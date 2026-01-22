-- Purpose: Get all distinct types of qualitative measurements available
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves distinct combinations of qualitative measurement quantities and their
-- coded values. Provides an inventory of what qualitative measurements are
-- available in the dataset (e.g., subtlety scores, margin descriptions).
-- 
-- Author/Source: IDC Cookbook

SELECT
  DISTINCT(Quantity.CodeMeaning) AS quantity_cm,
  Value.CodeMeaning AS value_cm
FROM
  `bigquery-public-data.idc_current.qualitative_measurements`
ORDER BY
  quantity_cm
