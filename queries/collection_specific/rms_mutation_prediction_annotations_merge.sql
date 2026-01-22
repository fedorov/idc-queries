-- Purpose: RMS Mutation Prediction - merge annotations with slides and clinical data
-- 
-- Complexity: High
-- Estimated Cost: $0.30-0.50 | Bytes Scanned: TBD
-- 
-- Description:
-- Complex multi-table join demonstrating how to combine DICOM annotations (from SR),
-- Slide Microscopy metadata, and clinical data tables for the RMS Mutation Prediction
-- collection. Extracts annotation findings and merges with patient age, sample info,
-- diagnosis, and demographics.
-- 
-- Author/Source: IDC Cookbook

WITH annotations_details AS (
  SELECT
    PatientID,
    StudyInstanceUID,
    dicom_all.SeriesInstanceUID,
    CurrentRequestedProcedureEvidenceSequence[SAFE_OFFSET(0)].ReferencedSeriesSequence[SAFE_OFFSET(0)].SeriesInstanceUID AS annotated_series_instance_uid,
    content_sequence_unnested3.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning
  FROM
    `bigquery-public-data.idc_current.dicom_all` AS dicom_all
  CROSS JOIN
    UNNEST(ContentSequence) AS content_sequence_unnested
  CROSS JOIN
    UNNEST(content_sequence_unnested.ContentSequence) AS content_sequence_unnested2
  CROSS JOIN
    UNNEST(content_sequence_unnested2.ContentSequence) AS content_sequence_unnested3
  WHERE
    dicom_all.analysis_result_id = "RMS-Mutation-Prediction-Expert-Annotations"
    AND (content_sequence_unnested3.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning = "Finding")),
  rms_slides AS (
  SELECT
    DISTINCT(sm_metadata.SeriesInstanceUID) AS series_instance_uid,
    dicom_all.PatientID,
    LEFT(dicom_all.PatientAge, LENGTH(dicom_all.PatientAge) - 1) as patient_age,
    dicom_all.StudyInstanceUID,
    sm_metadata.* EXCEPT (SeriesInstanceUID)
  FROM
    `bigquery-public-data.idc_current.dicom_metadata_curated_series_level` AS sm_metadata
  INNER JOIN
    `bigquery-public-data.idc_current.dicom_all` AS dicom_all
  ON
    sm_metadata.SeriesInstanceUID = dicom_all.SeriesInstanceUID
  WHERE
    dicom_all.collection_id = "rms_mutation_prediction"
    AND dicom_all.Modality = "SM"
  ORDER BY
    sm_metadata.SeriesInstanceUID)
SELECT
  rms_slides.*,
  sample.* EXCEPT (dicom_patient_id, participantparticipant_id),
  diagnosis.* EXCEPT (dicom_patient_id, participantparticipant_id),
  demographics.* EXCEPT (dicom_patient_id),
  annotations_details.* EXCEPT (SeriesInstanceUID),
  annotations_details.SeriesInstanceUID AS annotation_series_instance_uid
FROM
  rms_slides
LEFT OUTER JOIN
  annotations_details
ON
  rms_slides.series_instance_uid = annotations_details.annotated_series_instance_uid
JOIN
  `bigquery-public-data.idc_current_clinical.rms_mutation_prediction_sample` AS sample
ON
  rms_slides.PatientID = sample.dicom_patient_id
JOIN
  `bigquery-public-data.idc_current_clinical.rms_mutation_prediction_diagnosis` AS diagnosis
ON
  rms_slides.PatientID = diagnosis.dicom_patient_id
JOIN
  `bigquery-public-data.idc_current_clinical.rms_mutation_prediction_demographics` AS demographics
ON
  rms_slides.PatientID = demographics.dicom_patient_id
ORDER BY
  rms_slides.series_instance_uid
