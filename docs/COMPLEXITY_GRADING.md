# Complexity Grading System

Queries are classified into three tiers based on estimated computational cost and complexity.

## Grading Criteria

### Low Complexity (Tier 1)
- **Scope**: Single table or minimal joins
- **Operations**: Basic filtering, simple aggregations
- **Data Access**: Column selection, WHERE filtering
- **Estimated Cost**: < $0.10
- **Execution Time**: < 10 seconds typically

**Characteristics:**
- No CROSS JOIN or UNNEST operations
- Single GROUP BY at most
- No recursive or window functions
- Straightforward schema access

**Examples:**
- `slide_distinct_container_identifiers.sql` - Simple distinct on Modality filter
- `quantitative_measurement_types.sql` - Single table, distinct aggregation
- `volume_measurements.sql` - Single table with basic WHERE

### Medium Complexity (Tier 2)
- **Scope**: Multiple tables or complex filtering
- **Operations**: Joins, basic unnesting, multi-step aggregations
- **Data Access**: Nested field access, controlled unnesting
- **Estimated Cost**: $0.10 - $0.30
- **Execution Time**: 10-60 seconds typically

**Characteristics:**
- One or two JOIN operations
- Single-level UNNEST or limited nesting
- Multiple aggregation steps or window functions
- Moderate table scans

**Examples:**
- `check_uid_reuse_across_hierarchy.sql` - UNION with multiple scans, aggregation
- `sr_tids_with_counts.sql` - UNNEST + aggregation
- `series_imagepositionpatient_counts.sql` - GROUP BY with derived columns

### High Complexity (Tier 3)
- **Scope**: Multiple complex joins or full table scans
- **Operations**: Deep unnesting, complex window functions, analytical operations
- **Data Access**: Nested sequence navigation, complex schema traversal
- **Estimated Cost**: > $0.30
- **Execution Time**: 60+ seconds or unbounded

**Characteristics:**
- Multiple JOIN operations (3+)
- Nested CROSS JOIN and UNNEST operations
- Complex recursive or multi-level window functions
- Full table scans without effective filtering
- Produces large result sets

**Examples:**
- `images_multiple_slices_per_position.sql` - Multiple CTEs with nested operations
- `rms_mutation_prediction_annotations_merge.sql` - 4+ table joins with clinical data
- `slide_processing_step_combinations.sql` - Nested CROSS JOIN with deep unnesting

## Cost Estimation Formula

```
Estimated Cost (USD) = (Bytes Scanned in GB / 1024) × $6.25 per TB
```

**Examples:**
- 10 GB scanned = (10/1024) × $6.25 = $0.061
- 100 GB scanned = (100/1024) × $6.25 = $0.610
- 1 TB scanned = 1 × $6.25 = $6.25

## Optimization Principles

### Reducing Complexity

1. **Filter Early**
   ```sql
   -- ❌ Inefficient: Full scan then filter
   SELECT * FROM dicom_all 
   WHERE Modality = "SEG"
   
   -- ✅ Better: Filter at source
   SELECT * FROM dicom_all 
   WHERE Modality = "SEG" AND collection_id = "lidc_idri"
   ```

2. **Avoid Full Table Scans**
   ```sql
   -- ❌ Inefficient: Scans entire table
   SELECT COUNT(*) FROM dicom_all
   
   -- ✅ Better: Known partition column
   SELECT COUNT(*) FROM dicom_all 
   WHERE collection_id = "lidc_idri"
   ```

3. **Limit Unnesting**
   ```sql
   -- ❌ Inefficient: Unnest then filter
   SELECT * FROM dicom_all 
   CROSS JOIN UNNEST(SegmentSequence) AS seg
   
   -- ✅ Better: Filter before unnest if possible
   SELECT * FROM dicom_all 
   WHERE Modality = "SEG"
   CROSS JOIN UNNEST(SegmentSequence) AS seg
   ```

4. **Use Subqueries Strategically**
   ```sql
   -- ❌ Inefficient: Multiple passes
   SELECT s1.* FROM series s1
   JOIN (SELECT * FROM dicom_all WHERE status = 'valid') d1
   ...
   
   -- ✅ Better: Single pass with CTE
   WITH valid_data AS (
     SELECT * FROM dicom_all WHERE status = 'valid'
   )
   SELECT s1.* FROM series s1
   JOIN valid_data d1 ...
   ```

## Complexity-Based Selection Guide

### Choose Low Complexity Queries For:
- Ad-hoc exploratory analysis
- Frequent monitoring/dashboards
- Resource-constrained environments
- Time-sensitive queries

### Choose Medium Complexity For:
- Regular analysis with moderate data scope
- Data quality validation
- Collection-level analysis
- Reporting workflows

### Choose High Complexity For:
- One-time comprehensive analysis
- Research studies requiring full dataset
- Complex correlations across tables
- Clinical outcome analysis with full context

## Performance Considerations

### Dry Run vs. Execution
- **Dry run**: Free, returns estimated bytes
- **Full execution**: Charged per bytes scanned

Always use dry run first to estimate cost:
```bash
bq query --dry_run < query.sql
```

### Caching
- Results cached for 24 hours if data unchanged
- Cached queries don't incur charges
- Use same exact query text to hit cache

### Slots and On-Demand
- **On-demand**: $6.25/TB (default)
- **Slots**: Fixed monthly cost, better for predictable workloads
- For frequent high-complexity queries, consider slots

## Query Header Format

Every query header includes complexity classification:

```sql
-- Complexity: Medium
-- Estimated Cost: $0.15-0.30 | Bytes Scanned: TBD
```

Stats are automatically updated from regression tests when actual execution differs by >10% from estimate.

## Regression Test Cost Estimation

During CI/CD testing, queries execute with `LIMIT 1000` to constrain result size. Actual production costs may differ:

```
Test cost ≤ Actual cost (because of LIMIT)
```

Review full-execution costs for queries before using in production.

## Examples by Complexity

### Low Complexity Example
```sql
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
SELECT DISTINCT(Modality)
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE collection_id = "tcga_luad"
```

### Medium Complexity Example
```sql
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
WITH modality_count AS (
  SELECT
    Modality,
    COUNT(*) as count
  FROM `bigquery-public-data.idc_current.dicom_all`
  WHERE collection_id = "tcga_luad"
  GROUP BY Modality
)
SELECT * FROM modality_count
WHERE count > 100
```

### High Complexity Example
```sql
-- Complexity: High
-- Estimated Cost: $0.30+ | Bytes Scanned: TBD
WITH annotations AS (
  SELECT PatientID, StudyInstanceUID, series_id
  FROM `bigquery-public-data.idc_current.dicom_all` d
  CROSS JOIN UNNEST(ContentSequence) c
  WHERE Modality = "SR"
)
SELECT a.*, c.*, d.*
FROM annotations a
JOIN `bigquery-public-data.idc_current_clinical.tcga_data` c ON a.PatientID = c.patient_id
JOIN segmentations d ON a.series_id = d.series_id
```
