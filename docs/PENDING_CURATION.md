# Pending Query Curation Guide

This guide explains how to curate queries in the `queries/pending/` folder for promotion to production.

## Curation Process Overview

Pending queries fall into several categories, each with specific curation steps:

1. **Parameterized Queries** - Need parameter documentation and sample values
2. **Template Queries** - Need usage examples and placeholder documentation
3. **Incomplete/TODO Queries** - Need implementation or clarification
4. **Problem Queries** - Need fixes for syntax/data quality issues

## Category-Specific Curation

### 1. Parameterized Queries

**Files:** 
- `slide_dcm_objects_by_id_param.sql`
- `slide_dcm_width_height_by_url_param.sql`
- `slide_pixel_size_by_url_param.sql`
- `slides_by_project_id_param.sql`

**Curation Steps:**

1. **Identify parameter sources**
   ```sql
   -- Original: WHERE ContainerIdentifier = "<slide_id>"
   -- Source: Output from slide_distinct_container_identifiers.sql
   ```

2. **Document parameters in header**
   ```sql
   -- Parameters:
   --   <slide_id>: ContainerIdentifier from slide_distinct_container_identifiers
   --   Example: C3N-03928-22
   ```

3. **Create test with sample data**
   ```python
   # Find sample parameter value
   client = bigquery.Client()
   sample = client.query("""
     SELECT DISTINCT ContainerIdentifier
     FROM `bigquery-public-data.idc_current.dicom_all`
     WHERE Modality = "SM"
     LIMIT 1
   """).result()
   sample_slide_id = list(sample)[0][0]
   
   # Test query with sample
   result = client.query(f"""
     SELECT gcs_url
     FROM `bigquery-public-data.idc_current.dicom_all`
     WHERE ContainerIdentifier = "{sample_slide_id}"
     LIMIT 1000
   """).result()
   ```

4. **Add to header**
   ```sql
   -- Status: PENDING REVIEW
   -- Action: Add parameter documentation and sample values
   -- After: Move to queries/slide_microscopy/ after testing
   ```

5. **Move to production**
   ```bash
   mv queries/pending/slide_dcm_objects_by_id_param.sql \
      queries/slide_microscopy/slide_dcm_objects_by_id.sql
   
   # Remove <slide_id> placeholder, replace with parameter doc
   # Commit: "Promote slide_dcm_objects_by_id.sql to production"
   ```

### 2. Template Queries

**Files:**
- `wsi_information_simplified_template.sql`

**Curation Steps:**

1. **Identify template placeholders**
   - `<columns from slide images view>` - Column selection
   - `<condition>` - WHERE clause filtering

2. **Create example variations**
   ```sql
   -- Example 1: Get all slide images for HTAN dataset
   SELECT
     slide_id,
     patient_id,
     dataset,
     width,
     height,
     pixel_spacing
   FROM slide_images
   WHERE dataset = "htan"
   
   -- Example 2: Filter by pixel spacing range
   SELECT * FROM slide_images
   WHERE pixel_spacing BETWEEN 0.25 AND 0.5
     AND compression = 'jpeg2000'
   ```

3. **Create documentation file**
   ```markdown
   # WSI Information Simplified Template
   
   Template for accessing Whole Slide Image metadata with flexible columns and filters.
   
   ## Usage
   
   Customize by providing:
   - `<columns from slide images view>`: Select desired columns
   - `<condition>`: Add WHERE clause filters
   
   ## Examples
   ...
   ```

4. **Update query header**
   ```sql
   -- Purpose: Simplified access to WSI information (template with examples)
   -- Status: ACTIVE - Examples documented in docs/slide_microscopy.md
   ```

5. **Move with documentation**
   ```bash
   mv queries/pending/wsi_information_simplified_template.sql \
      queries/slide_microscopy/wsi_information_template.sql
   
   # Commit: "Promote wsi_information_template.sql with usage examples"
   ```

### 3. Incomplete/TODO Queries

**Files:**
- `TODO_codesequence_tuples_as_strings.sql`
- `quantitative_qualitative_pivot_validation_pending.sql`
- `htan_channels_exploration_needs_curation.sql`

**Curation Steps:**

1. **For TODO_codesequence_tuples_as_strings.sql**
   - Research DICOM code sequence representation
   - Design approach for extracting CodeSequence as strings
   - Implement query or document why it's not feasible
   - If feasible: test and promote; if not: document limitation

2. **For quantitative_qualitative_pivot_validation_pending.sql**
   - Add verification logic from TODO
   - Create test instances to validate results
   - Compare pivoted results against raw data
   - Document validation approach in query

