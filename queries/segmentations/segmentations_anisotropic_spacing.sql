-- Purpose: Select all segmentations with anisotropic pixel spacing and unequal dimensions
-- 
-- Complexity: Medium
-- Estimated Cost: $0.15-0.30 | Bytes Scanned: TBD
-- 
-- Description:
-- Identifies segmentation series where the number of columns does not equal the
-- number of rows AND the PixelSpacing components are not equal (anisotropic).
-- Uses proper SOPClassUID filtering to identify true DICOM Segmentation objects.
-- 
-- Reference: https://dicom.nema.org/medical/dicom/current/output/html/part04.html#sect_B.5
-- Author/Source: IDC Cookbook

WITH uneq_with_spacing AS (
  WITH uneq AS (
    SELECT
      DISTINCT(collection_id),
      PatientID,
      SeriesInstanceUID
    FROM
      `bigquery-public-data.idc_current.dicom_all`
    WHERE
      Modality = "SEG"
      AND SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"
      AND `Rows` <> `Columns`)
  SELECT
    uneq.*,
    dicom_all.SharedFunctionalGroupsSequence[OFFSET(0)].PixelMeasuresSequence[OFFSET(0)].PixelSpacing[OFFSET(0)] AS spacing_row,
    dicom_all.SharedFunctionalGroupsSequence[OFFSET(0)].PixelMeasuresSequence[OFFSET(0)].PixelSpacing[OFFSET(1)] AS spacing_col
  FROM
    uneq
  JOIN
    `bigquery-public-data.idc_current.dicom_all` AS dicom_all
  ON
    uneq.SeriesInstanceUID = dicom_all.SeriesInstanceUID
  WHERE
    dicom_all.SharedFunctionalGroupsSequence IS NOT NULL)
SELECT
  *
FROM
  uneq_with_spacing
WHERE
  spacing_row <> spacing_col
