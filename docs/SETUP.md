# SETUP: BigQuery Access and Local Testing

## Prerequisites

- Python 3.8+
- Google Cloud Project with BigQuery enabled
- Access to `bigquery-public-data` (public datasets)

## Authentication

### Option 1: Using Service Account (Recommended for CI/CD)

1. Create a service account in your GCP project:
   ```bash
   gcloud iam service-accounts create idc-queries-test \
     --display-name="IDC Queries Testing"
   ```

2. Grant BigQuery read permissions:
   ```bash
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:idc-queries-test@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/bigquery.dataViewer"
   ```

3. Create and download a key:
   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=idc-queries-test@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

4. Set environment variable:
   ```bash
   export GCP_SA_KEY=/path/to/key.json
   ```

### Option 2: Using Application Default Credentials

```bash
gcloud auth application-default login
```

## Local Testing

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

Or manually:
```bash
pip install google-cloud-bigquery google-auth pyyaml
```

### 2. Run Full Test Suite

```bash
# Run all regression tests
python tests/run_regression_tests.py \
  --query-dir queries \
  --output tests/QUERY_TEST_RESULTS.md \
  --json-output tests/query_test_results.json \
  --credentials $GCP_SA_KEY
```

### 3. Update Query Headers with Actual Stats

```bash
python tests/update_query_headers.py \
  --results tests/query_test_results.json \
  --threshold 0.10 \
  --query-dir queries
```

This will update query headers with real execution statistics from BigQuery, but only if the new values differ by more than 10% from the existing estimates.

### 4. Test Individual Queries

```bash
# Manually test a specific query in Python
python << 'EOF'
from google.cloud import bigquery
from pathlib import Path

client = bigquery.Client()

# Load a query
query_file = Path("queries/general/confirm_patientid_single_collection.sql")
with open(query_file) as f:
    query = f.read()

# Add LIMIT for testing
query_with_limit = query + "\nLIMIT 1000"

# Run dry run first
job_config = bigquery.QueryJobConfig(dry_run=True)
job = client.query(query_with_limit, job_config=job_config)
print(f"Dry run - Bytes scanned: {job.total_bytes_processed}")

# Run actual query
job = client.query(query_with_limit)
result = job.result()
print(f"Execution - Rows: {result.total_rows}")
print(f"Estimated cost: ${(job.total_bytes_processed / (1024**4)) * 6.25:.4f}")

EOF
```

## Testing Parameterized Queries

Parameterized queries in the `queries/pending/` folder require manual testing with actual parameter values. Example:

```sql
-- queries/pending/slide_dcm_objects_by_id_param.sql
SELECT gcs_url
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE ContainerIdentifier = "<slide_id>"
```

To test, replace `<slide_id>` with an actual value:

```python
# Get an actual slide ID first
from google.cloud import bigquery

client = bigquery.Client()
query = """
SELECT DISTINCT ContainerIdentifier
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE Modality = "SM"
LIMIT 1
"""
result = client.query(query).result()
slide_id = list(result)[0][0]
print(f"Sample slide ID: {slide_id}")

# Now test the parameterized query
query_with_param = f"""
SELECT gcs_url
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE ContainerIdentifier = "{slide_id}"
LIMIT 1000
"""
result = client.query(query_with_param).result()
print(f"Retrieved {result.total_rows} objects for slide {slide_id}")
```

## Cost Management

### Understanding BigQuery Pricing

- **Standard SQL**: $6.25 per TB scanned
- **Dry run**: Free (estimates data scanned without executing)
- **Cache hits**: Free (if query results cached and data unchanged)

### Monitoring Costs

Each test result includes estimated cost in USD:
```
Estimated Cost: $0.0625  (= 10 GB scanned * $6.25/TB)
```

Total cost for a test run = sum of all individual query costs

### Controlling Test Costs

1. **LIMIT clauses**: Tests append `LIMIT 1000` to limit result size
2. **Dry run first**: Syntax validation without execution cost
3. **Cache**: BigQuery caches results for 24 hours
4. **Sampling**: Filter queries to specific collections for faster testing

## Troubleshooting

### "ERROR: Failed to authenticate with credentials"

```bash
# Verify credentials file
cat $GCP_SA_KEY

# Verify project ID
export GOOGLE_CLOUD_PROJECT=$(jq -r '.project_id' $GCP_SA_KEY)
echo $GOOGLE_CLOUD_PROJECT

# Test authentication
python -c "from google.cloud import bigquery; print(bigquery.Client().project)"
```

### "Query parsing error" during dry run

The query has syntax errors. Check:
1. DICOM table references: should be `bigquery-public-data.idc_current.dicom_all`
2. Array/struct access: use `[OFFSET(0)]` not `[0]`
3. SAFE casting: use `SAFE_CAST` for type conversions

### "No rows returned" for a query

Some queries may legitimately return no results if:
- Filtering on rare attributes
- Collection-specific data not present
- Parameterized queries without values

Check if query is in `queries/pending/` folder - these require manual curation and parameter substitution.

### BigQuery quota or rate limit exceeded

- Retry after a few minutes
- Spread tests across time if running frequently
- Contact GCP support to increase quotas

## CI/CD Integration

The GitHub Actions workflow automatically:

1. **On PR**: Runs full test suite, posts results comment
2. **On push to main**: Runs tests, updates headers, commits stats
3. **Failures**: Stops build if production queries fail
4. **Artifacts**: Stores test results for 30 days

Configure GitHub secrets:
```
Settings → Secrets → New repository secret
Name: GCP_SA_KEY
Value: (paste contents of service account JSON)
```

## Next Steps

- Add new queries to appropriate category folder
- Run tests locally before pushing
- Review query stats and complexity analysis
- Promote queries from `queries/pending/` after curation
