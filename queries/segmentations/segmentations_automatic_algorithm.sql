-- Purpose: Get all segmentations that were generated with AUTOMATIC algorithm type
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves segmentation instances that were automatically generated (as opposed
-- to manual segmentations), joining dicom_all with the segmentations table.
-- 
-- Author/Source: IDC Cookbook

SELECT
  dicom_all.SeriesInstanceUID,
  dicom_all.SOPInstanceUID,
  segmentations.SegmentAlgorithmType
FROM
  `bigquery-public-data.idc_current.segmentations` as segmentations
JOIN
  `bigquery-public-data.idc_current.dicom_all` as dicom_all
ON
  dicom_all.SOPInstanceUID = segmentations.SOPInstanceUID
WHERE
  SegmentAlgorithmType = 'AUTOMATIC'
