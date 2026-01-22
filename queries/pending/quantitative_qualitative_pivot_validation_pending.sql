-- Purpose: Select quantitative and qualitative, pivot by measurement type, join by SOPInstanceUID
-- 
-- Complexity: High
-- Estimated Cost: $0.25-0.50 | Bytes Scanned: TBD
-- 
-- Status: PENDING REVIEW
-- Reason: Query contains TODO comment for validation - needs verification logic
-- 
-- Description:
-- Combines quantitative and qualitative measurements by pivoting on measurement type
-- and joining by SOPInstanceUID. Creates temporary tables for pivoted data and joins them.
-- This approach works well for LIDC collection where there is one instance per measurement.
-- 
-- TODO: Demonstrate how to verify that the results are accurate on example instances
-- Author/Source: IDC Cookbook

CREATE TEMP TABLE IF NOT EXISTS quantitative_pivoted AS
SELECT
  PatientID,
  SOPInstanceUID,
  SUM(CASE
    WHEN Quantity.CodeMeaning = "Volume" THEN SAFE_CAST(Value AS NUMERIC)
    ELSE 0
  END) AS volume,
  SUM(CASE
    WHEN Quantity.CodeMeaning = "Surface area of mesh" THEN SAFE_CAST(Value AS numeric)
    ELSE 0
  END) AS surface,
  SUM(CASE
    WHEN Quantity.CodeMeaning = "Diameter" THEN SAFE_CAST(Value AS numeric)
    ELSE 0
  END) AS diameter
FROM
  `bigquery-public-data.idc_current.quantitative_measurements`
GROUP BY
  1, 2;

CREATE temp TABLE IF NOT EXISTS qualitative_pivoted AS
SELECT
  PatientID,
  SOPInstanceUID,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Subtlety score" THEN Value.CodeMeaning
    ELSE ""
  END) AS subtlety,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Internal structure" THEN Value.CodeMeaning
    ELSE ""
  END) AS internal_structure,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Calcification" THEN Value.CodeMeaning
    ELSE ""
  END) AS calcification,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Sphericity" THEN Value.CodeMeaning
    ELSE ""
  END) AS sphericity,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Margin" THEN Value.CodeMeaning
    ELSE ""
  END) AS margin,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Lobular Pattern" THEN Value.CodeMeaning
    ELSE ""
  END) AS lobulation,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Spiculation" THEN Value.CodeMeaning
    ELSE ""
  END) AS spiculation,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Texture" THEN Value.CodeMeaning
    ELSE ""
  END) AS texture,
  MAX(CASE
    WHEN Quantity.CodeMeaning = "Malignancy" THEN Value.CodeMeaning
    ELSE ""
  END) AS malignancy
FROM
  `bigquery-public-data.idc_current.qualitative_measurements`
GROUP BY
  1, 2;

SELECT
  quantitative_pivoted.*,
  qualitative_pivoted.* EXCEPT (PatientID, SOPInstanceUID)
FROM
  quantitative_pivoted
JOIN
  qualitative_pivoted
ON
  quantitative_pivoted.SOPInstanceUID = qualitative_pivoted.SOPInstanceUID
