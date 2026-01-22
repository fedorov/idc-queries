-- Purpose: PET related explorations for robust SUV calculations
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
-- 
-- Description:
-- Explores PET data characteristics for SUV (Standardized Uptake Value) calculations.
-- Identifies PET series with specific units, decay correction, and image correction
-- attributes. Based on QIBA algorithms for robust SUV implementation.
-- 
-- Note: This may not be the definitive way to do it per David Clunie, but demonstrates
-- practical use of BigQuery to search DICOM headers for specific data characteristics.
-- Author/Source: IDC Cookbook

SELECT
  StudyInstanceUID,
  ANY_VALUE(Units) as units,
  ANY_VALUE(DecayCorrection) as decay_correction,
  ANY_VALUE(CorrectedImage) as corrected_image
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  Units = "PROPCNTS"
  AND DecayCorrection = "START"
  AND "DECY" IN UNNEST(CorrectedImage)
  AND "ATTN" IN UNNEST(CorrectedImage)
GROUP BY
  StudyInstanceUID
