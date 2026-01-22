-- Purpose: Get all distinct combinations of values describing anatomy/types in segmentations
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves distinct combinations of anatomic region, property category, and property type
-- information from segmentation objects. Useful for understanding what anatomical structures
-- are being segmented and with what properties.
-- 
-- Author/Source: IDC Cookbook

SELECT
  DISTINCT(AnatomicRegion.CodeMeaning) AS AnatomicRegion_cm,
  AnatomicRegionModifier.CodeMeaning AS AnatomicRegionModifier_cm,
  SegmentedPropertyCategory.CodeMeaning AS SegmentedPropertyCategory_cm,
  SegmentedPropertyType.CodeMeaning AS SegmentedPropertyType_cm,
  SegmentedPropertyType.AnatomicRegionModifierSequence[SAFE_OFFSET(0)].CodeMeaning AS SegmentedPropertyType_AnatomicRegionModifier_cm
FROM
  `bigquery-public-data.idc_current.segmentations`
