-- Purpose: Find all non-SM multiframe series and sort by size
-- 
-- Complexity: Medium
-- Estimated Cost: $0.15-0.30 | Bytes Scanned: TBD
-- 
-- Description:
-- Identifies multiframe DICOM series (excluding Slide Microscopy) that consist of
-- a single instance. Sorts results by total size to find the largest multiframe objects.
-- Provides viewer URLs for inspection.
-- 
-- Author/Source: IDC Cookbook

WITH temp_q AS (
  SELECT
    SeriesInstanceUID,
    STRING_AGG(DISTINCT(Modality)) AS modalities,
    COUNT(DISTINCT(SOPInstanceUID)) AS num_instances,
    ANY_VALUE(NumberOfFrames) AS number_of_frames,
    SUM(instance_size / POW(1024,3)) AS num_bytes,
    ANY_VALUE(StudyInstanceUID) AS study_instance_uid,
    ANY_VALUE(SOPClassUID) AS sop_class_uid,
    ANY_VALUE(CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/", StudyInstanceUID, "?seriesInstanceUID=", SeriesInstanceUID)) AS viewer_url
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    Modality <> "SM"
  GROUP BY
    SeriesInstanceUID)
SELECT
  *
FROM
  temp_q
WHERE
  num_instances = 1
ORDER BY
  num_bytes desc
