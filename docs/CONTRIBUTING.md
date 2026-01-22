# Contributing New Queries

Thank you for contributing to the IDC BigQuery Queries cookbook! This guide explains how to add new queries to the repository.

## Before You Start

1. **Review existing queries** - Check if a similar query already exists
2. **Understand the dataset** - Famiarize yourself with [IDC documentation](https://imaging.datacommons.cancer.gov/)
3. **Test your query** - Validate locally before submitting

## Creating a New Query

### 1. Choose a Category

Place your query in the appropriate category folder under `queries/`:

| Category | Use For |
|----------|---------|
| `general/` | Data validation, metadata exploration |
| `segmentations/` | DICOM Segmentation (SEG) analysis |
| `measurements/` | Quantitative/qualitative measurements |
| `slide_microscopy/` | Whole Slide Image analysis |
| `collection_specific/` | Collection-specific complex joins |
| `rtstruct/` | Radiotherapy structure queries |
| `annotations/` | Annotation availability |
| `pet/` | PET imaging queries |
| `image_series/` | Image series analysis |
| `lesions/` | Lesion/nodule queries |
| `pending/` | **Incomplete/parameterized queries** |

**If unsure, start in `pending/` for review.**

### 2. Use Query Template

Create file with `snake_case` naming:

```sql
-- Purpose: [Brief description - 1 sentence]
-- 
-- Complexity: Low|Medium|High
-- Estimated Cost: TBD | Bytes Scanned: TBD
-- 
-- Description:
-- [Detailed explanation of what query does]
-- [Methodology and approach]
-- [Why this analysis is useful]
-- [Any caveats or limitations]
-- 
-- Author/Source: [Your name or organization]

SELECT
  ...
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE ...
```

### 3. Dataset Requirements

✅ **Required:**
- Use `bigquery-public-data.idc_current.*` datasets (current version)
- Use only public datasets
- Include meaningful comments for complex logic

❌ **Avoid:**
- Private/internal datasets
- Outdated dataset versions (e.g., `idc_v9`)
- Hardcoded project IDs or credentials

### 4. Estimate Complexity

Analyze your query and assign complexity tier:

**Low Complexity:**
- Single table with filtering
- Example: `quantitative_measurement_types.sql`
- Estimated cost: < $0.10

**Medium Complexity:**
- Joins, basic unnesting, multi-step aggregations
- Example: `sr_tids_with_counts.sql`
- Estimated cost: $0.10-0.30

**High Complexity:**
- Multiple joins, deep unnesting
- Example: `rms_mutation_prediction_annotations_merge.sql`
- Estimated cost: > $0.30

[Learn more → Complexity Grading](./COMPLEXITY_GRADING.md)

### 5. Test Your Query

```bash
# Install dependencies
pip install -r requirements.txt

# Test with dry run first (free)
bq query --dry_run --use_legacy_sql=false < queries/category/your_query.sql

# Test with limit to prevent large result
python << 'EOF'
from google.cloud import bigquery

client = bigquery.Client()

# Load and test
with open("queries/category/your_query.sql") as f:
    query = f.read()

# Add LIMIT if needed
query_test = f"{query}\nLIMIT 1000"

# Dry run
job_config = bigquery.QueryJobConfig(dry_run=True)
job = client.query(query_test, job_config=job_config)
print(f"Dry run - Bytes: {job.total_bytes_processed}")

# Execute
job = client.query(query_test)
result = job.result()
print(f"Execution - Rows: {result.total_rows}")
print(f"Cost estimate: ${(job.total_bytes_processed / (1024**4)) * 6.25:.4f}")
EOF
```

## Query Standards

### Header Format

Every query must include this header:

```sql
-- Purpose: Clear, specific description of what query returns
-- 
-- Complexity: Low|Medium|High
-- Estimated Cost: $X.XX-Y.YY | Bytes Scanned: TBD
-- 
-- Description:
-- Paragraph explaining the query. What problem does it solve?
-- Include references to DICOM standards or documentation if relevant.
-- Note any assumptions, edge cases, or limitations.
-- 
-- Author/Source: [Your name]
```

### Naming Convention

- Use `snake_case` for all filenames
- Be descriptive but concise
- Examples:
  - ✅ `confirm_patientid_single_collection.sql`
  - ✅ `segmentations_anisotropic_spacing.sql`
  - ❌ `query1.sql`
  - ❌ `myQueryForSEG.sql`

### Code Style

```sql
-- ✅ Good: Clear, well-formatted, commented
SELECT
  PatientID,
  COUNT(DISTINCT SeriesInstanceUID) AS series_count
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  Modality = "SEG"
  AND access = "Public"
GROUP BY
  PatientID
ORDER BY
  series_count DESC

-- ❌ Poor: Minimal formatting, no comments
SELECT PatientID, COUNT(DISTINCT SeriesInstanceUID) FROM `bigquery-public-data.idc_current.dicom_all` WHERE Modality = "SEG" GROUP BY PatientID
```

### Best Practices

1. **Filter Early**
   ```sql
   -- ✅ Good: Filter before complex operations
   WHERE Modality = "SEG" AND collection_id = "lidc_idri"
   
   -- ❌ Poor: Apply filter after complex logic
   HAVING Modality = "SEG"
   ```

2. **Use CTEs for Readability**
   ```sql
   -- ✅ Good: Clear logic flow
   WITH segmentations AS (
     SELECT * FROM dicom_all WHERE Modality = "SEG"
   )
   SELECT * FROM segmentations WHERE access = "Public"
   ```

3. **Avoid SELECT ***
   ```sql
   -- ✅ Good: Explicit columns
   SELECT PatientID, SeriesInstanceUID, SOPInstanceUID
   
   -- ❌ Poor: Unpredictable columns
   SELECT * FROM dicom_all
   ```

4. **Add Comments for Complex Logic**
   ```sql
   -- Use SAFE_OFFSET to handle potential null sequences
   SELECT SegmentedPropertyType.AnatomicRegionModifierSequence[SAFE_OFFSET(0)].CodeMeaning
   ```

## Submission Process

### 1. Create Feature Branch

```bash
git checkout -b query/descriptive-query-name
```

### 2. Add Your Query

```bash
# Add to appropriate category
cp your_query.sql queries/category/your_query.sql

# Or if incomplete:
cp your_query.sql queries/pending/your_query.sql
```

### 3. Test with Regression Suite

```bash
python tests/run_regression_tests.py --query-dir queries
```

### 4. Commit

```bash
git add queries/category/your_query.sql
git commit -m "Add your_query.sql for [category]

- Purpose: [What does it do]
- Complexity: [Low|Medium|High]
- Dataset: [tables used]
- Estimated cost: $X.XX
"
```

### 5. Push and Create PR

```bash
git push origin query/descriptive-query-name
```

On GitHub: Create Pull Request with:
- **Title**: `Add: your_query.sql (category)`
- **Description**: 
  - Purpose of query
  - Why it's useful
  - Any dependencies or requirements

## Review Criteria

Your PR will be reviewed for:

- ✅ **Correctness** - Query produces expected results
- ✅ **Dataset** - Uses `idc_current` public datasets
- ✅ **Documentation** - Clear header with complexity
- ✅ **Performance** - Reasonable cost for use case
- ✅ **Style** - Follows naming and format conventions
- ✅ **Testing** - Passes regression tests or pending curation

## Special Cases

### Parameterized Queries

If your query needs parameters (e.g., `<slide_id>`):

1. Put in `queries/pending/`
2. Document parameter format in header
3. Provide examples of parameter values
4. Will be promoted to production after curation

Example:
```sql
-- Parameters:
--   <slide_id>: ContainerIdentifier from slide_distinct_container_identifiers
--   Example: C3N-03928-22
```

### Template Queries

If your query is a template with customizable parts:

1. Put in `queries/pending/`
2. Document all placeholders
3. Provide multiple usage examples
4. Create documentation file
5. Will be promoted after examples added

### Collection-Specific Queries

For queries specific to one or two collections:

```sql
-- Note: LIDC-specific query
-- This query works with LIDC collection nodules...
```

## Examples

### Example: Simple Low-Complexity Query

```sql
-- Purpose: Get all distinct DICOM modalities in a collection
-- 
-- Complexity: Low
-- Estimated Cost: $0.05 | Bytes Scanned: TBD
-- 
-- Description:
-- Lists all unique DICOM modalities in the specified collection.
-- Useful for understanding what imaging types are available.
-- 
-- Author/Source: User submission

SELECT
  DISTINCT Modality
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  collection_id = "tcga_luad"
ORDER BY
  Modality
```

### Example: Medium-Complexity Query with CTE

```sql
-- Purpose: Count instances per modality per collection
-- 
-- Complexity: Medium
-- Estimated Cost: $0.15 | Bytes Scanned: TBD
-- 
-- Description:
-- Provides a summary of how many DICOM instances exist for each modality
-- in each collection. Useful for data inventory and collection overview.
-- 
-- Author/Source: User submission

WITH modality_counts AS (
  SELECT
    collection_id,
    Modality,
    COUNT(*) as instance_count
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  GROUP BY
    collection_id,
    Modality
)
SELECT
  *
FROM
  modality_counts
ORDER BY
  collection_id,
  instance_count DESC
```

## Need Help?

- **Questions?** Open an issue on GitHub
- **Dataset help?** Check [IDC documentation](https://imaging.datacommons.cancer.gov/)
- **BigQuery help?** See [BigQuery docs](https://cloud.google.com/bigquery/docs)
- **Setup issues?** See [SETUP.md](./SETUP.md)

## Acknowledgments

Thank you for contributing to the IDC community! Your queries help researchers and developers explore medical imaging data more effectively.
