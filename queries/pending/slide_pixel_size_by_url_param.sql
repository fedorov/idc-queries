-- Purpose: Select pixel size / resolution / magnification of DCM object by GCS URL
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Parameterized query - requires <gcs_url> parameter substitution
-- 
-- Description:
-- Retrieves pixel spacing (resolution) for a Slide Microscopy DICOM object.
-- Pixel size is returned in mm. Resolution = 1 / pixel size.
-- First value is row spacing (Y), second value is column spacing (X).
-- 
-- References:
--   - DICOM PS3.3 2021b 10.7.1.3: Pixel Spacing Value Order and Valid Values
--     http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_10.7.html#sect_10.7.1.3
--   - Pixel size values for different magnifications:
--     https://doi.org/10.4103/2153-3539.116866
-- 
-- Parameters:
--   <gcs_url>: GCS URL from slide queries (full path to DICOM object)
-- 
-- Author/Source: IDC Cookbook

SELECT
  CAST(SharedFunctionalGroupsSequence[OFFSET(0)].
    PixelMeasuresSequence[OFFSET(0)].
    PixelSpacing[OFFSET(0)] AS FLOAT64) AS pixel_size_y,
  CAST(SharedFunctionalGroupsSequence[OFFSET(0)].
    PixelMeasuresSequence[OFFSET(0)].
    PixelSpacing[OFFSET(1)] AS FLOAT64) AS pixel_size_x
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  gcs_url = "<gcs_url>"
