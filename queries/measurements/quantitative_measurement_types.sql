-- Purpose: Get all types of quantitative measurements available
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves distinct combinations of measurement quantities and their units
-- from the quantitative_measurements table. Provides an inventory of what
-- quantitative measurements are available in the dataset.
-- 
-- Author/Source: IDC Cookbook

SELECT
  DISTINCT(Quantity.CodeMeaning) AS quantity_cm,
  Units.CodeMeaning AS units_cm
FROM
  `bigquery-public-data.idc_current.quantitative_measurements`
