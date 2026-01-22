-- Purpose: Sample values of TransferSyntaxUID
-- 
-- Complexity: Low
-- Estimated Cost: $0.10-0.15 | Bytes Scanned: TBD
-- 
-- Description:
-- Samples one instance for each distinct TransferSyntaxUID and Modality combination.
-- Maps UIDs to human-readable descriptions and provides viewer URLs appropriate for
-- each modality (Slim for SM, OHIF for others).
-- 
-- Reference: DICOM PS3.3 2021b 8.7.3.1
-- Author/Source: IDC Cookbook

WITH selection AS (
  SELECT
    TransferSyntaxUID,
    Modality,
    ANY_VALUE(SOPInstanceUID) AS sop_instance_uid
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  GROUP BY
    TransferSyntaxUID,
    Modality)
SELECT
  dicom_all.TransferSyntaxUID,
  dicom_all.Modality,
  CASE dicom_all.TransferSyntaxUID
    WHEN "1.2.840.10008.1.2.1" THEN "Explicit VR Big Endian"
    WHEN "1.2.840.10008.1.2.4.50" THEN "JPEG Baseline (Process 1)"
    WHEN "1.2.840.10008.1.2.4.90" THEN "JPEG 2000 Image Compression (Lossless Only)"
    WHEN "1.2.840.10008.1.2.4.91" THEN "JPEG 2000 Image Compression"
  END AS transfer_syntax_readable,
  dicom_all.StudyInstanceUID,
  dicom_all.SeriesInstanceUID,
  CASE dicom_all.Modality
    WHEN "SM" THEN CONCAT("https://viewer.imaging.datacommons.cancer.gov/slim/studies/", StudyInstanceUID, "/series/", SeriesInstanceUID)
    ELSE CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/", StudyInstanceUID, "?seriesInstanceUID=", SeriesInstanceUID)
  END AS viewer_url
FROM
  selection
JOIN
  `bigquery-public-data.idc_current.dicom_all` AS dicom_all
ON
  selection.sop_instance_uid = dicom_all.SOPInstanceUID
ORDER BY
  TransferSyntaxUID, Modality
