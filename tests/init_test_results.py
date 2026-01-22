#!/usr/bin/env python3
"""
Initialize test results file with structure for all queries.
Run this once to create the initial QUERY_TEST_RESULTS.md file.
"""

from pathlib import Path
from typing import Dict, List
import sys


def discover_queries(query_dir: str = "queries") -> Dict[str, List[str]]:
    """Discover all queries organized by category."""
    queries_by_category = {}
    query_path = Path(query_dir)
    
    for sql_file in sorted(query_path.rglob("*.sql")):
        relative = sql_file.relative_to(query_path)
        parts = relative.parts[:-1]
        category = parts[0] if parts else "root"
        
        if category not in queries_by_category:
            queries_by_category[category] = []
        
        query_name = sql_file.stem
        queries_by_category[category].append(query_name)
    
    return queries_by_category


def generate_initial_markdown(queries_by_category: Dict[str, List[str]]) -> str:
    """Generate initial markdown table structure."""
    lines = [
        "# Query Test Results\n",
        "## Status Summary",
        "| Category | Total | Pass | Pending | Errors | Empty |",
        "|----------|-------|------|---------|--------|-------|",
    ]
    
    # Add summary rows (will be updated by test runner)
    for category in sorted(queries_by_category.keys()):
        lines.append(f"| {category} | - | - | - | - | - |")
    
    lines.append("\n## Results by Category\n")
    
    # Add detailed results by category
    for category in sorted(queries_by_category.keys()):
        lines.append(f"### {category.replace('_', ' ').title()}\n")
        lines.append("| Query | Complexity | Status | Rows | Bytes | Cost USD | Last Run |")
        lines.append("|-------|------------|--------|------|-------|----------|----------|")
        
        for query_name in sorted(queries_by_category[category]):
            lines.append(f"| {query_name} | - | - | - | - | - | - |")
        
        lines.append("")
    
    return "\n".join(lines)


if __name__ == "__main__":
    queries = discover_queries("queries")
    total_queries = sum(len(q) for q in queries.values())
    print(f"Discovered {total_queries} queries in {len(queries)} categories")
    
    # Create output directory
    Path("tests").mkdir(exist_ok=True)
    
    # Generate and write initial markdown
    markdown = generate_initial_markdown(queries)
    with open("tests/QUERY_TEST_RESULTS.md", "w") as f:
        f.write(markdown)
    
    print("✓ Created tests/QUERY_TEST_RESULTS.md")
