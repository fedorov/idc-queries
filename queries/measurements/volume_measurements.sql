-- Purpose: Get all volume measurements
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves all quantitative measurements where the quantity is "Volume".
-- The actual volume measurement values are in the "Value" column.
-- 
-- Author/Source: IDC Cookbook

SELECT
  *
FROM
  `bigquery-public-data.idc_current.quantitative_measurements`
WHERE
  Quantity.CodeMeaning = "Volume"
