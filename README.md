# IDC BigQuery Queries Cookbook

[![Regression Tests](https://github.com/afxentis/idc-queries/actions/workflows/regression_tests.yml/badge.svg)](https://github.com/afxentis/idc-queries/actions/workflows/regression_tests.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A curated collection of BigQuery queries for analyzing DICOM metadata and derived data from the [Imaging Data Commons (IDC)](https://imaging.datacommons.cancer.gov/). 

Includes ~50 production-ready queries organized by topic (segmentations, measurements, slide microscopy, annotations, etc.) with automated regression testing, cost estimation, and complexity analysis.

## Quick Start

### View Queries

Browse the [queries/](queries/) directory organized by category:
- **[general/](queries/general/)** - Data validation queries
- **[segmentations/](queries/segmentations/)** - DICOM Segmentation (SEG) analysis
- **[measurements/](queries/measurements/)** - Quantitative & qualitative measurements
- **[slide_microscopy/](queries/slide_microscopy/)** - Whole Slide Image (WSI) queries
- **[collection_specific/](queries/collection_specific/)** - Collection-specific joins
- **[pending/](queries/pending/)** - Queries requiring curation

[See complete directory structure →](docs/QUERY_ORGANIZATION.md)

### Run a Query

**Via BigQuery Console:**
1. Go to [console.cloud.google.com/bigquery](https://console.cloud.google.com/bigquery)
2. Copy query file content
3. Click "Run"

**Via Python:**
```python
from google.cloud import bigquery
from pathlib import Path

client = bigquery.Client()
with open("queries/general/confirm_patientid_single_collection.sql") as f:
    query = f.read()
result = client.query(query).result()
print(f"Results: {result.total_rows} rows")
```

**Via Command Line:**
```bash
bq query --use_legacy_sql=false < queries/general/confirm_patientid_single_collection.sql
```

## Features

✅ **Production-Ready Queries** - 30 validated queries across 10 categories  
✅ **Automated Testing** - GitHub Actions CI/CD with regression tests  
✅ **Cost Analysis** - Estimated cost and complexity for every query  
✅ **Dynamic Stats** - Execution stats updated from real BigQuery runs  
✅ **Pending Queue** - 9 queries in curation (parameterized, templates, TODOs)  
✅ **Comprehensive Docs** - Setup guides, examples, and best practices  

## Documentation

| Guide | Content |
|-------|---------|
| [SETUP.md](docs/SETUP.md) | Authentication, local testing, troubleshooting |
| [QUERY_ORGANIZATION.md](docs/QUERY_ORGANIZATION.md) | Directory structure and query categories |
| [COMPLEXITY_GRADING.md](docs/COMPLEXITY_GRADING.md) | Low/Medium/High complexity explained |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | Adding new queries and contributing |
| [PENDING_CURATION.md](docs/PENDING_CURATION.md) | Curation process for pending queries |

## Query Statistics

| Category | Queries | Complexity | Est. Cost |
|----------|---------|------------|-----------|
| General | 2 | Low-Medium | $0.05-0.25 |
| Segmentations | 5 | Low-Medium | $0.05-0.30 |
| Measurements | 6 | Low-Medium | $0.05-0.50 |
| Slide Microscopy | 5 | Medium-High | $0.10-0.40 |
| Image Series | 3 | Medium-High | $0.15-0.50 |
| Collection-Specific | 1 | High | $0.30-1.00 |
| **Total Production** | **30** | - | - |
| **Total Pending** | **9** | - | - |

[View full test results →](tests/QUERY_TEST_RESULTS.md)

## Test Results

Latest regression test run: [tests/QUERY_TEST_RESULTS.md](tests/QUERY_TEST_RESULTS.md)

### Running Regression Tests Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run all tests
python tests/run_regression_tests.py \
  --query-dir queries \
  --output tests/QUERY_TEST_RESULTS.md

# Update query headers with real stats
python tests/update_query_headers.py \
  --results tests/query_test_results.json
```

[Full testing guide →](docs/SETUP.md#local-testing)

## Complexity & Cost

Each query includes complexity classification and cost estimation:

```sql
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
```

| Tier | Scope | Cost | Examples |
|------|-------|------|----------|
| **Low** | Single table, basic filters | < $0.10 | Volume measurements, distinct values |
| **Medium** | Joins, unnesting, aggregations | $0.10-0.30 | UID reuse detection, series analysis |
| **High** | Complex joins, full scans | > $0.30 | SM multi-table analysis, clinical joins |

[Complexity guide →](docs/COMPLEXITY_GRADING.md)

## BigQuery Datasets

All queries use standardized IDC datasets:

- `bigquery-public-data.idc_current.dicom_all` - DICOM metadata
- `bigquery-public-data.idc_current.segmentations` - Segmentation data
- `bigquery-public-data.idc_current.quantitative_measurements` - Measurements
- `bigquery-public-data.idc_current_clinical.*` - Clinical data

[Learn more →](https://imaging.datacommons.cancer.gov/)

## Contributing

1. **Adding new queries:** [CONTRIBUTING.md](docs/CONTRIBUTING.md)
2. **Curating pending queries:** [PENDING_CURATION.md](docs/PENDING_CURATION.md)
3. **Query format:** Follow [header format](docs/QUERY_ORGANIZATION.md#query-headers) with purpose, complexity, description

## Examples

### Example 1: Confirm PatientID Collection Membership

```sql
-- queries/general/confirm_patientid_single_collection.sql
-- Find patients that appear in multiple collections
SELECT
  dic_all.PatientID,
  COUNT(DISTINCT(dic_all.collection_id)) as count_collection_id_list,
  STRING_AGG(DISTINCT(dic_all.collection_id), ",") as collection_id_list
FROM `bigquery-public-data.idc_current.dicom_all` as dic_all
GROUP BY PatientID
HAVING count_collection_id_list > 1
```

**Cost:** Low ($0.05-0.10) | **Status:** ✅ Production

### Example 2: Segmentations with Anisotropic Spacing

```sql
-- queries/segmentations/segmentations_anisotropic_spacing.sql
-- Find SEG objects with non-square pixels
WITH uneq AS (
  SELECT collection_id, PatientID, SeriesInstanceUID
  FROM `bigquery-public-data.idc_current.dicom_all`
  WHERE Modality = "SEG" AND `Rows` <> `Columns`
)
-- [complex join and analysis...]
```

**Cost:** Medium ($0.15-0.30) | **Status:** ✅ Production

### Example 3: Parameterized Query (Pending)

```sql
-- queries/pending/slide_dcm_objects_by_id_param.sql
-- Get all DICOM objects for a specific slide
-- ⏳ PENDING: Requires <slide_id> parameter
SELECT gcs_url
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE ContainerIdentifier = "<slide_id>"
```

**Status:** ⏳ Pending Review | [Curation guide →](docs/PENDING_CURATION.md)

## Debugging & Support

**Query failing?**
1. Check [SETUP.md troubleshooting](docs/SETUP.md#troubleshooting)
2. Verify dataset references use `idc_current`
3. Check [syntax errors guide](docs/SETUP.md#query-parsing-error-during-dry-run)

**Cost concerns?**
1. Use dry run to estimate first: `bq query --dry_run < query.sql`
2. Review [complexity guide](docs/COMPLEXITY_GRADING.md)
3. Filter early with collection/modality constraints

**Want to add a query?**
1. Follow [CONTRIBUTING.md](docs/CONTRIBUTING.md)
2. Use provided header template
3. Run regression tests locally
4. Submit PR with stats

## License

Apache 2.0 - See [LICENSE](LICENSE)

## Citation

If you use these queries in research, please cite the IDC project:

> Fedorov, A., Longabaugh, W. J., & Pot, D. (2021). The Imaging Data Commons. Retrieved from https://imaging.datacommons.cancer.gov/

## Resources

- [IDC Documentation](https://imaging.datacommons.cancer.gov/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [DICOM Standard](https://dicom.nema.org/)
- [BigQuery Pricing](https://cloud.google.com/bigquery/pricing)