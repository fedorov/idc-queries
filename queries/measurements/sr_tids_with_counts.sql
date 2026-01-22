-- Purpose: Get all SR Template IDs (TIDs) with counts
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Extracts and counts all Structured Report (SR) Template IDs from the
-- ContentTemplateSequence. Useful for understanding what SR templates are
-- present in the dataset.
-- 
-- Author/Source: IDC Cookbook

WITH sr_unnested AS (
  WITH structured_reports AS (
    SELECT
      *
    FROM
      `bigquery-public-data.idc_current.dicom_all`
    WHERE
      Modality = "SR")
  SELECT
    SOPInstanceUID,
    content_template_sequence.TemplateIdentifier AS sr_tid
  FROM
    structured_reports
  CROSS JOIN
    UNNEST(ContentTemplateSequence) AS content_template_sequence)
SELECT
  sr_tid,
  COUNT(DISTINCT(SOPInstanceUID)) AS sr_tids_count
FROM
  sr_unnested
GROUP BY
  sr_tid
ORDER BY
  sr_tids_count DESC
