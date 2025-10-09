# YAML Schema for IDC Query Files

This document provides a formal specification of the YAML schema used for IDC query files.

## Schema Version: 1.0

## Structure

```yaml
title: string (required)
description: string (required, multiline supported)
keywords: list<string> (required)
author: string (optional)
idc_version: string (optional)
modality: list<string> (optional)
difficulty: enum (optional)
estimated_cost: enum (optional)
sql: string (required, multiline supported)
notes: string (optional, multiline supported)
related_queries: list<string> (optional)
```

## Field Specifications

### title (required)
- **Type**: String
- **Description**: A short, descriptive title for the query
- **Constraints**: 
  - Should be concise (ideally under 80 characters)
  - Should be descriptive enough to understand the query's purpose
- **Example**: `"Count studies by collection"`

### description (required)
- **Type**: String (multiline supported with `|`)
- **Description**: Detailed explanation of what the query does, what data it returns, and any prerequisites
- **Constraints**: 
  - Should be at least one sentence
  - Should explain the purpose and expected output
- **Example**: 
  ```yaml
  description: |
    Returns the number of studies in each collection in IDC.
    Useful for getting an overview of dataset sizes.
  ```

### keywords (required)
- **Type**: List of strings
- **Description**: Searchable keywords/tags for query discovery
- **Constraints**: 
  - At least one keyword required
  - Use lowercase
  - Include relevant terms: modality, data type, operation, difficulty level
- **Example**: 
  ```yaml
  keywords:
    - collections
    - studies
    - counts
    - basic
  ```

### author (optional)
- **Type**: String
- **Description**: Name or identifier of the query author
- **Example**: `"John Doe"` or `"@johndoe"`

### idc_version (optional)
- **Type**: String
- **Description**: IDC dataset version the query was tested with
- **Constraints**: Use version notation (e.g., "v17") or "current"
- **Example**: `"v17"` or `"current"`

### modality (optional)
- **Type**: List of strings
- **Description**: Relevant imaging modalities for modality-specific queries
- **Constraints**: Use standard DICOM modality codes
- **Valid values**: CT, MR, PT, NM, US, DX, MG, XA, RF, etc.
- **Example**: 
  ```yaml
  modality:
    - CT
    - MR
  ```

### difficulty (optional)
- **Type**: Enum string
- **Description**: Complexity level of the query
- **Valid values**: 
  - `basic`: Simple queries, single table, basic filtering
  - `intermediate`: Multiple tables, joins, aggregations
  - `advanced`: Complex joins, subqueries, window functions, CTEs
- **Example**: `"basic"`

### estimated_cost (optional)
- **Type**: Enum string
- **Description**: Approximate cost based on amount of data scanned
- **Valid values**: 
  - `low`: < 100 MB scanned
  - `medium`: 100 MB - 1 GB scanned
  - `high`: > 1 GB scanned
- **Example**: `"low"`

### sql (required)
- **Type**: String (multiline supported with `|`)
- **Description**: The BigQuery SQL query
- **Constraints**: 
  - Must be valid BigQuery SQL
  - Should use fully qualified table names (project.dataset.table)
  - Should include LIMIT clause for queries that might return large results
  - Should be formatted for readability (indented, uppercase keywords recommended)
- **Example**: 
  ```yaml
  sql: |
    SELECT 
      collection_id,
      COUNT(DISTINCT StudyInstanceUID) as study_count
    FROM 
      `bigquery-public-data.idc_current.dicom_all`
    GROUP BY 
      collection_id
    ORDER BY 
      study_count DESC
  ```

### notes (optional)
- **Type**: String (multiline supported with `|`)
- **Description**: Additional information, tips, warnings, or usage notes
- **Example**: 
  ```yaml
  notes: |
    This query scans minimal data and is suitable for exploring
    the structure of IDC collections.
  ```

### related_queries (optional)
- **Type**: List of strings
- **Description**: Paths to related query files in the repository
- **Constraints**: Use relative paths from repository root
- **Example**: 
  ```yaml
  related_queries:
    - queries/basic/count_series_by_collection.yaml
    - queries/collections/list_collections.yaml
  ```

## Validation

To validate a query file against this schema, you can use Python with the `pyyaml` library:

```python
import yaml

def validate_query_file(filepath):
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f)
    
    # Check required fields
    required_fields = ['title', 'description', 'keywords', 'sql']
    for field in required_fields:
        if field not in data:
            raise ValueError(f"Missing required field: {field}")
    
    # Validate enums
    if 'difficulty' in data:
        valid_difficulties = ['basic', 'intermediate', 'advanced']
        if data['difficulty'] not in valid_difficulties:
            raise ValueError(f"Invalid difficulty: {data['difficulty']}")
    
    if 'estimated_cost' in data:
        valid_costs = ['low', 'medium', 'high']
        if data['estimated_cost'] not in valid_costs:
            raise ValueError(f"Invalid estimated_cost: {data['estimated_cost']}")
    
    return True
```

## Best Practices

1. **Be specific in descriptions**: Help users understand exactly what data will be returned
2. **Use meaningful keywords**: Include terms users might search for
3. **Test queries**: Always test against the specified IDC version before committing
4. **Include notes for complex queries**: Explain non-obvious aspects or performance considerations
5. **Link related queries**: Help users discover similar or complementary queries
6. **Format SQL consistently**: Use indentation and uppercase keywords for readability
7. **Consider cost**: Add LIMIT clauses or WHERE conditions to minimize data scanned
8. **Document assumptions**: If a query assumes certain data characteristics, note this

## Example Complete Query File

```yaml
title: CT series with specific slice thickness
description: |
  Finds all CT series with slice thickness between 1mm and 3mm
  from the TCGA-LUAD collection. Returns series-level metadata
  including patient ID, study date, and series description.
keywords:
  - CT
  - slice thickness
  - TCGA-LUAD
  - series
  - modality
author: IDC Team
idc_version: "current"
modality:
  - CT
difficulty: intermediate
estimated_cost: medium
sql: |
  SELECT 
    PatientID,
    StudyInstanceUID,
    SeriesInstanceUID,
    StudyDate,
    SeriesDescription,
    SliceThickness,
    COUNT(*) as instance_count
  FROM 
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    collection_id = 'tcga_luad'
    AND Modality = 'CT'
    AND SliceThickness BETWEEN 1 AND 3
  GROUP BY
    PatientID,
    StudyInstanceUID,
    SeriesInstanceUID,
    StudyDate,
    SeriesDescription,
    SliceThickness
  ORDER BY
    PatientID, StudyDate
  LIMIT 1000
notes: |
  This query filters by slice thickness, which is important for
  certain types of analysis. Be aware that not all CT series
  have slice thickness properly recorded in DICOM metadata.
  
  Estimated to scan ~500MB of data.
related_queries:
  - queries/modality/count_instances_by_modality.yaml
  - queries/collections/explore_tcga_luad.yaml
```

## Changelog

### Version 1.0 (Initial)
- Initial schema definition
- Core fields: title, description, keywords, sql
- Optional metadata: author, idc_version, modality, difficulty, estimated_cost
- Optional fields: notes, related_queries
