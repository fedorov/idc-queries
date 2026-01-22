"""
Update query header with actual execution statistics

Updates query header comments with real execution stats from regression tests,
but only if variance exceeds 10% threshold.
"""

import os
import re
from pathlib import Path
from typing import Dict, Tuple
import json


class QueryHeaderUpdater:
    def __init__(self, variance_threshold: float = 0.10):
        """
        Initialize updater.
        
        Args:
            variance_threshold: Only update if new value differs by this percentage (default 10%)
        """
        self.variance_threshold = variance_threshold

    def parse_header_stats(self, content: str) -> Dict:
        """Extract existing stats from query header."""
        stats = {
            "estimated_cost": "TBD",
            "bytes_scanned": "TBD",
            "complexity": "Unknown"
        }
        
        for line in content.split("\n")[:20]:
            if "Estimated Cost:" in line:
                cost_match = re.search(r"Estimated Cost:\s*([^\|]+)", line)
                if cost_match:
                    stats["estimated_cost"] = cost_match.group(1).strip()
            
            if "Bytes Scanned:" in line:
                bytes_match = re.search(r"Bytes Scanned:\s*([^\|]+)", line)
                if bytes_match:
                    stats["bytes_scanned"] = bytes_match.group(1).strip()
            
            if "Complexity:" in line:
                complexity_match = re.search(r"Complexity:\s*([^\|]+)", line)
                if complexity_match:
                    stats["complexity"] = complexity_match.group(1).strip()
        
        return stats

    def estimate_cost_from_bytes(self, bytes_scanned: int) -> float:
        """Estimate cost at $6.25 per TB."""
        tb_scanned = bytes_scanned / (1024 ** 4)
        return tb_scanned * 6.25

    def format_bytes(self, bytes_val: int) -> str:
        """Format bytes to human-readable format."""
        for unit in ["B", "KB", "MB", "GB", "TB"]:
            if bytes_val < 1024:
                return f"{bytes_val:.2f}{unit}"
            bytes_val /= 1024
        return f"{bytes_val:.2f}PB"

    def exceeds_variance_threshold(self, old_val: str, new_val: float) -> bool:
        """Check if new value differs from old by more than threshold."""
        # Extract numeric value from old_val (e.g., "$0.10-0.25" -> take 0.10)
        if old_val == "TBD":
            return True  # Always update if was TBD
        
        try:
            # Try to parse a range or single value
            old_val_clean = old_val.replace("$", "").split("-")[0].strip()
            old_numeric = float(old_val_clean)
            
            # Calculate variance
            if old_numeric == 0:
                return new_val > 0.01  # Consider any positive value as exceeding threshold
            
            variance = abs(new_val - old_numeric) / old_numeric
            return variance > self.variance_threshold
        except (ValueError, IndexError):
            return True  # Update if can't parse

    def update_query_file(self, query_path: str, bytes_scanned: int, row_count: int) -> Tuple[bool, str]:
        """
        Update query file with execution stats if variance exceeds threshold.
        
        Returns: (was_updated, message)
        """
        try:
            with open(query_path, "r") as f:
                content = f.read()
            
            current_stats = self.parse_header_stats(content)
            estimated_cost_usd = self.estimate_cost_from_bytes(bytes_scanned)
            bytes_formatted = self.format_bytes(bytes_scanned)
            
            # Check if update is needed
            if not self.exceeds_variance_threshold(current_stats["estimated_cost"], estimated_cost_usd):
                return False, f"No update needed (variance < {self.variance_threshold*100}%)"
            
            # Create new stats string
            new_estimated_cost = f"${estimated_cost_usd:.4f}"
            new_bytes_scanned = bytes_formatted
            
            # Find and replace in header
            # Pattern: "-- Estimated Cost: ... | Bytes Scanned: ... | Complexity: ..."
            old_pattern = r"-- Estimated Cost:.*?\| Bytes Scanned:.*?\| Complexity:.*?\n"
            new_stats_line = f"-- Estimated Cost: {new_estimated_cost} | Bytes Scanned: {new_bytes_scanned} | Complexity: {current_stats['complexity']}\n"
            
            updated_content = re.sub(old_pattern, new_stats_line, content)
            
            if updated_content == content:
                return False, "Could not find stats pattern in header"
            
            # Write updated content
            with open(query_path, "w") as f:
                f.write(updated_content)
            
            return True, f"Updated: {new_estimated_cost} (was {current_stats['estimated_cost']}), {new_bytes_scanned} bytes"
        
        except Exception as e:
            return False, f"Error: {str(e)}"

    def batch_update(self, test_results: list, query_base_dir: str = "queries") -> Dict:
        """
        Update multiple query files based on test results.
        
        Returns: Dictionary with update status for each query
        """
        updates = {}
        
        for result in test_results:
            if result["is_pending"] or result["status"] != "Pass":
                continue  # Skip pending and failed queries
            
            query_path = result["path"]
            was_updated, message = self.update_query_file(
                query_path,
                result["bytes_scanned"],
                result["row_count"]
            )
            
            updates[result["name"]] = {
                "was_updated": was_updated,
                "message": message
            }
        
        return updates


def main():
    import argparse
    import json as json_module
    
    parser = argparse.ArgumentParser(description="Update query headers with execution stats")
    parser.add_argument("--results", required=True, help="JSON file with test results")
    parser.add_argument("--threshold", type=float, default=0.10, help="Variance threshold (default 0.10 = 10%)")
    parser.add_argument("--query-dir", default="queries", help="Base query directory")
    
    args = parser.parse_args()
    
    # Load results
    with open(args.results) as f:
        results = json_module.load(f)
    
    # Update headers
    updater = QueryHeaderUpdater(variance_threshold=args.threshold)
    updates = updater.batch_update(results, args.query_dir)
    
    # Print summary
    updated_count = sum(1 for u in updates.values() if u["was_updated"])
    print(f"\nUpdated {updated_count} of {len(updates)} queries")
    
    for name, status in updates.items():
        if status["was_updated"]:
            print(f"  ✓ {name}: {status['message']}")


if __name__ == "__main__":
    main()
