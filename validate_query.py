#!/usr/bin/env python3
"""
Validate IDC Query YAML files against the schema.

Usage:
    python validate_query.py <path_to_query.yaml>
    python validate_query.py queries/basic/*.yaml
"""

import sys
import yaml
from pathlib import Path


def validate_query_file(filepath):
    """Validate a query file against the schema."""
    errors = []
    warnings = []
    
    try:
        with open(filepath, 'r') as f:
            data = yaml.safe_load(f)
    except Exception as e:
        return [f"Failed to parse YAML: {e}"], []
    
    if not isinstance(data, dict):
        return ["YAML file must contain a dictionary"], []
    
    # Check required fields
    required_fields = ['title', 'description', 'keywords', 'sql']
    for field in required_fields:
        if field not in data:
            errors.append(f"Missing required field: {field}")
        elif not data[field]:
            errors.append(f"Required field '{field}' is empty")
    
    # Validate field types
    if 'title' in data and not isinstance(data['title'], str):
        errors.append("'title' must be a string")
    
    if 'description' in data and not isinstance(data['description'], str):
        errors.append("'description' must be a string")
    
    if 'keywords' in data:
        if not isinstance(data['keywords'], list):
            errors.append("'keywords' must be a list")
        elif len(data['keywords']) == 0:
            errors.append("'keywords' must contain at least one keyword")
    
    if 'sql' in data and not isinstance(data['sql'], str):
        errors.append("'sql' must be a string")
    
    # Validate enums
    if 'difficulty' in data:
        valid_difficulties = ['basic', 'intermediate', 'advanced']
        if data['difficulty'] not in valid_difficulties:
            errors.append(
                f"'difficulty' must be one of {valid_difficulties}, "
                f"got '{data['difficulty']}'"
            )
    
    if 'estimated_cost' in data:
        valid_costs = ['low', 'medium', 'high']
        if data['estimated_cost'] not in valid_costs:
            errors.append(
                f"'estimated_cost' must be one of {valid_costs}, "
                f"got '{data['estimated_cost']}'"
            )
    
    # Validate optional field types
    if 'author' in data and not isinstance(data['author'], str):
        errors.append("'author' must be a string")
    
    if 'idc_version' in data and not isinstance(data['idc_version'], str):
        errors.append("'idc_version' must be a string")
    
    if 'modality' in data and not isinstance(data['modality'], list):
        errors.append("'modality' must be a list")
    
    if 'notes' in data and not isinstance(data['notes'], str):
        errors.append("'notes' must be a string")
    
    if 'related_queries' in data and not isinstance(data['related_queries'], list):
        errors.append("'related_queries' must be a list")
    
    # Warnings for best practices
    if 'title' in data and len(data['title']) > 80:
        warnings.append(
            f"Title is {len(data['title'])} characters, "
            "consider keeping it under 80 characters"
        )
    
    if 'sql' in data and 'LIMIT' not in data['sql'].upper():
        warnings.append(
            "Query does not contain a LIMIT clause, "
            "consider adding one to prevent large result sets"
        )
    
    if 'difficulty' not in data:
        warnings.append("Consider adding 'difficulty' field")
    
    if 'estimated_cost' not in data:
        warnings.append("Consider adding 'estimated_cost' field")
    
    return errors, warnings


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    files = []
    for arg in sys.argv[1:]:
        path = Path(arg)
        if path.is_file():
            files.append(path)
        elif path.is_dir():
            files.extend(path.glob('**/*.yaml'))
            files.extend(path.glob('**/*.yml'))
    
    if not files:
        print("No YAML files found to validate")
        sys.exit(1)
    
    total_errors = 0
    total_warnings = 0
    
    for filepath in files:
        print(f"\nValidating: {filepath}")
        errors, warnings = validate_query_file(filepath)
        
        if errors:
            total_errors += len(errors)
            print(f"  ✗ {len(errors)} error(s):")
            for error in errors:
                print(f"    - {error}")
        else:
            print("  ✓ No errors")
        
        if warnings:
            total_warnings += len(warnings)
            print(f"  ⚠ {len(warnings)} warning(s):")
            for warning in warnings:
                print(f"    - {warning}")
    
    print(f"\n{'='*60}")
    print(f"Validated {len(files)} file(s)")
    print(f"Total errors: {total_errors}")
    print(f"Total warnings: {total_warnings}")
    
    if total_errors > 0:
        sys.exit(1)
    else:
        print("\n✓ All files are valid!")
        sys.exit(0)


if __name__ == '__main__':
    main()
