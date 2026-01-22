-- Purpose: Confirm each PatientID is included in a single collection
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Selects distinct PatientID, groups by PatientID, and aggregates distinct values
-- of collection_id per PatientID. Orders by count to identify patients that span
-- multiple collections (count > 1).
-- 
-- Author/Source: IDC Cookbook

SELECT
  dic_all.PatientID,
  COUNT(DISTINCT(dic_all.collection_id)) as count_collection_id_list,
  STRING_AGG(DISTINCT(dic_all.collection_id), ",") as collection_id_list
FROM
  `bigquery-public-data.idc_current.dicom_all` as dic_all
GROUP BY
  PatientID
HAVING
  count_collection_id_list > 1
