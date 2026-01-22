# Development Guide: IDC BigQuery Queries Repository

This document outlines the technical approach, organization, conventions, and architecture decisions for the IDC BigQuery Queries repository. It serves as a reference for future development and maintenance.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Directory Structure](#directory-structure)
3. [File Naming Conventions](#file-naming-conventions)
4. [Query Standards](#query-standards)
5. [Testing Infrastructure](#testing-infrastructure)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Complexity Grading System](#complexity-grading-system)
8. [Pending Queue Management](#pending-queue-management)
9. [Future Development Guidelines](#future-development-guidelines)

---

## Architecture Overview

### Design Principles

1. **Separation of Concerns**
   - Queries: Pure SQL files with metadata headers
   - Tests: Python scripts for validation and execution
   - Documentation: Comprehensive markdown guides
   - CI/CD: GitHub Actions for automation

2. **Standardization**
   - All queries use `bigquery-public-data.idc_current.*` datasets
   - Consistent header format across all queries
   - `snake_case` naming for all files
   - Three-tier complexity grading (Low/Medium/High)

3. **Testability**
   - Dry run validation (syntax check, free)
   - Execution with LIMIT clause (prevents excessive costs)
   - Non-blocking error handling (all tests complete)
   - Automatic stat tracking with variance threshold

4. **Maintainability**
   - Self-documenting headers in each query
   - Tracked test results in markdown table
   - Pending queue for queries requiring curation
   - Comprehensive documentation for all processes

### Repository Goals

- **Discoverability**: Easy to find queries by category and purpose
- **Reliability**: Automated testing ensures queries execute successfully
- **Cost Awareness**: Complexity grading and cost estimates prevent surprises
- **Community**: Clear contribution guidelines and curation processes

---

## Directory Structure

### Core Organization

```
idc-queries/
├── queries/                      # SQL query files organized by category
│   ├── {category}/              # Category folders (snake_case)
│   │   └── {query_name}.sql     # Individual query files (snake_case)
│   └── pending/                 # Queries requiring manual curation
│       ├── {query_name}.sql     # Pending query files
│       └── _PENDING_NOTES.md    # Curation tracking document
│
├── tests/                        # Testing infrastructure
│   ├── run_regression_tests.py  # Main test runner
│   ├── update_query_headers.py  # Stat update script
│   ├── init_test_results.py     # Initialize results table
│   ├── test_config.yaml         # Test configuration
│   └── QUERY_TEST_RESULTS.md    # Tracked results (generated)
│
├── docs/                         # User-facing documentation
│   ├── SETUP.md                 # Authentication and local testing
│   ├── QUERY_ORGANIZATION.md    # Directory guide
│   ├── COMPLEXITY_GRADING.md    # Complexity system explained
│   ├── PENDING_CURATION.md      # Curation process
│   └── CONTRIBUTING.md          # Contribution guidelines
│
├── dev/                          # Developer documentation (this file)
│   └── DEVELOPMENT_GUIDE.md     # Technical reference
│
├── .github/workflows/            # GitHub Actions workflows
│   └── regression_tests.yml     # CI/CD pipeline
│
├── README.md                     # Project overview
├── requirements.txt              # Python dependencies
├── LICENSE                       # Apache 2.0
└── .gitignore                    # Standard ignores
```

### Category Taxonomy

Categories are chosen based on DICOM data type and analysis purpose:

| Category | Criteria | Example Queries |
|----------|----------|-----------------|
| `general/` | Cross-cutting utilities, data validation | UID reuse detection |
| `segmentations/` | DICOM SEG modality, SegmentSequence analysis | Anisotropic spacing |
| `measurements/` | Quant/qual measurements, SR templates | Volume measurements |
| `slide_microscopy/` | SM modality, WSI-specific attributes | Processing steps |
| `image_series/` | Series-level analysis, ImagePositionPatient | 4D image detection |
| `rtstruct/` | RTSTRUCT modality, ROI analysis | ROI name enumeration |
| `pet/` | PET modality, SUV calculations | Decay correction |
| `annotations/` | Annotation availability, modality inventory | SEG/RTSTRUCT presence |
| `collection_specific/` | Collection-specific joins | RMS Mutation Prediction |
| `lesions/` | Lesion/nodule identification | LIDC nodule clustering |
| `series_analysis/` | Frame-level series characteristics | FrameOfReferenceUID |
| `transfer_syntax/` | Encoding and compression | Transfer syntax samples |
| `private_tags/` | Private DICOM tag extraction | GE b-value extraction |

**Rule**: If a query doesn't fit existing categories, place in `pending/` until category is determined.

---

## File Naming Conventions

### Query Files

**Format**: `{verb}_{noun}_{modifier}.sql`

**Rules**:
1. Use `snake_case` (lowercase with underscores)
2. Be descriptive but concise (< 50 characters preferred)
3. Use action verbs: `select`, `get`, `count`, `list`, `find`
4. Include key attributes: modality, data type, condition

**Examples**:
```
✅ confirm_patientid_single_collection.sql
✅ segmentations_anisotropic_spacing.sql
✅ count_segments_per_patient.sql
✅ slide_processing_step_combinations.sql

❌ query1.sql                              (not descriptive)
❌ getSegmentations.sql                    (camelCase)
❌ SEG-queries.sql                         (hyphens)
❌ very_long_name_that_describes_every_single_detail.sql  (too verbose)
```

### Python Scripts

**Format**: `{verb}_{noun}.py`

**Examples**:
```
run_regression_tests.py
update_query_headers.py
init_test_results.py
```

### Documentation Files

**Format**: `{TOPIC}.md` (SCREAMING_SNAKE_CASE for main docs)

**Examples**:
```
SETUP.md
QUERY_ORGANIZATION.md
COMPLEXITY_GRADING.md
CONTRIBUTING.md
_PENDING_NOTES.md          (special: underscore prefix for internal docs)
```

---

## Query Standards

### Header Format (Mandatory)

Every production query must include this exact header structure:

```sql
-- Purpose: [One-sentence description of what the query returns]
-- 
-- Complexity: Low|Medium|High
-- Estimated Cost: $X.XX-Y.YY | Bytes Scanned: TBD
-- 
-- Description:
-- [Paragraph 1: What problem does this query solve?]
-- [Paragraph 2: Methodology and approach used]
-- [Paragraph 3: Output format and interpretation]
-- [Paragraph 4 (optional): Caveats, limitations, edge cases]
-- 
-- [Optional: Reference links to DICOM standards, papers, etc.]
-- Author/Source: [Author name or "IDC Cookbook"]

SELECT ...
```

### Header Components Explained

| Component | Purpose | Rules |
|-----------|---------|-------|
| `Purpose` | Brief description | One sentence, < 80 chars |
| `Complexity` | Tier classification | Low/Medium/High only |
| `Estimated Cost` | Cost range | Format: `$0.XX-Y.YY`, updated by tests |
| `Bytes Scanned` | Data scanned | Initially `TBD`, updated by tests |
| `Description` | Detailed explanation | Multi-paragraph, comprehensive |
| `References` | External links | DICOM specs, papers, docs |
| `Author/Source` | Attribution | Person, org, or "IDC Cookbook" |

### SQL Style Guide

**DO:**
```sql
-- Use uppercase for SQL keywords
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
```

**DON'T:**
```sql
-- Avoid single-line formatting and lowercase keywords
select PatientID, count(distinct SeriesInstanceUID) from `bigquery-public-data.idc_current.dicom_all` where Modality = "SEG" group by PatientID
```

**Best Practices**:
1. One clause per line for readability
2. Indent consistently (2 spaces)
3. Use CTEs for complex logic
4. Add inline comments for non-obvious operations
5. Use `SAFE_OFFSET()` for array access
6. Use `SAFE_CAST()` for type conversions
7. Filter early (WHERE before JOIN when possible)

### Dataset References

**Standard Format**:
```sql
`bigquery-public-data.idc_current.{table_name}`
```

**Available Tables**:
- `dicom_all` - Main DICOM metadata
- `segmentations` - Segmentation-specific data
- `quantitative_measurements` - Numeric measurements
- `qualitative_measurements` - Categorical measurements
- `dicom_metadata_curated_series_level` - Series-level metadata
- `idc_current_clinical.*` - Clinical data tables (collection-specific)

**NEVER USE**:
- `idc_v9`, `idc_v10` - Outdated versions
- `idc-dev-etl.*` - Development datasets
- `canceridc-data.*` - Non-standard references

---

## Testing Infrastructure

### Test Architecture

```
┌─────────────────────────────────────────────────────────┐
│ run_regression_tests.py                                 │
├─────────────────────────────────────────────────────────┤
│ 1. Load queries from queries/                           │
│ 2. For each query:                                      │
│    ├─ Dry run (syntax check, estimate bytes)           │
│    ├─ If dry run fails: Log error, skip execution      │
│    ├─ If pending: Skip execution, mark "Pending Review"│
│    └─ Else: Execute with LIMIT, capture stats          │
│ 3. Generate markdown summary table                      │
│ 4. Write to tests/QUERY_TEST_RESULTS.md                │
│ 5. Write JSON to tests/query_test_results.json         │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│ update_query_headers.py                                 │
├─────────────────────────────────────────────────────────┤
│ 1. Load results from JSON                               │
│ 2. For each passing query:                              │
│    ├─ Parse existing header stats                       │
│    ├─ Calculate variance from new stats                 │
│    ├─ If variance > 10%: Update header                  │
│    └─ Else: Skip (no update needed)                     │
│ 3. Write updated files back to disk                     │
└─────────────────────────────────────────────────────────┘
```

### Test Runner (`run_regression_tests.py`)

**Key Classes**:
- `QueryTestRunner`: Main orchestrator
  - `load_queries()`: Discover .sql files
  - `run_dry_run()`: Validate syntax, estimate cost
  - `run_query_with_limit()`: Execute with LIMIT appended
  - `test_query()`: Full test cycle
  - `generate_markdown_report()`: Create summary table

**Test Flow**:
1. **Discovery**: Recursively find all `.sql` files
2. **Classification**: Identify pending vs. production
3. **Dry Run**: Syntax validation (free, no execution)
4. **Execution**: Run with `LIMIT 1000` (production only)
5. **Validation**: Check non-empty results
6. **Stats**: Capture bytes scanned, cost, execution time
7. **Reporting**: Generate markdown + JSON

**Error Handling**:
- Non-blocking: Errors logged, testing continues
- Categorized: Syntax vs. execution vs. empty results
- Detailed: Error messages truncated but preserved

### Header Updater (`update_query_headers.py`)

**Key Classes**:
- `QueryHeaderUpdater`: Stat update manager
  - `parse_header_stats()`: Extract current values
  - `exceeds_variance_threshold()`: Check if update needed
  - `update_query_file()`: Replace header line
  - `batch_update()`: Process all queries

**Variance Calculation**:
```python
variance = abs(new_value - old_value) / old_value
update_needed = variance > 0.10  # 10% threshold
```

**Update Logic**:
1. Parse existing `Estimated Cost: $X.XX | Bytes Scanned: Y.YY` line
2. Calculate new cost from bytes scanned
3. Compare: `variance = |new - old| / old`
4. If `variance > 10%`: Replace line in file
5. Else: Skip (preserves manual edits < 10% drift)

**Header Line Format**:
```sql
-- Estimated Cost: $0.1234 | Bytes Scanned: 123.45GB | Complexity: Medium
```

### Test Configuration (`test_config.yaml`)

**Parameters**:
```yaml
test_parameters:
  limit_for_tests: 1000                  # LIMIT clause for execution
  stat_update_variance_threshold: 0.10   # 10% variance threshold
  query_timeout_seconds: 300             # Query timeout

ci_integration:
  fail_on_production_error: true         # CI fails if production queries fail
  fail_on_pending_syntax_error: false    # CI doesn't fail on pending errors
  post_pr_comment: true                  # Post results to PR
  auto_commit_stats: true                # Auto-commit stat updates
```

---

## CI/CD Pipeline

### GitHub Actions Workflow (`regression_tests.yml`)

**Triggers**:
- `pull_request` to `main` or `develop`
- `push` to `main` or `develop`

**Workflow Steps**:

1. **Setup** (5 steps)
   - Checkout repository
   - Setup Python 3.11
   - Install dependencies
   - Authenticate with GCP (via `GCP_SA_KEY` secret)
   - Export key file path

2. **Test Execution** (4 steps)
   - Initialize test results file
   - Run regression tests (all queries)
   - Update query headers (if > 10% variance)
   - Generate PR comment summary

3. **Reporting** (2 steps)
   - Post PR comment with full stats table
   - Upload artifacts (results.md, results.json)

4. **Finalization** (2 steps)
   - Commit stat updates (push to main only)
   - Check for failures (exit code 1 if production queries failed)

**Environment Variables**:
```bash
GCP_SA_KEY          # Secret: Service account JSON
GCP_SA_KEY_FILE     # Temp file path: /tmp/gcp-key.json
```

**Permissions Required**:
```yaml
permissions:
  contents: write          # For committing stat updates
  pull-requests: write     # For posting PR comments
```

### PR Comment Format

```markdown
## Query Regression Test Results

**Summary:**
- ✅ **Pass:** 30 queries
- ⏳ **Pending Review:** 9 queries
- ❌ **Errors:** 0 queries

**Total Estimated Cost:** $2.4567

[View Full Results](link-to-results)

### Errors
- **query_name** (status): error message...
```

### Auto-Commit Strategy

**When**: On `push` to `main` or `develop` only (not PRs)

**What**: Updated query headers with new stats

**Commit Message**:
```
Update query stats from regression tests

- Updated X queries with new execution statistics
- Variance threshold: 10%
- Triggered by: [commit SHA]
```

**Conflict Handling**: Uses `|| true` to prevent failure if no changes

---

## Complexity Grading System

### Three-Tier Classification

| Tier | Criteria | Cost Range | Characteristics |
|------|----------|------------|-----------------|
| **Low** | Single table, basic filters | < $0.10 | No joins, simple aggregation, fast |
| **Medium** | Joins, unnesting, multi-step | $0.10-0.30 | 1-2 joins, controlled unnesting |
| **High** | Complex joins, full scans | > $0.30 | 3+ joins, deep unnesting, slow |

### Grading Algorithm (Manual)

**Factors to Consider**:
1. **Table Scope**: Single vs. multiple tables
2. **Join Complexity**: Number and type of joins
3. **Unnesting Depth**: Level of CROSS JOIN UNNEST nesting
4. **Aggregation**: Simple vs. window functions
5. **Filter Efficiency**: Early filtering vs. late filtering
6. **Result Size**: Expected row count

**Decision Tree**:
```
┌─ Single table?
│  ├─ Yes → Simple aggregation? → Yes → LOW
│  │         └─ No → MEDIUM
│  └─ No → Multiple joins?
│           ├─ 1-2 joins → MEDIUM
│           └─ 3+ joins → HIGH

┌─ Full table scan?
│  ├─ Yes → HIGH (unless very small table)
│  └─ No → (follow decision tree above)

┌─ Deep unnesting (3+ levels)?
│  ├─ Yes → HIGH
│  └─ No → (follow decision tree above)
```

**Examples**:

**Low**:
```sql
-- Single table, filtered, simple aggregation
SELECT DISTINCT Modality
FROM `bigquery-public-data.idc_current.dicom_all`
WHERE collection_id = "tcga_luad"
```

**Medium**:
```sql
-- Single table, unnesting, aggregation
SELECT sr_tid, COUNT(*) AS count
FROM `...dicom_all`
CROSS JOIN UNNEST(ContentTemplateSequence) AS seq
GROUP BY sr_tid
```

**High**:
```sql
-- Multiple tables, multiple joins, deep unnesting
WITH annotations AS (
  SELECT * FROM dicom_all
  CROSS JOIN UNNEST(ContentSequence) c1
  CROSS JOIN UNNEST(c1.ContentSequence) c2
)
SELECT a.*, s.*, c.*
FROM annotations a
JOIN segmentations s ON a.series_id = s.series_id
JOIN clinical c ON a.patient_id = c.patient_id
```

### Cost Estimation Formula

```
Cost (USD) = (Bytes Scanned / 1,099,511,627,776) × $6.25

Where:
- 1,099,511,627,776 bytes = 1 TB
- $6.25 = BigQuery on-demand pricing per TB
```

**Example**:
```
10 GB scanned   = (10 × 1024³) / 1024⁴ × $6.25 = $0.061
100 GB scanned  = (100 × 1024³) / 1024⁴ × $6.25 = $0.610
1 TB scanned    = 1 × $6.25 = $6.25
```

---

## Pending Queue Management

### Pending Categories

| Category | Reason | Curation Action |
|----------|--------|-----------------|
| **Parameterized** | Contains `<PLACEHOLDER>` | Document parameters, add examples |
| **Template** | Incomplete with `<condition>` | Provide usage examples, consolidate |
| **TODO** | Marked as TODO or incomplete | Complete implementation or document limitation |
| **Problem** | Syntax error or data issue | Fix and test, or document known issue |

### Pending Query Header

```sql
-- Purpose: [Description]
-- 
-- Complexity: [Tier]
-- Estimated Cost: TBD | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: [Why it's pending]
-- Action: [What needs to be done]
-- 
-- Description: ...
```

### Curation Workflow

```
┌─────────────────┐
│ Query Identified│
│   as Pending    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Categorize    │
│  (4 types)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Add to pending/│
│  + _NOTES.md    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Dry Run Testing │
│  (syntax check) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Manual Curation │
│  (fix issues)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Full Testing   │
│ (with execution)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Move to Prod    │
│ + Update _NOTES │
└─────────────────┘
```

### Promotion Checklist

- [ ] Issue fixed (parameters documented, template completed, etc.)
- [ ] Dry run passes (syntax valid)
- [ ] Execution passes (returns non-empty results)
- [ ] Header updated (remove PENDING status)
- [ ] Moved to appropriate category folder
- [ ] `_PENDING_NOTES.md` updated (entry removed)
- [ ] Committed with descriptive message

---

## Future Development Guidelines

### Adding New Features

**New Query Category**:
1. Create folder: `queries/{new_category}/`
2. Add category to `docs/QUERY_ORGANIZATION.md`
3. Update category taxonomy in this file
4. Add example queries
5. Update README.md with new category

**New Test Validation**:
1. Add validation logic to `run_regression_tests.py`
2. Update `test_config.yaml` with new parameters
3. Add documentation to `docs/SETUP.md`
4. Update CI/CD workflow if needed

**New Dataset Version**:
1. Update all queries: `idc_current` → `idc_vXX`
2. Test all queries with new dataset
3. Update documentation references
4. Create migration guide if schema changed

### Code Maintenance

**Python Code Style**:
- Follow PEP 8
- Use type hints where appropriate
- Document functions with docstrings
- Keep functions focused (single responsibility)

**Testing Changes**:
```bash
# Test locally before pushing
python tests/run_regression_tests.py --query-dir queries

# Check specific query
python -c "
from google.cloud import bigquery
client = bigquery.Client()
with open('queries/category/query.sql') as f:
    query = f.read()
result = client.query(query + '\nLIMIT 10').result()
print(f'Rows: {result.total_rows}')
"
```

**Documentation Updates**:
- Update this file when making architectural changes
- Update user-facing docs when changing user workflows
- Keep examples up-to-date with actual code
- Version significant changes in commit messages

### Performance Optimization

**Query Optimization**:
1. Use `LIMIT` for development/testing
2. Filter early with WHERE clauses
3. Partition pruning when available
4. Avoid `SELECT *` in production
5. Use materialized CTEs for repeated logic

**Test Optimization**:
1. Parallel test execution (future enhancement)
2. Caching test results for unchanged queries
3. Incremental testing (only changed queries)
4. Skip expensive queries in quick-test mode

### Monitoring & Alerts

**Current Monitoring**:
- GitHub Actions job status (pass/fail)
- Test result artifacts (30-day retention)
- PR comments (visible to reviewers)

**Future Enhancements**:
- Cost tracking dashboard
- Query performance trends
- Failure rate metrics
- Slack/email notifications

### Security Considerations

**Credentials Management**:
- NEVER commit `*.json` credential files
- Use GitHub Secrets for service accounts
- Rotate service account keys periodically
- Limit service account permissions (read-only)

**Code Review**:
- Review all SQL queries for injection risks
- Validate all user inputs in Python scripts
- Check for hardcoded credentials
- Verify dataset references are public

### Deprecation Policy

**Query Deprecation**:
1. Mark query as deprecated in header
2. Move to `queries/deprecated/` folder
3. Update documentation with deprecation notice
4. Remove from test suite
5. Delete after 6 months (with notice)

**Version Deprecation**:
1. Document in CHANGELOG.md
2. Update all references
3. Provide migration guide
4. Support old version for 3 months
5. Archive in separate branch

---

## Technical Debt & Known Issues

### Current Limitations

1. **Sequential Testing**: Tests run sequentially (slow for 39 queries)
   - Future: Parallel execution with thread pool
   
2. **Manual Complexity Grading**: Requires human judgment
   - Future: Automated grading based on query AST analysis

3. **No Query Versioning**: Queries overwritten on update
   - Future: Git history tracking or explicit versioning

4. **Limited Validation**: Only checks non-empty results
   - Future: Schema validation, result count assertions

### Future Enhancements

1. **Query Library Package**: Publish as Python package
2. **Interactive Query Builder**: Web UI for query construction
3. **Result Caching**: Cache results for faster testing
4. **Cost Budgeting**: Alert when cost threshold exceeded
5. **Query Templates**: Parameterized query generation
6. **Performance Profiling**: Detailed execution plan analysis

---

## References

### Internal Documentation
- [README.md](../README.md) - Project overview
- [docs/SETUP.md](../docs/SETUP.md) - Setup guide
- [docs/QUERY_ORGANIZATION.md](../docs/QUERY_ORGANIZATION.md) - Organization
- [docs/CONTRIBUTING.md](../docs/CONTRIBUTING.md) - Contribution guide

### External Resources
- [IDC Documentation](https://learn.canceridc.dev/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Understanding the BigQuery DICOM schema](https://docs.cloud.google.com/healthcare-api/docs/how-tos/dicom-bigquery-schema)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [DICOM Standard](https://dicom.nema.org/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

### Contact

For questions or issues with this development guide:
- Open GitHub issue with `dev` label
- Tag with `documentation` for doc issues
- Tag with `architecture` for design questions

---

**Last Updated**: January 22, 2026  
**Version**: 1.0.0  
**Maintainer**: Repository Contributors
