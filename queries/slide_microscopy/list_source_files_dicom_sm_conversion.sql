-- Purpose: List source files used for conversion of DICOM SM slides
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
-- 
-- Description:
-- Extracts source file paths from the OtherElements field for Slide Microscopy
-- objects. Identifies the original files used during DICOM SM conversion. Retrieves
-- the full resolution (base level) slide representation.
-- 
-- Author/Source: IDC Cookbook

WITH count_instances AS (
  SELECT
    ANY_VALUE(StudyInstanceUID) AS study_instance_uid,
    SeriesInstanceUID,
    COUNT(DISTINCT(SOPInstanceUID)) AS num_instances,
    STRING_AGG(DISTINCT(collection_id)) AS collection,
    SAFE_CAST(ANY_VALUE(NumberOfFrames) AS NUMERIC) AS num_frames,
    ANY_VALUE(OtherElements) AS other_elements
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    Modality = "SM"
  GROUP BY
    SeriesInstanceUID
  HAVING
    num_instances = 1)
SELECT
  SeriesInstanceUID,
  num_instances,
  collection,
  num_frames,
  other_elements.Data[SAFE_OFFSET(0)] AS source_file_path,
  CONCAT("https://viewer.imaging.datacommons.cancer.gov/slim/studies/", study_instance_uid, "/series/", SeriesInstanceUID) AS idc_viewer_url
FROM
  count_instances,
  UNNEST(other_elements) AS other_elements
WHERE
  num_instances = 1
  AND other_elements.Tag = "Tag_00091001"
ORDER BY
  num_frames DESC
