-- Purpose: Select all images that have multiple slices per ImagePositionPatient (4D images)
-- 
-- Complexity: High
-- Estimated Cost: $0.25-0.50 | Bytes Scanned: TBD
-- 
-- Description:
-- Identifies 4D images - series where multiple slices exist at the same spatial position.
-- Useful for finding temporal or multi-volume series. Filters out problematic series
-- and provides viewer URLs for investigation.
-- 
-- Author/Source: IDC Cookbook

WITH image_counts AS (
  SELECT
    SeriesInstanceUID,
    ANY_VALUE(SeriesDescription) AS series_description,
    ANY_VALUE(collection_id) AS collection_id,
    ARRAY_TO_STRING(ImagePositionPatient,'/') AS image_position_patient_str,
    COUNT(DISTINCT SOPInstanceUID) AS sop_count,
    ANY_VALUE(StudyInstanceUID) AS study_instance_uid,
    ANY_VALUE(Manufacturer) AS manufacturer
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  GROUP BY
    SeriesInstanceUID,
    ImagePositionPatient),
  series_stats AS (
  SELECT
    SeriesInstanceUID,
    ANY_VALUE(Manufacturer) AS manufacturer,
    MIN(sop_count) AS min_sop_count,
    MAX(sop_count) AS max_sop_count,
    COUNT(DISTINCT image_position_patient_str) AS image_position_count,
    ANY_VALUE(SeriesDescription) AS series_description,
    ANY_VALUE(collection_id) AS collection_id,
    ANY_VALUE(StudyInstanceUID) AS study_instance_uid
  FROM
    image_counts
  GROUP BY
    SeriesInstanceUID)
SELECT
  * EXCEPT(min_sop_count, max_sop_count, image_position_count),
  min_sop_count AS slices_per_ipp,
  image_position_count * min_sop_count AS total_slices,
  CONCAT("https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=", study_instance_uid, "&SeriesInstanceUIDs=", SeriesInstanceUID) AS ohif_v3_url
FROM
  series_stats
WHERE
  min_sop_count = max_sop_count
  AND min_sop_count >= 10
  AND image_position_count > 20
ORDER BY
  slices_per_ipp DESC
