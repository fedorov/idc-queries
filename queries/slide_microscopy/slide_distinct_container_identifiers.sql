-- Purpose: Select distinct values of slide IDs (ContainerIdentifier)
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves all distinct slide IDs from Slide Microscopy (SM) modality objects.
-- These identifiers can be used as input for other SM queries.
-- 
-- Author/Source: IDC Cookbook

SELECT
  DISTINCT(ContainerIdentifier)
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  Modality = "SM"
