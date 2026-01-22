-- Purpose: Get instances that have a specific ROIName in RTSTRUCT
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Database reference mismatch - uses non-standard dataset
-- 
-- Description:
-- Retrieves SOPInstanceUID and PatientID for RTSTRUCT objects containing a
-- specific ROI (Region of Interest) name (e.g., "Heart").
-- 
-- ISSUE: Original query references `canceridc-data.idc_views.dicom_all`
--        This appears to be a non-standard dataset reference.
--        Should be updated to `bigquery-public-data.idc_current.dicom_all`
--        Needs verification during curation.
-- 
-- Parameters:
--   Update "Heart" to desired ROIName value
-- 
-- Author/Source: IDC Cookbook

SELECT
  SOPInstanceUID,
  PatientID,
  structure_set_roi_sequence.ROIName AS roi_name
FROM
  `bigquery-public-data.idc_current.dicom_all`
CROSS JOIN
  UNNEST(StructureSetROISequence) AS structure_set_roi_sequence
WHERE
  Modality = "RTSTRUCT"
  AND roi_name = "Heart"
