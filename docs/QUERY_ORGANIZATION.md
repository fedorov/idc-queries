# Query Organization

This directory contains ~50 BigQuery queries for analyzing DICOM metadata in the Imaging Data Commons (IDC).

## Directory Structure

```
queries/
├── general/                  # General utility queries
├── segmentations/           # DICOM Segmentation (SEG) queries
├── lesions/                 # Lesion and nodule queries
├── measurements/            # Quantitative & qualitative measurements
├── rtstruct/                # Radiotherapy Structure Set (RTSTRUCT) queries
├── pet/                     # PET imaging queries
├── image_series/            # Image series analysis
├── series_analysis/         # Series-level analysis
├── transfer_syntax/         # Transfer syntax and encoding
├── annotations/             # Annotation and modality queries
├── private_tags/            # Private DICOM tag queries
├── slide_microscopy/        # Slide Microscopy (SM) queries
├── collection_specific/     # Collection-specific queries
└── pending/                 # Queries requiring curation
```

## Query Categories

### General (`general/`)
Utility queries for data validation and exploration:
- PatientID collection membership verification
- UID reuse detection across hierarchy

### Segmentations (`segmentations/`)
Analysis of DICOM Segmentation objects:
- Anisotropic pixel spacing detection
- Segment count analysis
- Anatomy/property type combinations
- Algorithm type classification

### Lesions (`lesions/`)
Lesion and nodule-specific analysis:
- LIDC collection nodule clustering
- Unique lesion identification

### Measurements (`measurements/`)
Quantitative and qualitative measurement queries:
- Structured Report (SR) template analysis
- Volume measurements
- Measurement type inventory
- Pivoting/joining measurements by SOPInstanceUID

### RTSTRUCT (`rtstruct/`)
Radiotherapy structure analysis:
- ROI name enumeration
- Instance-ROI mapping

### PET (`pet/`)
PET imaging specific queries:
- SUV (Standardized Uptake Value) calculations
- Decay correction and unit analysis

### Image Series (`image_series/`)
Series-level image analysis:
- ImagePositionPatient distribution
- 4D image detection
- Multiframe series sizing

### Series Analysis (`series_analysis/`)
Advanced series characteristics:
- FrameOfReferenceUID multiplicity
- Frame-level analysis

### Transfer Syntax (`transfer_syntax/`)
Encoding and compression analysis:
- Transfer syntax enumeration
- Compression type identification

### Annotations (`annotations/`)
Annotation availability and modality:
- SEG/RTSTRUCT presence per collection
- Modality inventory

### Private Tags (`private_tags/`)
Private DICOM tag extraction:
- Manufacturer-specific attributes
- B-value extraction from private tags

### Slide Microscopy (`slide_microscopy/`)
Whole Slide Image (WSI) analysis:
- Slide identification and metadata
- Processing step analysis
- Pixel spacing and resolution
- Source file tracking

### Collection-Specific (`collection_specific/`)
Collection-specific complex queries:
- RMS Mutation Prediction annotation merges
- Multi-table joins with clinical data

### Pending (`pending/`)
Queries requiring curation before production use:
- Parameterized queries (need parameter documentation)
- Template queries (need usage examples)
- Incomplete TODOs (need implementation)
- Queries with data quality issues
- See [pending/_PENDING_NOTES.md](pending/_PENDING_NOTES.md) for details

## File Naming Convention

All production query files use `snake_case`:
- `confirm_patientid_single_collection.sql`
- `segmentations_anisotropic_spacing.sql`
- `slides_by_project_id_param.sql`

## Query Headers

Every production query includes a standard header:

```sql
-- Purpose: Brief description of what the query does
-- 
-- Complexity: Low|Medium|High
-- Estimated Cost: $X.XX | Bytes Scanned: X.XXGB | Complexity: [tier]
-- 
-- Description:
-- Longer explanation of the query purpose, methodology, and output.
-- Include references to DICOM standards or other resources if applicable.
-- 
-- Author/Source: IDC Cookbook
```

## Complexity Grading

Queries are classified by complexity based on best practices:

### Low Complexity
- Single table scans with filtering
- Basic aggregations
- Estimated cost: < $0.10
- Examples: `count_segments_per_patient.sql`, `quantitative_measurement_types.sql`

### Medium Complexity
- Single table scans with joins or unnesting
- Multiple aggregation steps
- Estimated cost: $0.10 - $0.30
- Examples: `check_uid_reuse_across_hierarchy.sql`, `sr_tids_with_counts.sql`

### High Complexity
- Multiple table joins
- Complex unnesting and aggregations
- Large result sets or full table scans
- Estimated cost: > $0.30
- Examples: `images_multiple_slices_per_position.sql`, `rms_mutation_prediction_annotations_merge.sql`

## Datasets Used

All queries standardized to use:
- `bigquery-public-data.idc_current.dicom_all` - DICOM metadata
- `bigquery-public-data.idc_current.segmentations` - Segmentation data
- `bigquery-public-data.idc_current.quantitative_measurements` - Quant measurements
- `bigquery-public-data.idc_current.qualitative_measurements` - Qual measurements
- `bigquery-public-data.idc_current.dicom_metadata_curated_series_level` - Series metadata
- `bigquery-public-data.idc_current_clinical.*` - Clinical data tables

## Using Queries

### In Python

```python
from google.cloud import bigquery
from pathlib import Path

client = bigquery.Client()

# Load query file
with open("queries/general/confirm_patientid_single_collection.sql") as f:
    query = f.read()

# Execute
result = client.query(query).result()
print(f"Results: {result.total_rows} rows")
print(f"Cost estimate: ${(result.job.total_bytes_processed / (1024**4)) * 6.25:.4f}")
```

### With Command Line

```bash
# Using bq CLI
bq query --use_legacy_sql=false < queries/general/confirm_patientid_single_collection.sql

# Or with dry run to estimate cost
bq query --dry_run --use_legacy_sql=false < queries/general/confirm_patientid_single_collection.sql
```

### In BigQuery UI

1. Go to [console.cloud.google.com/bigquery](https://console.cloud.google.com/bigquery)
2. Create new query
3. Copy-paste query file content
4. Click "Run"

## Pending Query Curation

Queries in `queries/pending/` require manual curation before use. See [PENDING_CURATION.md](../docs/PENDING_CURATION.md) for detailed curation process and examples.

## Adding New Queries

1. Create query file in appropriate category folder with `snake_case` name
2. Add comprehensive header with purpose, complexity, and description
3. Use `bigquery-public-data.idc_current.*` datasets
4. Add meaningful comments for complex logic
5. Test locally with regression test suite:
   ```bash
   python tests/run_regression_tests.py --query-dir queries
   ```
6. Review stats update and commit changes

See [CONTRIBUTING.md](../docs/CONTRIBUTING.md) for full guidelines.

## Resources

- [IDC Documentation](https://imaging.datacommons.cancer.gov/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [DICOM Standard](https://dicom.nema.org/)
- [Query Complexity Guide](./COMPLEXITY_GRADING.md)
- [Setup and Testing Guide](./SETUP.md)
