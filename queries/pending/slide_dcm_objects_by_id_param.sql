-- Purpose: Select DCM objects of slide by slide_id
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Parameterized query - requires <slide_id> parameter substitution
-- 
-- Description:
-- Retrieves all DICOM objects (gcs_url) for a specific slide identified by
-- ContainerIdentifier (slide_id).
-- 
-- Parameters:
--   <slide_id>: ContainerIdentifier value from slide_distinct_container_identifiers query
--   Example: C3N-03928-22
-- 
-- Author/Source: IDC Cookbook

SELECT
  gcs_url
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  ContainerIdentifier = "<slide_id>"
