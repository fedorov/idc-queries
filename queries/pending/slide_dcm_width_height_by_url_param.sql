-- Purpose: Select width and height of DCM object by GCS URL
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Parameterized query - requires <gcs_url> parameter substitution
-- 
-- Description:
-- Retrieves the pixel dimensions (width/height) for a specific Slide Microscopy
-- DICOM object identified by its GCS URL.
-- 
-- Parameters:
--   <gcs_url>: GCS URL from slide queries (full path to DICOM object)
-- 
-- Author/Source: IDC Cookbook

SELECT
  TotalPixelMatrixColumns AS width,
  TotalPixelMatrixRows AS height
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  gcs_url = "<gcs_url>"
