-- Purpose: Select slides of project by project_id
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Parameterized query - requires <project_id> parameter substitution
-- 
-- Description:
-- Retrieves all distinct slide IDs (ContainerIdentifier) for a specific clinical
-- trial project identified by ClinicalTrialProtocolID.
-- 
-- Parameters:
--   <project_id>: ClinicalTrialProtocolID value (project identifier)
-- 
-- Author/Source: IDC Cookbook

SELECT
  DISTINCT(ContainerIdentifier) AS slide_id
FROM
  `bigquery-public-data.idc_current.dicom_all`
WHERE
  ClinicalTrialProtocolID = "<project_id>"
  AND Modality = "SM"
