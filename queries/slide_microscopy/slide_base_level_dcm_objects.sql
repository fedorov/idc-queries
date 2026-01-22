-- Purpose: Select base level (full resolution) DCM objects of slide
-- 
-- Complexity: Low
-- Estimated Cost: $0.05-0.10 | Bytes Scanned: TBD
-- 
-- Description:
-- Retrieves the base level (highest resolution) DICOM object for each slide.
-- Since ContainerIdentifier is not globally unique (slides can be scanned twice),
-- uses both ContainerIdentifier and FrameOfReferenceUID to uniquely identify slides.
-- Identifies base level by finding the instance with maximum pixel matrix size.
-- 
-- Author/Source: IDC Cookbook

WITH max_sizes AS (
  SELECT
    ContainerIdentifier,
    FrameOfReferenceUID,
    MAX(TotalPixelMatrixColumns * TotalPixelMatrixRows) AS max_size
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  WHERE
    NOT (ContainerIdentifier IS NULL)
    AND Modality = "SM"
  GROUP BY
    ContainerIdentifier,
    FrameOfReferenceUID)
SELECT
  b.ContainerIdentifier AS slide_id,
  b.gcs_url
FROM
  max_sizes AS a
JOIN
  `bigquery-public-data.idc_current.dicom_all` AS b
ON
  b.ContainerIdentifier = a.ContainerIdentifier
  AND b.FrameOfReferenceUID = a.FrameOfReferenceUID
  AND a.max_size = b.TotalPixelMatrixColumns * b.TotalPixelMatrixRows
WHERE
  b.Modality = "SM"
