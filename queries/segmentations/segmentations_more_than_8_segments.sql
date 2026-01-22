-- Purpose: Select segmentations that have more than 8 segments
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Identifies segmentation series with more than 8 segments. The threshold of 8
-- is arbitrary and can be adjusted as needed. Only includes public access data.
-- 
-- Author/Source: IDC Cookbook

WITH seg_only AS (
  SELECT
    SOPInstanceUID,
    PatientID,
    collection_id,
    SegmentSequence,
    SeriesInstanceUID
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    Modality = "SEG"
    AND SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"
    AND access = "Public")
SELECT
  DISTINCT(PatientID),
  SeriesInstanceUID,
  collection_id
FROM
  seg_only
WHERE
  ARRAY_LENGTH(SegmentSequence) > 8
