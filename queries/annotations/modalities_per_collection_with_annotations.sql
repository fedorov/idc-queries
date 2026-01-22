-- Purpose: Summarize modalities per collection and mark those that have SEG or RTSTRUCT
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Lists all modalities available in each collection and marks whether the collection
-- contains segmentation (SEG) or radiotherapy structure (RTSTRUCT) annotations.
-- 
-- Author/Source: IDC Cookbook

WITH all_modalities AS (
  SELECT
    collection_id,
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT(Modality)),",") AS modalities,
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT(access)),",") AS access
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  GROUP BY
    collection_id)
SELECT
  *,
  (CASE
    WHEN modalities LIKE "%SEG%" OR modalities LIKE "%RTSTRUCT%" THEN "YES"
    ELSE "NO"
  END) AS has_annotations
FROM
  all_modalities
ORDER BY
  has_annotations DESC
