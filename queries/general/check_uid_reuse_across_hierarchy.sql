-- Purpose: Check which UIDs are reused across instance/series/study hierarchy
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.25 | Bytes Scanned: TBD
-- 
-- Description:
-- Checks for UIDs that are reused across different levels of the DICOM hierarchy.
-- Combines SOPInstanceUID, SeriesInstanceUID, and StudyInstanceUID into a single
-- dataset and identifies any UID that appears more than once (potentially indicating
-- data quality issues).
-- 
-- Author/Source: IDC Cookbook

WITH take_them_all AS (
  SELECT
    collection_id,
    SOPInstanceUID AS uid,
    'SOPInstanceUID' AS what_uid
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  UNION ALL
  SELECT
    DISTINCT collection_id,
    SeriesInstanceUID AS uid,
    'SeriesInstanceUID' AS what_uid
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  UNION ALL
  SELECT
    DISTINCT collection_id,
    StudyInstanceUID AS uid,
    'StudyInstanceUID' AS what_uid
  FROM
    `bigquery-public-data.idc_current.dicom_all`)
SELECT
  uid,
  COUNT(*) AS used_this_much,
  STRING_AGG(DISTINCT(collection_id),",") AS in_collections,
  STRING_AGG(DISTINCT(what_uid),",") AS used_where
FROM
  take_them_all
GROUP BY
  uid
HAVING
  used_this_much > 1
ORDER BY
  used_this_much desc
