-- Purpose: Select slides based on processing step characteristics
-- 
-- Complexity: High
-- Estimated Cost: $0.20-0.40 | Bytes Scanned: TBD
-- 
-- Description:
-- Builds on the processing step query to select slides matching specific processing
-- characteristics. Example: select all slides that were freeze-processed.
-- Demonstrates filtering on nested specimen preparation attributes.
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
    Modality = "SM"),
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
  *
FROM
  steps_unnested
WHERE
  concept_name_code_meaning = "Embedding medium"
  AND code_value_code_meaning = "Tissue freezing medium"