3. **For htan_channels_exploration_needs_curation.sql**
   - Review struck-through code blocks
   - Determine optimal approach among alternatives
   - Consolidate into single query
   - Document trade-offs of alternatives

4. **Testing & promotion**
   ```bash
   # Test consolidated query
   python tests/run_regression_tests.py --query-dir queries
   
   # If passes: Move to production
   mv queries/pending/query_name.sql queries/category/query_name.sql
   ```

### 4. Problem Queries

**Files:**
- `rtstruct_roi_instances_db_mismatch.sql`

**Curation Steps:**

1. **Identify the problem**
   ```sql
   -- Original uses: `canceridc-data.idc_views.dicom_all`
   -- Standard uses: `bigquery-public-data.idc_current.dicom_all`
   ```

2. **Fix and test**
   ```python
   # Test both approaches to find correct dataset
   
   # Approach 1: Standard dataset
   result1 = client.query("""
     SELECT COUNT(*) FROM `bigquery-public-data.idc_current.dicom_all`
     WHERE Modality = "RTSTRUCT"
   """).result()
   
   # Verify results make sense
   ```

3. **Update query with correction**
   ```sql
   -- Note: Original query used non-standard dataset reference
   -- Updated to use: `bigquery-public-data.idc_current.dicom_all`
   ```

4. **Document the fix**
   ```bash
   git commit -m "Fix database reference in rtstruct_roi_instances.sql"
   ```

## Promotion Workflow

### Step 1: Local Testing

```bash
# Ensure all dependencies installed
pip install -r requirements.txt

# Run regression tests
python tests/run_regression_tests.py --query-dir queries

# Verify the query passes or has only expected issues
cat tests/QUERY_TEST_RESULTS.md | grep "query_name"
```

### Step 2: Update Query File

Remove "PENDING REVIEW" status and update header:

```sql
-- Before:
-- Status: PENDING REVIEW
-- Reason: Parameterized query - requires <slide_id> parameter substitution

-- After:
-- Status: PRODUCTION
-- Parameters:
--   slide_id: ContainerIdentifier (e.g., C3N-03928-22)
--   Source: slide_distinct_container_identifiers.sql
```

### Step 3: Move File

```bash
# Move to appropriate production category
mv queries/pending/query_name.sql queries/category/query_name.sql

# Example for parameterized SM query
mv queries/pending/slide_dcm_objects_by_id_param.sql \
   queries/slide_microscopy/slide_dcm_objects_by_id.sql
```

### Step 4: Update Pending Notes

Edit `queries/pending/_PENDING_NOTES.md` to remove the promoted query from the table.

### Step 5: Commit

```bash
git add queries/pending/_PENDING_NOTES.md
git add queries/category/query_name.sql
git rm queries/pending/old_query_name.sql

git commit -m "Promote query_name to production after curation

- Type: [parameterized|template|todo|fix]
- Changes: [specific changes made]
- Testing: [regression tests pass|manual testing completed]
"
```

## Curation Timeline

- **Initial**: Query identified as pending
- **In Progress**: Curator assigned, working on issues
- **Ready**: All issues fixed, local tests pass
- **Promoted**: Moved to production, documented in PR
- **Complete**: Merged to main, available for all users

## Examples

### Example: Promote Parameterized Query

```bash
# 1. Test locally
python tests/run_regression_tests.py --query-dir queries

# 2. Update query file header to add parameter docs
vi queries/pending/slide_dcm_objects_by_id_param.sql

# 3. Move to production
mv queries/pending/slide_dcm_objects_by_id_param.sql \
   queries/slide_microscopy/slide_dcm_objects_by_id.sql

# 4. Update pending notes
vi queries/pending/_PENDING_NOTES.md
# Remove from table

# 5. Commit
git add queries/pending/_PENDING_NOTES.md
git add queries/slide_microscopy/slide_dcm_objects_by_id.sql
git commit -m "Promote slide_dcm_objects_by_id.sql to production

- Type: parameterized query
- Changes: Added parameter documentation and examples
- Testing: Regression tests pass with sample parameters
"
git push
```

## Resources

- [Query Organization](./QUERY_ORGANIZATION.md) - Category structure
- [Complexity Grading](./COMPLEXITY_GRADING.md) - How to analyze query cost
- [Setup Guide](./SETUP.md) - Testing and debugging queries
- [IDC Documentation](https://imaging.datacommons.cancer.gov/) - Dataset reference
