-- Purpose: Count series and distinct ImagePositionPatient values per series
-- 
-- Complexity: Medium
-- Estimated Cost: $0.15-0.30 | Bytes Scanned: TBD
-- 
-- Description:
-- Counts the number of instances and distinct ImagePositionPatient values per series.
-- Can identify non-conventional 3D cross-sectional images. Provides viewer URLs for
-- further investigation of interesting series.
-- 
-- Note: The WHERE clause filters out problematic series (e.g., missing ImagePositionPatient).
-- Author/Source: IDC Cookbook

WITH series_counts AS (
  SELECT
    SeriesInstanceUID,
    ANY_VALUE(StudyInstanceUID) AS study_instance_uid,
    COUNT(DISTINCT(SOPInstanceUID)) AS instance_count,
    COUNT(DISTINCT(ARRAY_TO_STRING(ImagePositionPatient,"/"))) AS position_count,
    STRING_AGG(DISTINCT(SeriesDescription),",") AS series_desc
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  GROUP BY
    SeriesInstanceUID)
SELECT
  * EXCEPT (SeriesInstanceUID, study_instance_uid),
  instance_count / position_count AS instances_per_position,
  CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/", study_instance_uid, "?seriesInstanceUID=", SeriesInstanceUID) AS viewer_url
FROM
  series_counts
WHERE
  position_count > 1
ORDER BY
  instances_per_position DESC
