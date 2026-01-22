-- Purpose: Get all distinct combinations for processing step names and values
-- 
-- Complexity: High
-- Estimated Cost: $0.20-0.40 | Bytes Scanned: TBD
-- 
-- Description:
-- Unnests and analyzes SpecimenPreparationSequence from Slide Microscopy objects.
-- Extracts all distinct combinations of processing step names and their values.
-- Useful for understanding what specimen preparation steps are used in the dataset.
-- 
-- Author/Source: IDC Cookbook

WITH specimen_preparation_sequence_unnested AS (
  SELECT
    gcs_url,
    SOPInstanceUID,
    ContainerIdentifier,
    ARRAY_LENGTH(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence),
    steps_unnested.SpecimenPreparationStepContentItemSequence AS steps_unnested1
  FROM
    `bigquery-public-data.idc_current.dicom_all`
  CROSS JOIN
    UNNEST(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested
  WHERE
    (collection_id = "tcga_lusc" OR collection_id = "tcga_luad")
    AND Modality = "SM"),
  steps_unnested AS (
  SELECT
    SOPInstanceUID,
    ContainerIdentifier,
    gcs_url,
    steps_unnested2.ValueType,
    steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS concept_name_code_meaning,
    steps_unnested2.TextValue AS text_value,
    steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS code_value_code_meaning
  FROM
    specimen_preparation_sequence_unnested
  CROSS JOIN
    UNNEST(steps_unnested1) AS steps_unnested2)
SELECT
  DISTINCT(concept_name_code_meaning) AS step_name_cm,
  code_value_code_meaning AS step_value_cm
FROM
  steps_unnested
ORDER BY
  step_name_cm
