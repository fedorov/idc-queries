-- Purpose: Select all unique lesions from LIDC collection (nodules clustered by pylidc)
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
-- 
-- Description:
-- Identifies unique lesions in the LIDC-IDRI dataset by extracting nodule IDs from
-- SeriesDescription (LIDC-specific). Demonstrates complex windowing and aggregation
-- to count distinct lesion IDs per patient.
-- 
-- Note: LIDC-specific collection query
-- Author/Source: IDC Cookbook

WITH nodulesAggregated AS (
  WITH withDistinctNoduleID AS (
    WITH withNoduleID AS (
      SELECT
        PatientID,
        SAFE_CAST(REGEXP_EXTRACT(SeriesDescription, r"[0-9]+") AS NUMERIC) AS noduleID
      FROM
        `bigquery-public-data.idc_current.dicom_all`
      WHERE
        Modality = "SEG"
        AND collection_id = "lidc_idri"
        AND source_doi = "10.7937/TCIA.2018.h7umfurq"
      ORDER BY
        PatientID)
    SELECT
      DISTINCT(noduleID),
      PatientID
    FROM
      withNoduleID)
  SELECT
    PatientID,
    MAX(noduleID) OVER (PARTITION BY PatientID) AS max_lesion_id,
    COUNT(noduleID) OVER (PARTITION BY PatientID) AS num_distinct_lesion_ids
  FROM
    withDistinctNoduleID)
SELECT
  DISTINCT(PatientID),
  num_distinct_lesion_ids
FROM
  nodulesAggregated
ORDER BY
  num_distinct_lesion_ids DESC
