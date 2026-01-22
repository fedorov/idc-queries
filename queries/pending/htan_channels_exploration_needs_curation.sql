-- Purpose: Exploration of channels in HTAN collections
-- 
-- Complexity: High
-- Estimated Cost: $0.25-0.50 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Contains struck-through code blocks and commented variations
-- 
-- Description:
-- Analyzes specimen preparation steps and identifies channel components in
-- Human Tumor Atlas Network (HTAN) collections. Demonstrates complex unnesting
-- and filtering on slide microscopy metadata.
-- 
-- Note: Contains multiple commented/alternative approaches below main query.
--       These require review and consolidation during curation.
-- 
-- Author/Source: IDC Cookbook

WITH specimen_preparation_sequence_unnested AS (
  SELECT
    gcs_url,
    collection_id,
    SOPInstanceUID,
    StudyInstanceUID,
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
    StudyInstanceUID,
    collection_id,
    ContainerIdentifier,
    gcs_url,
    steps_unnested2.ValueType,
    steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS concept,
    steps_unnested2.TextValue AS text_value,
    steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS value
  FROM
    specimen_preparation_sequence_unnested
  CROSS JOIN
    UNNEST(steps_unnested1) AS steps_unnested2)
SELECT
  *,
  concat("https://viewer.imaging.datacommons.cancer.gov/slim/studies/", StudyInstanceUID) as viewer_url
FROM
  steps_unnested
WHERE
  collection_id LIKE "htan_hms"
  AND concept = "Component investigated"
  AND ValueType = "TEXT"

-- NOTE: Alternative approaches below require consolidation during curation:
-- - Multiple commented-out variations testing different WHERE conditions
-- - Tests for specific components like CD163
-- - Alternative database references (idc_v10_pub, testing-viewer)
-- TODO: Review alternatives and determine optimal approach
