-- Purpose: Select series that have more than one value of FrameOfReferenceUID
-- 
-- Complexity: Medium
-- Estimated Cost: $0.15-0.30 | Bytes Scanned: TBD
-- 
-- Description:
-- Identifies series (particularly Slide Microscopy) that have multiple FrameOfReferenceUID
-- values, which can occur when a slide is scanned multiple times. Uses a custom array
-- distinct function to deduplicate image types. Provides Slim viewer URLs for inspection.
-- 
-- Author/Source: IDC Cookbook

CREATE TEMP FUNCTION array_distinct(value ANY TYPE) AS ((
  SELECT
    ARRAY_AGG(a.b)
  FROM (
    SELECT
      DISTINCT *
    FROM
      UNNEST(value) b) a));

WITH selection AS (
  SELECT
    SeriesInstanceUID,
    any_value(StudyInstanceUID) as study_instance_uid,
    COUNT(DISTINCT(FrameOfReferenceUID)) AS num_for,
    ARRAY_AGG(ARRAY_TO_STRING(ImageType,"/")) AS image_types
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    Modality = "SM"
  GROUP BY
    SeriesInstanceUID
  ORDER BY
    num_for DESC)
SELECT
  study_instance_uid,
  SeriesInstanceUID,
  num_for,
  array_distinct(image_types),
  concat("https://viewer.imaging.datacommons.cancer.gov/slim/studies/", study_instance_uid, "/series/", SeriesInstanceUID) as slim_url
FROM
  selection
WHERE
  num_for > 1
