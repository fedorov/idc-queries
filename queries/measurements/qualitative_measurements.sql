-- Purpose: Get all qualitative measurements
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves all qualitative measurements with their SOPInstanceUID, Quantity, and Value.
-- Qualitative measurements are categorical/coded assessments (as opposed to numeric
-- quantitative measurements).
-- 
-- Author/Source: IDC Cookbook

SELECT
  SOPInstanceUID,
  Quantity,
  Value
FROM
  `bigquery-public-data.idc_current.qualitative_measurements`
