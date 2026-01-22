"""
BigQuery Regression Test Runner

Validates all queries by:
1. Running dry run to check syntax and estimate cost
2. Executing with LIMIT clause to ensure non-empty results
3. Capturing execution stats (bytes scanned, estimated cost, execution time)
4. Logging results to a markdown summary table
"""

import os
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import yaml

try:
    from google.cloud import bigquery
    from google.oauth2 import service_account
except ImportError:
    print("ERROR: google-cloud-bigquery not installed")
    print("Install with: pip install google-cloud-bigquery google-auth")
    sys.exit(1)


class QueryTestRunner:
    def __init__(self, credentials_json: Optional[str] = None):
        """Initialize BigQuery client with service account credentials."""
        self.project_id = None
        self.client = None
        self.results = []
        
        if credentials_json:
            try:
                credentials = service_account.Credentials.from_service_account_file(
                    credentials_json
                )
                self.project_id = credentials.project_id
                self.client = bigquery.Client(
                    credentials=credentials,
                    project=self.project_id
                )
            except Exception as e:
                print(f"ERROR: Failed to authenticate with credentials: {e}")
                sys.exit(1)
        else:
            try:
                self.client = bigquery.Client()
                self.project_id = self.client.project
            except Exception as e:
                print(f"ERROR: Failed to create BigQuery client: {e}")
                print("Ensure GCP_SA_KEY environment variable or credentials are configured")
                sys.exit(1)

    def load_queries(self, query_dir: str) -> Dict[str, Dict]:
        """Load all .sql files from query directory, excluding pending."""
        queries = {}
        query_path = Path(query_dir)
        
        for sql_file in query_path.rglob("*.sql"):
            # Skip pending folder for execution testing
            if "pending" in str(sql_file):
                category = "pending"
            else:
                # Extract category from folder structure
                relative = sql_file.relative_to(query_path)
                parts = relative.parts[:-1]  # Exclude filename
                category = parts[0] if parts else "root"
            
            with open(sql_file, "r") as f:
                query_content = f.read()
            
            query_name = sql_file.stem
            queries[str(sql_file)] = {
                "name": query_name,
                "category": category,
                "path": str(sql_file),
                "content": query_content,
                "is_pending": category == "pending"
            }
        
        return queries

    def extract_complexity(self, content: str) -> str:
        """Extract complexity from query header comments."""
        for line in content.split("\n")[:10]:
            if "Complexity:" in line:
                # Extract: "Complexity: Low" -> "Low"
                return line.split("Complexity:")[1].strip().split("|")[0].strip()
        return "Unknown"

    def extract_estimated_cost(self, content: str) -> str:
        """Extract estimated cost from query header comments."""
        for line in content.split("\n")[:10]:
            if "Estimated Cost:" in line:
                # Extract estimated cost before "|"
                return line.split("Estimated Cost:")[1].strip().split("|")[0].strip()
        return "TBD"

    def run_dry_run(self, query_content: str) -> Tuple[bool, Optional[int], Optional[float], str]:
        """
        Execute dry run to validate syntax and estimate cost.
        
        Returns: (success, bytes_scanned, estimated_cost_usd, error_message)
        """
        try:
            job_config = bigquery.QueryJobConfig(dry_run=True)
            query_job = self.client.query(query_content, job_config=job_config)
            
            # Dry run doesn't execute, but returns stats
            bytes_scanned = query_job.total_bytes_processed or 0
            estimated_cost = (bytes_scanned / (1024 ** 4)) * 6.25  # $6.25 per TB
            
            return True, bytes_scanned, estimated_cost, ""
        except Exception as e:
            return False, None, None, str(e)

    def run_query_with_limit(self, query_content: str, limit: int = 1000) -> Tuple[bool, int, Optional[int], Optional[float], str]:
        """
        Execute query with LIMIT clause.
        
        Returns: (success, row_count, bytes_scanned, estimated_cost_usd, error_message)
        """
        try:
            # Append LIMIT if not already present
            if "LIMIT" not in query_content.upper():
                query_to_run = f"{query_content}\nLIMIT {limit}"
            else:
                query_to_run = query_content
            
            query_job = self.client.query(query_to_run)
            result = query_job.result()
            
            row_count = result.total_rows
            bytes_scanned = query_job.total_bytes_processed or 0
            estimated_cost = (bytes_scanned / (1024 ** 4)) * 6.25
            
            return True, row_count, bytes_scanned, estimated_cost, ""
        except Exception as e:
            return False, 0, None, None, str(e)

    def test_query(self, query_info: Dict) -> Dict:
        """Run full test cycle for a query: dry run -> execution -> capture stats."""
        result = {
            "name": query_info["name"],
            "category": query_info["category"],
            "path": query_info["path"],
            "is_pending": query_info["is_pending"],
            "complexity": self.extract_complexity(query_info["content"]),
            "estimated_cost_header": self.extract_estimated_cost(query_info["content"]),
            "dry_run_success": False,
            "dry_run_error": "",
            "execution_success": False,
            "execution_error": "",
            "row_count": 0,
            "bytes_scanned": 0,
            "estimated_cost_usd": 0.0,
            "status": "Unknown"
        }
        
        # Step 1: Dry run
        dry_run_ok, bytes_estimated, cost_estimated, dry_error = self.run_dry_run(query_info["content"])
        result["dry_run_success"] = dry_run_ok
        result["dry_run_error"] = dry_error
        
        if not dry_run_ok:
            result["status"] = "Syntax Error"
            return result
        
        # Step 2: Execute (only for non-pending queries)
        if query_info["is_pending"]:
            result["status"] = "Pending Review"
            return result
        
        exec_ok, row_count, bytes_scanned, cost_actual, exec_error = self.run_query_with_limit(query_info["content"])
        result["execution_success"] = exec_ok
        result["execution_error"] = exec_error
        result["row_count"] = row_count
        result["bytes_scanned"] = bytes_scanned or 0
        result["estimated_cost_usd"] = cost_actual or 0.0
        
        if not exec_ok:
            result["status"] = "Execution Error"
        elif row_count == 0:
            result["status"] = "Empty Result"
        else:
            result["status"] = "Pass"
        
        return result

    def format_bytes(self, bytes_val: int) -> str:
        """Format bytes to human-readable format."""
        for unit in ["B", "KB", "MB", "GB", "TB"]:
            if bytes_val < 1024:
                return f"{bytes_val:.2f}{unit}"
            bytes_val /= 1024
        return f"{bytes_val:.2f}PB"

    def generate_markdown_report(self, results: List[Dict]) -> str:
        """Generate markdown table of test results."""
        lines = [
            "# Query Regression Test Results",
            f"\n**Generated:** {datetime.now().isoformat()}",
            f"**Total Queries:** {len(results)}",
            f"**Pass:** {sum(1 for r in results if r['status'] == 'Pass')}",
            f"**Pending Review:** {sum(1 for r in results if r['status'] == 'Pending Review')}",
            f"**Syntax Errors:** {sum(1 for r in results if r['status'] == 'Syntax Error')}",
            f"**Execution Errors:** {sum(1 for r in results if r['status'] == 'Execution Error')}",
            f"**Empty Results:** {sum(1 for r in results if r['status'] == 'Empty Result')}",
            "\n## Results by Query\n",
            "| Query | Category | Complexity | Status | Rows | Bytes | Cost USD | Dry Run Error | Exec Error |",
            "|-------|----------|------------|--------|------|-------|----------|---------------|-----------|"
        ]
        
        for r in sorted(results, key=lambda x: (x["category"], x["name"])):
            dry_error = r["dry_run_error"][:30] + "..." if len(r["dry_run_error"]) > 30 else r["dry_run_error"]
            exec_error = r["execution_error"][:30] + "..." if len(r["execution_error"]) > 30 else r["execution_error"]
            
            bytes_fmt = self.format_bytes(r["bytes_scanned"]) if r["bytes_scanned"] > 0 else "N/A"
            cost_fmt = f"${r['estimated_cost_usd']:.4f}" if r["estimated_cost_usd"] > 0 else "N/A"
            rows_fmt = str(r["row_count"]) if r["row_count"] > 0 else "N/A"
            
            line = f"| {r['name']} | {r['category']} | {r['complexity']} | {r['status']} | {rows_fmt} | {bytes_fmt} | {cost_fmt} | {dry_error} | {exec_error} |"
            lines.append(line)
        
        return "\n".join(lines)

    def run_all_tests(self, query_dir: str) -> Tuple[List[Dict], str]:
        """Run tests for all queries."""
        queries = self.load_queries(query_dir)
        print(f"\nLoaded {len(queries)} queries from {query_dir}")
        
        for i, (path, query_info) in enumerate(queries.items(), 1):
            print(f"  [{i}/{len(queries)}] Testing {query_info['name']}...", end=" ")
            result = self.test_query(query_info)
            self.results.append(result)
            print(f"[{result['status']}]")
        
        report = self.generate_markdown_report(self.results)
        return self.results, report


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Run regression tests on BigQuery queries")
    parser.add_argument("--query-dir", default="queries", help="Directory containing query files")
    parser.add_argument("--output", default="tests/QUERY_TEST_RESULTS.md", help="Output markdown file")
    parser.add_argument("--credentials", help="Path to GCP service account JSON (or use GCP_SA_KEY env)")
    parser.add_argument("--json-output", help="Also write results as JSON")
    
    args = parser.parse_args()
    
    # Get credentials path
    creds_path = args.credentials or os.getenv("GCP_SA_KEY")
    
    # Initialize runner
    runner = QueryTestRunner(creds_path)
    print(f"Authenticated as: {runner.project_id}")
    
    # Run tests
    results, report = runner.run_all_tests(args.query_dir)
    
    # Write markdown report
    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "w") as f:
        f.write(report)
    print(f"\n✓ Wrote test results to {args.output}")
    
    # Write JSON output if requested
    if args.json_output:
        os.makedirs(os.path.dirname(args.json_output) or ".", exist_ok=True)
        with open(args.json_output, "w") as f:
            json.dump(results, f, indent=2)
        print(f"✓ Wrote JSON results to {args.json_output}")
    
    # Exit with error code if any tests failed (non-pending)
    non_pending = [r for r in results if not r["is_pending"]]
    failures = [r for r in non_pending if r["status"] not in ["Pass"]]
    
    if failures:
        print(f"\n❌ {len(failures)} test(s) failed:")
        for f in failures:
            print(f"   - {f['name']}: {f['status']}")
        return 1
    
    print(f"\n✓ All {len(non_pending)} production queries passed!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
