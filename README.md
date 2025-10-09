# IDC Queries

A collection of BigQuery SQL queries to help users navigate and explore [Imaging Data Commons (IDC)](https://imaging.datacommons.cancer.gov/) BigQuery datasets.

## About IDC Datasets

The [NCI Imaging Data Commons (IDC)](https://imaging.datacommons.cancer.gov/) is a cloud-based repository of publicly available cancer imaging data co-located with analysis and exploration tools and resources. IDC makes imaging data and related metadata available in Google BigQuery, enabling fast and efficient queries across large collections of imaging studies.

### IDC BigQuery Datasets

IDC provides several BigQuery datasets containing metadata about:
- **DICOM instances**: Individual medical imaging files with technical metadata
- **Series**: Groups of related images (e.g., all slices in a CT scan)
- **Studies**: Complete imaging examinations
- **Collections**: Curated sets of studies organized by research focus
- **Clinical and derived data**: Patient information, measurements, annotations, and analysis results

The main IDC BigQuery project is `bigquery-public-data.idc_current` for the most recent version, with versioned datasets also available (e.g., `bigquery-public-data.idc_v17`).

## Getting Started with BigQuery

### Prerequisites
- A Google Cloud Platform account (free tier available)
- Basic knowledge of SQL

### Learning Resources

#### BigQuery Documentation
- [BigQuery Official Documentation](https://cloud.google.com/bigquery/docs)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices)

#### IDC-Specific Resources
- [IDC Documentation](https://learn.canceridc.dev/)
- [IDC Portal](https://imaging.datacommons.cancer.gov/)
- [IDC Data Model](https://learn.canceridc.dev/data-model)
- [IDC BigQuery Tutorial](https://learn.canceridc.dev/cookbook/bigquery)
- [IDC GitHub Organization](https://github.com/ImagingDataCommons)

#### Tutorials and Examples
- [Google Cloud BigQuery Quickstart](https://cloud.google.com/bigquery/docs/quickstarts)
- [BigQuery Sandbox](https://cloud.google.com/bigquery/docs/sandbox) - Use BigQuery without providing billing information
- [IDC Example Notebooks](https://github.com/ImagingDataCommons/IDC-Examples)

## Repository Organization

This repository is organized to facilitate easy discovery and reuse of BigQuery queries for IDC datasets:

```
idc-queries/
├── README.md                 # This file
├── queries/                  # Directory containing all query files
│   ├── basic/               # Simple queries for getting started
│   ├── collections/         # Queries related to specific collections
│   ├── clinical/            # Queries involving clinical data
│   ├── modality/            # Modality-specific queries (CT, MR, PT, etc.)
│   ├── series/              # Queries at the series level
│   ├── studies/             # Queries at the study level
│   └── advanced/            # Complex queries and joins
└── schema/                  # Documentation and validation schemas
```

### Query Categories

Queries are organized into directories by category:
- **basic/**: Simple queries for beginners exploring IDC data structure
- **collections/**: Queries to explore specific imaging collections
- **clinical/**: Queries that incorporate clinical data
- **modality/**: Queries specific to imaging modalities (CT, MR, PT, etc.)
- **series/**: Queries focused on series-level metadata
- **studies/**: Queries focused on study-level metadata
- **advanced/**: Complex queries involving multiple tables or advanced SQL features

## YAML Schema for Queries

Each query is stored in a YAML file with the following structure:

```yaml
title: Brief descriptive title of the query
description: |
  Detailed description of what the query does, what data it returns,
  and any important considerations or prerequisites.
keywords:
  - keyword1
  - keyword2
  - keyword3
author: Author name or username (optional)
idc_version: "v17"  # IDC data version this query was tested with
modality:  # Optional, for modality-specific queries
  - CT
  - MR
difficulty: basic  # Options: basic, intermediate, advanced
estimated_cost: low  # Options: low, medium, high (based on data scanned)
sql: |
  SELECT 
    column1,
    column2
  FROM 
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    condition = 'value'
  LIMIT 100
notes: |
  Optional additional notes, tips, or warnings about running the query.
related_queries:  # Optional, links to related queries
  - path/to/related/query.yaml
```

### Schema Fields

#### Required Fields
- **title**: Short, descriptive title (string)
- **description**: Detailed explanation of the query's purpose (string, multiline supported)
- **keywords**: List of searchable keywords/tags (list of strings)
- **sql**: The BigQuery SQL query (string, multiline supported)

#### Optional Fields
- **author**: Query author name or identifier (string)
- **idc_version**: IDC dataset version tested with (string, e.g., "v17", "current")
- **modality**: Relevant imaging modalities (list of strings: CT, MR, PT, etc.)
- **difficulty**: Query complexity level (string: "basic", "intermediate", "advanced")
- **estimated_cost**: Approximate cost/data scanned (string: "low", "medium", "high")
- **notes**: Additional information, warnings, or tips (string, multiline supported)
- **related_queries**: Links to related query files (list of strings)

### Example Query File

```yaml
# queries/basic/count_studies_by_collection.yaml
title: Count studies by collection
description: |
  Returns the number of studies in each collection in IDC.
  Useful for getting an overview of dataset sizes.
keywords:
  - collections
  - studies
  - counts
  - basic
idc_version: "current"
difficulty: basic
estimated_cost: low
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
notes: |
  This query scans minimal data and is suitable for exploring
  the structure of IDC collections.
```

## Using the Queries

### In BigQuery Console
1. Navigate to [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Copy the SQL from any query file
3. Paste into the query editor
4. Run the query

### Programmatically
Use the [Google Cloud BigQuery Client Libraries](https://cloud.google.com/bigquery/docs/reference/libraries) for your preferred language:

**Python Example:**
```python
from google.cloud import bigquery
import yaml

# Load query from YAML
with open('queries/basic/count_studies_by_collection.yaml', 'r') as f:
    query_data = yaml.safe_load(f)

# Execute query
client = bigquery.Client()
results = client.query(query_data['sql']).result()

for row in results:
    print(f"{row.collection_id}: {row.study_count} studies")
```

## Contributing

Contributions are welcome! When adding a new query:
1. Follow the YAML schema outlined above
2. Place the query in the appropriate category directory
3. Use clear, descriptive naming (e.g., `count_ct_series_by_manufacturer.yaml`)
4. Test your query against the latest IDC dataset
5. Include helpful descriptions and notes

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Resources and Support

- [IDC Forum](https://discourse.canceridc.dev/) - Community support and discussions
- [IDC GitHub Issues](https://github.com/ImagingDataCommons/IDC-WebApp/issues) - Report issues with IDC
- [Google Cloud Support](https://cloud.google.com/support) - BigQuery technical support