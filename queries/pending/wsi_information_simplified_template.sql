-- Purpose: Simplify access to WSI-related information
-- 
-- Complexity: Medium
-- Estimated Cost: $0.10-0.20 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Template query with incomplete placeholders needing customization
-- 
-- Description:
-- Provides a reusable view-like structure to access Whole Slide Image (WSI) information
-- with pixel dimensions, spacing, GCS URL, compression type, and metadata.
-- 
-- This is a template - customize by:
-- 1. Replacing <columns from slide images view> with desired columns
-- 2. Replacing <condition> with WHERE clause filters
-- 
-- Compression types reference:
--   - DICOM PS3.3 2021b 8.7.3.1 Instance Media Types
--     http://dicom.nema.org/medical/dicom/current/output/chtml/part18/sect_8.7.3.html#table_8.7.3-2
-- 
-- Author/Source: IDC Cookbook

WITH slide_images AS (
  SELECT
    ContainerIdentifier AS slide_id,
    PatientID AS patient_id,
    ClinicalTrialProtocolID AS dataset,
    TotalPixelMatrixColumns AS width,
    TotalPixelMatrixRows AS height,
    gcs_url,
    CAST(SharedFunctionalGroupsSequence[OFFSET(0)].
      PixelMeasuresSequence[OFFSET(0)].
      PixelSpacing[OFFSET(0)] AS FLOAT64) AS pixel_spacing,
    CASE TransferSyntaxUID
      WHEN '1.2.840.10008.1.2.4.50' THEN 'jpeg'
      WHEN '1.2.840.10008.1.2.4.91' THEN 'jpeg2000'
      ELSE 'other'
    END AS compression
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    NOT (ContainerIdentifier IS NULL)
    AND Modality = "SM")
SELECT
  <columns from slide images view>
FROM
  slide_images
WHERE
  <condition>
