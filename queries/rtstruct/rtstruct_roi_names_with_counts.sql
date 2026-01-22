-- Purpose: Get unique RTSTRUCT ROI names and count corresponding series
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Extracts all ROI (Region of Interest) names from RTSTRUCT objects and counts
-- how many series contain each ROI. Useful for understanding what anatomical
-- structures have been annotated with RTSTRUCT.
-- 
-- Author/Source: IDC Cookbook

SELECT
  structure_set_roi_sequence.ROIName AS roi_name,
  COUNT(DISTINCT(SeriesInstanceUID)) AS roi_series_count
FROM
  `bigquery-public-data.idc_current.dicom_all`
CROSS JOIN
  UNNEST(StructureSetROISequence) AS structure_set_roi_sequence
WHERE
  Modality = "RTSTRUCT"
GROUP BY
  roi_name
ORDER BY
  roi_series_count DESC
