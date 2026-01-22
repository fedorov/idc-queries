# Pending Queries - Curation Guide

This directory contains queries that require manual review and curation before moving to production folders.

## Pending Queries Summary

| Query | Reason for Pending | Action Required |
|-------|-------------------|-----------------|
| `TODO_codesequence_tuples_as_strings.sql` | TODO comment - incomplete work | Complete implementation based on DICOM code sequence analysis requirements |
| `quantitative_qualitative_pivot_validation_pending.sql` | TODO comment - validation needed | Add verification logic to validate results against example instances |
| `slide_dcm_objects_by_id_param.sql` | Parameterized with `<slide_id>` | Document parameter usage, add example values, test with sample data |
| `slide_dcm_width_height_by_url_param.sql` | Parameterized with `<gcs_url>` | Document parameter usage, add example values, test with sample data |
| `slide_pixel_size_by_url_param.sql` | Parameterized with `<gcs_url>` | Document parameter usage, add example values, test with sample data |
| `slides_by_project_id_param.sql` | Parameterized with `<project_id>` | Document parameter usage, add example values, test with sample data |
| `wsi_information_simplified_template.sql` | Template with incomplete placeholders | Provide examples of column and condition usage, consolidate variations |
| `htan_channels_exploration_needs_curation.sql` | Struck-through code blocks, multiple variations | Consolidate alternatives, determine optimal approach, test variations |
| `rtstruct_roi_instances_db_mismatch.sql` | Non-standard database reference in original | Verify database reference correction, test query execution |

## Curation Process

### For Parameterized Queries
1. Add example parameter values to the header
2. Create test cases with actual IDC data
3. Document the source of parameter values
4. Move to production folder once tested

### For Template Queries
1. Provide concrete usage examples
2. Document all customization points
3. Create sample variations
4. Move to production folder once examples are complete

### For TODO/Incomplete Queries
1. Complete implementation or clarify requirements
2. Add validation logic where needed
3. Test against sample data
4. Move to production folder once validated

### For Consolidation Queries
1. Review all variations and alternatives
2. Determine which approach is optimal
3. Document differences and performance trade-offs
4. Choose and implement best version, move to production

## Promotion to Production

Once a pending query has been fully curated and tested:
1. Move the `.sql` file to the appropriate production category folder
2. Update the file header to remove "PENDING REVIEW" status
3. Update this `_PENDING_NOTES.md` file to remove the completed query
4. Create a git commit documenting the promotion

Example:
```bash
# After curation and testing of parameterized_query.sql
git mv queries/pending/parameterized_query.sql queries/measurements/parameterized_query.sql
# Update the file, then:
git add -A
git commit -m "Promote parameterized_query.sql to production after curation"
```
