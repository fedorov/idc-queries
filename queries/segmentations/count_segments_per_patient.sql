-- Purpose: Count segments per patient from segmentation series
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Aggregates the number of segments across all segmentation series per patient.
-- Note: Does not account for the same lesion segmented multiple times by the same reader.
-- 
-- Author/Source: IDC Cookbook

WITH lesion_count AS (
  SELECT
    PatientID,
    ARRAY_LENGTH(SegmentSequence) AS per_series_lesions
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    Modality = "SEG"
  ORDER BY
    per_series_lesions DESC)
SELECT
  PatientID,
  SUM(per_series_lesions) AS segments_per_patient
FROM
  lesion_count
GROUP BY
  PatientID
ORDER BY
  segments_per_patient DESC
