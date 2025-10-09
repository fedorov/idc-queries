# Quick Start Guide

Welcome to IDC Queries! This guide will help you get started quickly.

## What is IDC?

The NCI Imaging Data Commons (IDC) is a cloud-based repository of publicly available cancer imaging data. IDC makes this data available in Google BigQuery, allowing you to query and analyze imaging metadata at scale.

## Getting Started in 5 Minutes

### 1. Access BigQuery

You can access BigQuery in two ways:

**Option A: BigQuery Sandbox (No billing required)**
1. Go to [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Sign in with your Google account
3. You get 1 TB of free query processing per month

**Option B: Google Cloud Project**
1. Create a Google Cloud account
2. Create a new project
3. Enable BigQuery API

### 2. Try Your First Query

1. Open the [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Click "Compose New Query"
3. Copy this simple query:

```sql
SELECT 
  collection_id,
  COUNT(DISTINCT StudyInstanceUID) as study_count
FROM 
  `bigquery-public-data.idc_current.dicom_all`
GROUP BY 
  collection_id
ORDER BY 
  study_count DESC
LIMIT 10
```

4. Click "Run"
5. See the top 10 collections by study count!

### 3. Explore More Queries

Browse the `queries/` directory to find more examples:

- **queries/basic/** - Simple queries to explore IDC data structure
- **queries/modality/** - Queries specific to imaging types (CT, MR, PT, etc.)
- **queries/collections/** - Queries for specific cancer imaging collections

## Understanding the YAML Format

Each query is stored in a YAML file with this structure:

```yaml
title: Brief title
description: |
  What this query does and why it's useful
keywords:
  - searchable
  - tags
sql: |
  SELECT * FROM ...
```

See [schema/query-schema.md](schema/query-schema.md) for complete details.

## Next Steps

1. **Learn about IDC data**: Visit [IDC Documentation](https://learn.canceridc.dev/)
2. **Explore collections**: Browse available collections at [IDC Portal](https://imaging.datacommons.cancer.gov/)
3. **Try more queries**: Browse the queries/ directory
4. **Contribute**: Share your own useful queries!

## Common Use Cases

### Find CT scans from a specific collection
```sql
SELECT 
  PatientID,
  SeriesInstanceUID,
  SeriesDescription
FROM 
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  collection_id = 'tcga_luad'
  AND Modality = 'CT'
LIMIT 100
```

### Count images by modality
See: `queries/modality/count_instances_by_modality.yaml`

### List all collections
```sql
SELECT DISTINCT
  collection_id,
  collection_name
FROM 
  `bigquery-public-data.idc_current.dicom_all`
ORDER BY
  collection_id
```

## Tips for Writing Queries

1. **Always use LIMIT**: Prevent accidentally downloading huge result sets
2. **Use fully qualified table names**: `project.dataset.table`
3. **Filter early**: Use WHERE clauses to reduce data scanned
4. **Check cost estimates**: BigQuery shows data to be scanned before running

## Getting Help

- **IDC Forum**: [discourse.canceridc.dev](https://discourse.canceridc.dev/)
- **BigQuery Docs**: [cloud.google.com/bigquery/docs](https://cloud.google.com/bigquery/docs)
- **Open an issue**: If you find problems with queries in this repo

## Cost Considerations

BigQuery charges based on data scanned:
- First 1 TB per month: Free
- After that: $5 per TB

Tips to minimize costs:
- Use LIMIT clauses
- Filter with WHERE before aggregating
- Use query preview to check data scanned
- Avoid `SELECT *` when possible

## Validating Queries

Before contributing, validate your query file:

```bash
python validate_query.py queries/your-category/your-query.yaml
```

This checks:
- Required fields are present
- Field types are correct
- Best practices are followed

Happy querying! 🎉
