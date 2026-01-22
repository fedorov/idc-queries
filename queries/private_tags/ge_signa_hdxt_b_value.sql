-- Purpose: Select b-value from private GE Signa HDxt DICOM tag
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
-- 
-- Description:
-- Extracts b-values from private GE Signa HDxt tags in the QIN Prostate Repeatability
-- collection. Demonstrates accessing private DICOM tags through the OtherElements field.
-- 
-- Author/Source: IDC Cookbook

WITH qpr AS (
  SELECT
    Manufacturer,
    ManufacturerModelName,
    ARRAY_TO_STRING(SoftwareVersions,"/"),
    PatientID,
    StudyDate,
    StudyInstanceUID,
    SeriesInstanceUID,
    SeriesDescription,
    SOPInstanceUID,
    OtherElements
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    collection_id = "qin_prostate_repeatability")
SELECT
  * EXCEPT(OtherElements, Tag),
  other_elements.Tag,
  other_elements.Data[SAFE_OFFSET(0)] as b_value
FROM
  qpr,
  UNNEST(OtherElements) AS other_elements
WHERE
  other_elements.Tag = "Tag_00431039"
ORDER BY
  PatientID,
  StudyDate
