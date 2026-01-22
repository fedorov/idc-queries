# BigQuery experiments/cookbook for derived data

**DISCLAIMER: none of those queries are claimed to be perfect, are optimized, or are guaranteed to be error-free\!** 

# 

[**Confirm each PatientID is included in a single collection	2**](#confirm-each-patientid-is-included-in-a-single-collection)

[**Check which UIDs are reused across instance/series/study	2**](#check-which-uids-are-reused-across-instance/series/study)

[**Select all segmentations with anisotropic pixel spacing and number of columns unequal to number of rows	3**](#select-all-segmentations-with-anisotropic-pixel-spacing-and-number-of-columns-unequal-to-number-of-rows)

[**Select segmentations that have more than 8 segments	4**](#select-segmentations-that-have-more-than-8-segments)

[**Get all segmentations that were generated with AUTOMATIC algorithm type	5**](#get-all-segmentations-that-were-generated-with-automatic-algorithm-type)

[**Get all the distinct combinations values describing anatomy/types of the available segmentations	6**](#get-all-the-distinct-combinations-values-describing-anatomy/types-of-the-available-segmentations)

[**TODO: Select all unique CodeSequence tuples as strings	6**](#todo:-select-all-unique-codesequence-tuples-as-strings)

[**Count segments	6**](#count-segments)

[**Select all unique lesions, as deduced from SeriesDescription (LIDC-specific, nodules clustered by pylidc)	7**](#select-all-unique-lesions,-as-deduced-from-seriesdescription-\(lidc-specific,-nodules-clustered-by-pylidc\))

[**Get all SR TIDs with counts	8**](#get-all-sr-tids-with-counts)

[**Get all types of quantitative measurements available	8**](#get-all-types-of-quantitative-measurements-available)

[**Get all volume measurements	9**](#get-all-volume-measurements)

[**Get all distinct types of qualitative measurements available	9**](#get-all-distinct-types-of-qualitative-measurements-available)

[**Get unique RTSTRUCT ROI names and count corresponding series	9**](#get-unique-rtstruct-roi-names-and-count-corresponding-series)

[**Get instances that have a specific ROIName in RTSTRUCT	10**](#get-instances-that-have-a-specific-roiname-in-rtstruct)

[**Get all qualitative measurements	10**](#get-all-qualitative-measurements)

[**Select quantitative and qualitative, pivot by measurement type, join by SOPInstanceUID	10**](#select-quantitative-and-qualitative,-pivot-by-measurement-type,-join-by-sopinstanceuid)

[**PET related explorations	13**](#pet-related-explorations)

[**Count number of series and distinct ImagePositionPatient values per series	14**](#count-number-of-series-and-distinct-imagepositionpatient-values-per-series)

[**Select all images that have multiple slices per ImagePositionPatient	14**](#select-all-images-that-have-multiple-slices-per-imagepositionpatient)

[**Find all non-SM multiframe series and sort by size	16**](#find-all-non-sm-multiframe-series-and-sort-by-size)

[Find series that exceed specific limit	17](#find-series-that-exceed-specific-limit)

[Get series-level folder URL for the selection	17](#get-series-level-folder-url-for-the-selection)

[**Annotations	18**](#annotations)

[Summarize modalities per collections and mark those that have SEG or RTSTRUCT	18](#summarize-modalities-per-collections-and-mark-those-that-have-seg-or-rtstruct)

[**Private tags	19**](#private-tags)

[Select b-value from the private GE Signa HDxt tag	19](#select-b-value-from-the-private-ge-signa-hdxt-tag)

[**Slide Microscopy (SM) Modality	19**](#slide-microscopy-\(sm\)-modality)

[Select distinct values of slide IDs	19](#select-distinct-values-of-slide-ids)

[Select DCM objects of slide	20](#select-dcm-objects-of-slide)

[Select width and height of DCM object	20](#select-width-and-height-of-dcm-object)

[Select pixel size / resolution / magnification of DCM object	20](#select-pixel-size-/-resolution-/-magnification-of-dcm-object)

[Select slides of project	21](#select-slides-of-project)

[Select base level DCM objects of slide	21](#select-base-level-dcm-objects-of-slide)

[Simplify access to WSI-related information	21](#simplify-access-to-wsi-related-information)

[Get all distinct combinations for the processing step names and values	22](#get-all-distinct-combinations-for-the-processing-step-names-and-values)

[Select slides based on the processing steps characteristics	24](#select-slides-based-on-the-processing-steps-characteristics)

[Exploration of channels in HTAN collections	24](#exploration-of-channels-in-htan-collections)

[Select series that have more than one value of FrameOfReferenceUID	26](#select-series-that-have-more-than-one-value-of-frameofreferenceuid)

[Sample values of TransferSyntaxUID	26](#sample-values-of-transfersyntaxuid)

[**Collection-specific queries	28**](#collection-specific-queries)

[RMS-Mutation-Prediction	28](#rms-mutation-prediction)

[List source files used for the conversion of DICOM SM slides	30](#list-source-files-used-for-the-conversion-of-dicom-sm-slides)

# 

# Confirm each PatientID is included in a single collection {#confirm-each-patientid-is-included-in-a-single-collection}

For Cosmin: run a query that selects distinct PatientID, grouping by PatientID, and aggregates distinct values of collection\_id per PatientID, or just counts the number of distinct collection\_id per PatientID, orders the result by those counts, or just filters only those PatientID that has count \> 1\.

| ``SELECT   dic_all.PatientID,   COUNT(DISTINCT(dic_all.collection_id)) as count_collection_id_list,   STRING_AGG(DISTINCT(dic_all.collection_id), ",") as collection_id_list FROM   `bigquery-public-data.idc_current.dicom_all` as dic_all GROUP BY PatientID HAVING count_collection_id_list > 1`` |
| :---- |

# Check which UIDs are reused across instance/series/study {#check-which-uids-are-reused-across-instance/series/study}

| ``WITH  take_them_all AS (  SELECT    collection_id,    SOPInstanceUID AS uid,    'SOPInstanceUID' AS what_uid  FROM    `bigquery-public-data.idc_current.dicom_all`  UNION ALL  SELECT    DISTINCT collection_id,    SeriesInstanceUID AS uid,    'SeriesInstanceUID' AS what_uid  FROM    `bigquery-public-data.idc_current.dicom_all`  UNION ALL  SELECT    DISTINCT collection_id,    StudyInstanceUID AS uid,    'StudyInstanceUID' AS what_uid  FROM    `bigquery-public-data.idc_current.dicom_all`) SELECT  uid,  COUNT(*) AS used_this_much,  STRING_AGG(DISTINCT(collection_id),",") AS in_collections,  STRING_AGG(DISTINCT(what_uid),",") AS used_where FROM  take_them_all GROUP BY  uid HAVING  used_this_much >1 ORDER BY  used_this_much desc`` |
| :---- |

# Select all segmentations with anisotropic pixel spacing and number of columns unequal to number of rows {#select-all-segmentations-with-anisotropic-pixel-spacing-and-number-of-columns-unequal-to-number-of-rows}

First, we select all series that have segmentations with the number of columns not equal to number of rows, and then from that we select series that have PixelSpacing components that are not equal.

Note that we select segmentations by specifying SOPClassUID in addition to Modality, since some series have SEG as Modality, but are not DICOM Segmentation objects (see [https://dicom.nema.org/medical/dicom/current/output/html/part04.html\#sect\_B.5](https://dicom.nema.org/medical/dicom/current/output/html/part04.html#sect_B.5) for the list of SOPClassUID values).

| ``WITH  uneq_with_spacing AS (  WITH    uneq AS (    SELECT      DISTINCT(collection_id),      PatientID,      SeriesInstanceUID    FROM      `bigquery-public-data.idc_current.dicom_all`    WHERE      Modality = "SEG"      AND SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"      AND `Rows` <> `Columns`)  SELECT    uneq.*,    dicom_all.SharedFunctionalGroupsSequence[  OFFSET    (0)].PixelMeasuresSequence[  OFFSET    (0)].PixelSpacing[  OFFSET    (0)] AS spacing_row,    dicom_all.SharedFunctionalGroupsSequence[  OFFSET    (0)].PixelMeasuresSequence[  OFFSET    (0)].PixelSpacing[  OFFSET    (1)] AS spacing_col  FROM    uneq  JOIN    `bigquery-public-data.idc_current.dicom_all` AS dicom_all  ON    uneq.SeriesInstanceUID = dicom_all.SeriesInstanceUID  WHERE    dicom_all.SharedFunctionalGroupsSequence IS NOT NULL) SELECT  * FROM  uneq_with_spacing WHERE  spacing_row <> spacing_col``  |
| :---- |

# Select segmentations that have more than 8 segments {#select-segmentations-that-have-more-than-8-segments}

8 is selected as an arbitrary threshold for the sake of query illustration. 

| ``WITH  seg_only AS (  SELECT    SOPInstanceUID,    PatientID,    collection_id,    SegmentSequence,    SeriesInstanceUID  FROM    `bigquery-public-data.idc_current.dicom_all`  WHERE    Modality = "SEG"    AND SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"    AND access = "Public") SELECT  DISTINCT(PatientID),  SeriesInstanceUID,  collection_id FROM  seg_only WHERE  ARRAY_LENGTH(SegmentSequence)>8``   |
| :---- |

# Get all segmentations that were generated with AUTOMATIC algorithm type {#get-all-segmentations-that-were-generated-with-automatic-algorithm-type}

* 

| ``SELECT  dicom_all.SeriesInstanceUID,  dicom_all.SOPInstanceUID,  segmentations.SegmentAlgorithmType FROM  `bigquery-public-data.idc_current.segmentations` as segmentations JOIN  `bigquery-public-data.idc_current.dicom_all` as dicom_all ON  dicom_all.SOPInstanceUID = segmentations.SOPInstanceUID WHERE  SegmentAlgorithmType = 'AUTOMATIC'`` |
| :---- |

# 

# Get all the distinct combinations values describing anatomy/types of the available segmentations {#get-all-the-distinct-combinations-values-describing-anatomy/types-of-the-available-segmentations}

* 

| `` SELECT  DISTINCT(AnatomicRegion.CodeMeaning) AS AnatomicRegion_cm,  AnatomicRegionModifier.CodeMeaning AS AnatomicRegionModifier_cm,  SegmentedPropertyCategory.CodeMeaning AS SegmentedPropertyCategory_cm,  SegmentedPropertyType.CodeMeaning AS SegmentedPropertyType_cm,  SegmentedPropertyType.AnatomicRegionModifierSequence[SAFE_OFFSET(0)].CodeMeaning AS SegmentedPropertyType_AnatomicRegionModifier_cm FROM  `bigquery-public-data.idc_current.segmentations` `` |
| :---- |

# TODO: Select all unique CodeSequence tuples as strings {#todo:-select-all-unique-codesequence-tuples-as-strings}

This is hard, since those code sequences will be hiding behind different sequence attributes

# Count segments  {#count-segments}

(this does not account for the same lesion segmented multiple times by the same reader)

* 

| ``WITH  lesionCount AS (  SELECT    PatientID,    ARRAY_LENGTH(SegmentSequence) AS perSeriesLesions  FROM    `bigquery-public-data.idc_current.dicom_all`  WHERE    Modality = "SEG"  ORDER BY    perSeriesLesions DESC) SELECT  PatientID,  SUM(perSeriesLesions) AS segmentsPerPatient FROM  lesionCount GROUP BY  PatientID ORDER BY  segmentsPerPatient DESC`` |
| :---- |

# Select all unique lesions, as deduced from SeriesDescription (LIDC-specific, nodules clustered by pylidc) {#select-all-unique-lesions,-as-deduced-from-seriesdescription-(lidc-specific,-nodules-clustered-by-pylidc)}

* 

| ``WITH nodulesAggregated AS ( WITH   withDistinctNoduleID AS (   WITH     withNoduleID AS (     SELECT       PatientID,       SAFE_CAST(REGEXP_EXTRACT(SeriesDescription, r"[0-9]+") AS NUMERIC) AS noduleID     FROM       `bigquery-public-data.idc_current.dicom_all`     WHERE       Modality = "SEG"       AND collection_id = "lidc_idri"       AND source_doi = "10.7937/TCIA.2018.h7umfurq"     ORDER BY       PatientID)   SELECT     DISTINCT(noduleID),     PatientID   FROM     withNoduleID ) SELECT   PatientID,   MAX(noduleID) OVER (PARTITION BY PatientID) AS maxLesionID,   COUNT(noduleID) OVER (PARTITION BY PatientID) AS numDistinctLesionIDs FROM   withDistinctNoduleID) SELECT # this is needed, since there will be one row for each patient/unique lesion ID combination otherwise DISTINCT(PatientID), numDistinctLesionIDs FROM nodulesAggregated #WHERE #  maxLesionID = numDistinctLesionIDs ORDER BY numDistinctLesionIDs DESC`` |
| :---- |

  * 

# Get all SR TIDs with counts {#get-all-sr-tids-with-counts}

* 

| ``WITH  ctsUnnested AS (  WITH    structuredReports AS (    SELECT      *    FROM      `bigquery-public-data.idc_current.dicom_all`    WHERE      Modality = "SR" )  SELECT    SOPInstanceUID,    contentTemplateSequence.TemplateIdentifier AS srTID  FROM    structuredReports  CROSS JOIN    UNNEST(ContentTemplateSequence) AS contentTemplateSequence ) SELECT  srTID,  COUNT(DISTINCT(SOPInstanceUID)) AS srTIDsCount FROM  ctsUnnested GROUP BY  srTID ORDER BY  srTIDsCount DESC`` |
| :---- |

# Get all types of quantitative measurements available {#get-all-types-of-quantitative-measurements-available}

* 

| `` SELECT  DISTINCT(Quantity.CodeMeaning) AS Quantity_cm,  Units.CodeMeaning AS Units_cm FROM  `bigquery-public-data.idc_current.quantitative_measurements` ``  |
| :---- |

  * 

# Get all volume measurements {#get-all-volume-measurements}

The actual volume measurement will be in the column “Value”.

* 

| ``SELECT  * FROM  `bigquery-public-data.idc_current.quantitative_measurements` WHERE  Quantity.CodeMeaning = "Volume"``  |
| :---- |

# Get all distinct types of qualitative measurements available {#get-all-distinct-types-of-qualitative-measurements-available}

`SELECT`  
 `DISTINCT(Quantity.CodeMeaning) AS Quantity_cm,`  
 `Value.CodeMeaning AS Value_cm`  
`FROM`  
 `` `bigquery-public-data.idc_current.qualitative_measurements` ``  
`ORDER BY`  
 `Quantity_cm`

# Get unique RTSTRUCT ROI names and count corresponding series {#get-unique-rtstruct-roi-names-and-count-corresponding-series}

* 

| ``SELECT  structureSetROISequence.ROIName AS ROIName,  COUNT(DISTINCT(SeriesInstanceUID)) AS ROISeriesCount FROM  `bigquery-public-data.idc_current.dicom_all` CROSS JOIN  UNNEST (StructureSetROISequence) AS structureSetROISequence WHERE  Modality = "RTSTRUCT" GROUP BY  ROIName ORDER BY  ROISeriesCount DESC``  |
| :---- |

# Get instances that have a specific ROIName in RTSTRUCT {#get-instances-that-have-a-specific-roiname-in-rtstruct}

| ``SELECT  SOPInstanceUID, PatientID,  structureSetROISequence.ROIName AS ROIName FROM  `canceridc-data.idc_views.dicom_all` CROSS JOIN  UNNEST (StructureSetROISequence) AS structureSetROISequence WHERE  Modality = "RTSTRUCT"  AND ROIName = "Heart"`` |
| :---- |

# Get all qualitative measurements {#get-all-qualitative-measurements}

* 

| `` SELECT SOPInstanceUID, Quantity, Value FROM `bigquery-public-data.idc_current.qualitative_measurements` `` |
| :---- |

# Select quantitative and qualitative, pivot by measurement type, join by SOPInstanceUID {#select-quantitative-and-qualitative,-pivot-by-measurement-type,-join-by-sopinstanceuid}

(since there is one instance of each measurement per SR instance, this approach will work for the LIDC collection)

TODO: demonstrate how to verify that the results are accurate on example instances

* 

|  ``CREATE TEMP TABLE IF NOT EXISTS quantitative_pivoted AS SELECT  PatientID,  SOPInstanceUID,  SUM(CASE      WHEN Quantity.CodeMeaning = "Volume" THEN SAFE_CAST(Value AS NUMERIC)    ELSE    0  END    ) AS volume,  SUM(CASE      WHEN Quantity.CodeMeaning = "Surface area of mesh" THEN SAFE_CAST(Value AS numeric)    ELSE    0  END    ) AS surface,  SUM(CASE      WHEN Quantity.CodeMeaning = "Diameter" THEN SAFE_CAST(Value AS numeric)    ELSE    0  END    ) AS diameter FROM  `bigquery-public-data.idc_v9.quantitative_measurements` GROUP BY  1,  2;   CREATE temp TABLE IF NOT EXISTS qualitative_pivoted AS SELECT  PatientID,  SOPInstanceUID,  MAX(CASE      WHEN Quantity.CodeMeaning = "Subtlety score" THEN Value.CodeMeaning    ELSE    ""  END    ) AS subtlety,  MAX(CASE      WHEN Quantity.CodeMeaning = "Internal structure" THEN Value.CodeMeaning    ELSE    ""  END    ) AS internal_structure,  MAX(CASE      WHEN Quantity.CodeMeaning = "Calcification" THEN Value.CodeMeaning    ELSE    ""  END    ) AS calcification,  MAX(CASE      WHEN Quantity.CodeMeaning = "Sphericity" THEN Value.CodeMeaning    ELSE    ""  END    ) AS sphericity,  MAX(CASE      WHEN Quantity.CodeMeaning = "Margin" THEN Value.CodeMeaning    ELSE    ""  END    ) AS margin,  MAX(CASE      WHEN Quantity.CodeMeaning = "Lobular Pattern" THEN Value.CodeMeaning    ELSE    ""  END    ) AS lobulation,  MAX(CASE      WHEN Quantity.CodeMeaning = "Spiculation" THEN Value.CodeMeaning    ELSE    ""  END    ) AS spiculation,  MAX(CASE      WHEN Quantity.CodeMeaning = "Texture" THEN Value.CodeMeaning    ELSE    ""  END    ) AS texture,  MAX(CASE      WHEN Quantity.CodeMeaning = "Malignancy" THEN Value.CodeMeaning    ELSE    ""  END    ) AS malignancy FROM  `bigquery-public-data.idc_v9.qualitative_measurements` GROUP BY  1,  2; SELECT  quantitative_pivoted.*,  qualitative_pivoted.* EXCEPT (PatientID,    SOPInstanceUID) FROM  quantitative_pivoted JOIN  qualitative_pivoted ON  quantitative_pivoted.SOPInstanceUID = qualitative_pivoted.SOPInstanceUID`` |
| :---- |

  * 

# PET related explorations {#pet-related-explorations}

The below may not be the right way to do it, per David Clunie, but …

| For LNQ Erik is working on the PET display calculations and wanted to have a robust implementation of SUV calculations. He worked from QIBA algorithms but did not have sample data. We used bigquery to search the headers to what kind of data is in IDC. It was fast and efficient to search and we were able to go back and forth between bq and the idc sandbox to see the images and look at the tags. This is a practical example that would have been very hard without IDC and it can be a candidate for an example. ``SELECT  StudyInstanceUID,  ANY_VALUE(Units) as Units,  ANY_VALUE(DecayCorrection) as DecayCorrection,  ANY_VALUE(CorrectedImage) as CorrectedImage FROM  `bigquery-public-data.idc_v9.dicom_all` WHERE  UNITS="PROPCNTS"  AND DecayCorrection="START"  AND "DECY" IN UNNEST(CorrectedImage)  AND "ATTN" IN UNNEST(CorrectedImage) GROUP BY  StudyInstanceUID`` |
| :---- |

# Count number of series and distinct ImagePositionPatient values per series {#count-number-of-series-and-distinct-imagepositionpatient-values-per-series}

This query can be useful in identifying image series that are not conventional 3d crossectional images. 

The WHERE clause is there to ignore images that are most likely problematic \- for example, some series may have ImagePositionPatient missing altogether, which will lead to NULL value in that column for the series.

| ``WITH  series_counts AS (  SELECT    SeriesInstanceUID,    ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID,    COUNT(DISTINCT(SOPInstanceUID)) AS instance_count,    COUNT(DISTINCT(ARRAY_TO_STRING(ImagePositionPatient,"/"))) AS position_count,    STRING_AGG(DISTINCT(SeriesDescription),",") AS series_desc  FROM    `bigquery-public-data.idc_current.dicom_all`    #  WHERE    #    collection_id = "prostatex"  GROUP BY    SeriesInstanceUID) SELECT  # skip some columns to improve readability of the result  * EXCEPT (SeriesInstanceUID, StudyInstanceUID),  instance_count/position_count AS instances_per_position,  # use this URL to see the specific series in IDC image viewer! CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/",StudyInstanceUID,"?seriesInstanceUID=",SeriesInstanceUID) AS viewer_url FROM  series_counts WHERE  position_count > 1 ORDER BY  instances_per_position DESC`` |
| :---- |

# Select all images that have multiple slices per ImagePositionPatient  {#select-all-images-that-have-multiple-slices-per-imagepositionpatient}

This can be used to identify 4D images.

| ``WITH  image_counts AS (  SELECT    SeriesInstanceUID,    ANY_VALUE(SeriesDescription) AS SeriesDescription,    ANY_VALUE(collection_id) AS collection_id,    ARRAY_TO_STRING(ImagePositionPatient,'/') AS ImagePositionPatient_str,    COUNT(DISTINCT SOPInstanceUID) AS sop_count,    ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID,    ANY_VALUE(Manufacturer) AS Manufacturer  FROM    `bigquery-public-data.idc_current.dicom_all`  GROUP BY    SeriesInstanceUID,    ImagePositionPatient ),  series_stats AS (  SELECT    SeriesInstanceUID,    ANY_VALUE(Manufacturer) AS Manufacturer,    MIN(sop_count) AS min_sop_count,    MAX(sop_count) AS max_sop_count,    COUNT(DISTINCT ImagePositionPatient_str) AS image_position_count,    ANY_VALUE(SeriesDescription) AS SeriesDescription,    ANY_VALUE(collection_id) AS collection_id,    ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID  FROM    image_counts  GROUP BY    SeriesInstanceUID ) SELECT  * EXCEPT(min_sop_count,    max_sop_count,    image_position_count),     min_sop_count AS slices_per_IPP,  # total number of slices per series  image_position_count*min_sop_count AS total_slices,  CONCAT("https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=",StudyInstanceUID,"&SeriesInstanceUIDs=",SeriesInstanceUID) AS ohif_v3_url FROM  series_stats WHERE  # make sure that for each value of ImagePositionPatient there is equal number of slices  min_sop_count = max_sop_count  # this is effectively the number of timepoints per position  AND min_sop_count >= 10  # and this is the number of spatial location imaged  #  - change this and the above to get more samples!  AND image_position_count > 20 ORDER BY slices_per_IPP DESC`` |
| :---- |

# Find all non-SM multiframe series and sort by size {#find-all-non-sm-multiframe-series-and-sort-by-size}

| ``WITH  temp_q AS (  SELECT    SeriesInstanceUID,    STRING_AGG(DISTINCT(Modality)) AS modalities,    COUNT(DISTINCT(SOPInstanceUID)) AS num_instances,    ANY_VALUE(NumberOfFrames) AS NumberOfFrames,    SUM(instance_size/POW(1024,3)) AS num_bytes,    ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID,    ANY_VALUE(SOPClassUID) AS SOPClassUID,    ANY_VALUE(CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/",StudyInstanceUID,"?seriesInstanceUID=",SeriesInstanceUID)) AS viewer_url  FROM    `bigquery-public-data.idc_current.dicom_all`  WHERE    Modality <> "SM"  GROUP BY    SeriesInstanceUID) SELECT  * FROM  temp_q WHERE  num_instances = 1 ORDER BY  num_bytes desc`` |
| :---- |

## *Find series that exceed specific limit* {#find-series-that-exceed-specific-limit}

`WITH`

`add_series_sizes AS (`

`SELECT`

`SeriesInstanceUID,`

`ROUND(SUM(instance_size)/POW(1024,3),2) AS series_size`

`FROM`

`` `bigquery-public-data.idc_current.dicom_all` ``

`WHERE`

`Modality <> "SM"`

`GROUP BY`

`SeriesInstanceUID)`

`SELECT`

`COUNT(DISTINCT(seriesInstanceUID)) as series_count,`

`series_size>1 AS larger_than_1gb`

`FROM`

`add_series_sizes`

`GROUP BY`

`larger_than_1gb`

# Get series-level folder URL for the selection {#get-series-level-folder-url-for-the-selection}

| ``SELECT ANY_VALUE(CONCAT("s5cmd cp s3",REGEXP_SUBSTR(gcs_url, "(://.*)/"),"/* .")) AS s5cmd_command FROM `bigquery-public-data.idc_current.dicom_all` AS dicom_all JOIN `bigquery-public-data.idc_current.dicom_metadata_curated_series_level` AS sm_attributes ON dicom_all.SeriesInstanceUID = sm_attributes.SeriesInstanceUID WHERE dicom_all.Modality = "SM" # select only series from the CPTAC-BRCA collection AND collection_id = "cptac_brca" AND sm_attributes.ObjectiveLensPower = 20 GROUP BY dicom_all.SeriesInstanceUID LIMIT 3`` |
| :---- |

# Annotations {#annotations}

## *Summarize modalities per collections and mark those that have SEG or RTSTRUCT* {#summarize-modalities-per-collections-and-mark-those-that-have-seg-or-rtstruct}

| ``WITH  all_modalities AS (  SELECT    collection_id,    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT(Modality)),",") AS Modalities,    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT(access)),",") AS access,  FROM    `bigquery-public-data.idc_current.dicom_all`  GROUP BY    collection_id) SELECT  *,  (CASE      WHEN Modalities LIKE "%SEG%" OR Modalities LIKE "%RTSTRUCT%" THEN "YES"    ELSE    "NO"  END    ) AS has_annotations FROM  all_modalities ORDER BY  has_annotations DESC`` |
| :---- |

# Private tags {#private-tags}

## *Select b-value from the private GE Signa HDxt tag* {#select-b-value-from-the-private-ge-signa-hdxt-tag}

| ``WITH  qpr AS (  SELECT    Manufacturer,    ManufacturerModelName,    ARRAY_TO_STRING(SoftwareVersions,"/"),    PatientID,    StudyDate,    StudyInstanceUID,    SeriesInstanceUID,    SeriesDescription,    SOPInstanceUID,    OtherElements  FROM    `bigquery-public-data.idc_current.dicom_all`  WHERE    collection_id = "qin_prostate_repeatability") SELECT  * EXCEPT(OtherElements, Tag),  other_elements.Tag, other_elements.Data[SAFE_OFFSET(0)] as b_value  FROM  qpr,  UNNEST(OtherElements) AS other_elements WHERE  other_elements.Tag = "Tag_00431039" ORDER BY  PatientID,  StudyDate`` |
| :---- |

# Slide Microscopy (SM) Modality {#slide-microscopy-(sm)-modality}

## *Select distinct values of slide IDs* {#select-distinct-values-of-slide-ids}

| `` SELECT  DISTINCT(ContainerIdentifier) FROM  `bigquery-public-data.idc_current.dicom_all` `` |
| :---- |

## *Select DCM objects of slide* {#select-dcm-objects-of-slide}

In the following, slide\_id should be replaced with any value from the result of the previous query, such as C3N-03928-22.

|  ``SELECT  gcs_url FROM  `bigquery-public-data.idc_current.dicom_all` WHERE  ContainerIdentifier = "<slide_id>"`` |
| :---- |

## 

## *Select width and height of DCM object* {#select-width-and-height-of-dcm-object}

| `SELECT     TotalPixelMatrixColumns AS width,     TotalPixelMatrixRows AS height FROM idc-dev-etl.idc_v3.dicom_all WHERE gcs_url="<gcs_url>"` |
| :---- |

## 

## *Select pixel size / resolution / magnification of DCM object* {#select-pixel-size-/-resolution-/-magnification-of-dcm-object}

Pixel size is returned in mm. Resolution equals 1 / pixel size. First value is row spacing in mm, second value is column spacing (see [DICOM PS3.3 2021b 10.7.1.3 Pixel Spacing Value Order and Valid Values](http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_10.7.html#sect_10.7.1.3)). Pixel size values for different magnifications are described [here](https://doi.org/10.4103/2153-3539.116866).

| `SELECT     CAST(SharedFunctionalGroupsSequence[OFFSET(0)].          PixelMeasuresSequence[OFFSET(0)].          PixelSpacing[OFFSET(0)] AS FLOAT64) AS pixel_size_y,     CAST(SharedFunctionalGroupsSequence[OFFSET(0)].          PixelMeasuresSequence[OFFSET(0)].          PixelSpacing[OFFSET(1)] AS FLOAT64) AS pixel_size_x FROM idc-dev-etl.idc_v3.dicom_all WHERE gcs_url="<gcs_url>"` |
| :---- |

## 

## *Select slides of project* {#select-slides-of-project}

| `SELECT DISTINCT(ContainerIdentifier) AS slide_id FROM idc-dev-etl.idc_v3.dicom_all WHERE ClinicalTrialProtocolID = "<project_id>"` |
| :---- |

## *Select base level DCM objects of slide* {#select-base-level-dcm-objects-of-slide}

| `WITH max_sizes AS (     SELECT         ContainerIdentifier,         FrameOfReferenceUID,         MAX(TotalPixelMatrixColumns * TotalPixelMatrixRows) AS max_size     FROM idc-dev-etl.idc_v3.dicom_metadata     WHERE         NOT (ContainerIdentifier IS NULL)     GROUP BY ContainerIdentifier, FrameOfReferenceUID  ) SELECT     b.ContainerIdentifier AS slide_id,     b.gcs_url FROM     -- ContainerIdentifier is not unique if slide was scanned twice.     -- Therefore, identify slides by both ContainerIdentifier and FrameOfReferenceUID.     max_sizes AS a JOIN idc-dev-etl.idc_v3.dicom_all AS b ON         b.ContainerIdentifier = a.ContainerIdentifier         AND b.FrameOfReferenceUID = a.FrameOfReferenceUID         AND a.max_size = b.TotalPixelMatrixColumns * b.TotalPixelMatrixRows` |
| :---- |

## *Simplify access to WSI-related information* {#simplify-access-to-wsi-related-information}

For Transfer Syntax UIDs see [DICOM PS3.3 2021b 8.7.3.1 Instance Media Types](http://dicom.nema.org/medical/dicom/current/output/chtml/part18/sect_8.7.3.html#table_8.7.3-2).

| ​`WITH slide_images AS (     SELECT         ContainerIdentifier AS slide_id,         PatientID AS patient_id,         ClinicalTrialProtocolID AS dataset,         TotalPixelMatrixColumns AS width,         TotalPixelMatrixRows AS height,         gcs_url, -- DICOM object URL in GCS bucket         CAST(SharedFunctionalGroupsSequence[OFFSET(0)].              PixelMeasuresSequence[OFFSET(0)].              PixelSpacing[OFFSET(0)] AS FLOAT64) AS pixel_spacing,         CASE TransferSyntaxUID             WHEN '1.2.840.10008.1.2.4.50' THEN 'jpeg'             WHEN '1.2.840.10008.1.2.4.91' THEN 'jpeg2000'             ELSE 'other'         END AS compression     FROM idc-dev-etl.idc_v3.dicom_all     WHERE NOT (ContainerIdentifier IS NULL) ) SELECT <columns from slide images view> FROM slide_images WHERE <condition>` |
| :---- |

## *Get all distinct combinations for the processing step names and values* {#get-all-distinct-combinations-for-the-processing-step-names-and-values}

`WITH`  
 `SpecimenPreparationSequence_unnested AS (`  
 `SELECT`  
   `gcs_url,`  
   `SOPInstanceUID,`  
   `ContainerIdentifier,`  
   `ARRAY_LENGTH(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence),`  
   `steps_unnested.SpecimenPreparationStepContentItemSequence AS steps_unnested1,`  
 `FROM`  
   `` `bigquery-public-data.idc_current.dicom_all` ``  
 `CROSS JOIN`  
   `UNNEST (SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested`  
 `WHERE`  
   `(collection_id = "tcga_lusc"`  
     `OR collection_id = "tcga_luad")`  
   `AND Modality = "SM"),`  
 `steps_unnested AS (`  
 `SELECT`  
   `SOPInstanceUID,`  
   `ContainerIdentifier,`  
   `gcs_url,`  
   `steps_unnested2.ValueType,`  
   `steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS conceptName_CodeMeaning,`  
   `steps_unnested2.TextValue AS text_value,`  
   `steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS code_value_CodeMeaning,`  
   `#*`  
 `FROM`  
   `SpecimenPreparationSequence_unnested`  
 `CROSS JOIN`  
   `UNNEST(steps_unnested1) AS steps_unnested2)`  
`SELECT`  
 `DISTINCT(conceptName_CodeMeaning) AS stepName_cm,`  
 `code_value_CodeMeaning AS stepValue_cm,`  
`FROM`  
 `Steps_unnested`

`Sample output`  
`![][image1]`

## *Select slides based on the processing steps characteristics* {#select-slides-based-on-the-processing-steps-characteristics}

Building upon the previous query, we can, for example, select all slides that were freeze-processed

`WITH`  
 `SpecimenPreparationSequence_unnested AS (`  
 `SELECT`  
   `gcs_url,`  
   `SOPInstanceUID,`  
   `ContainerIdentifier,`  
   `ARRAY_LENGTH(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence),`  
   `steps_unnested.SpecimenPreparationStepContentItemSequence AS steps_unnested1,`  
 `FROM`  
   `` `bigquery-public-data.idc_current.dicom_all` ``  
 `CROSS JOIN`  
 `UNNEST (SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested`  
 `WHERE`  
   `Modality = "SM"),`  
 `steps_unnested AS (`  
 `SELECT`  
   `SOPInstanceUID,`  
   `ContainerIdentifier,`  
   `gcs_url,`  
   `steps_unnested2.ValueType,`  
   `steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS conceptName_CodeMeaning,`  
   `steps_unnested2.TextValue AS text_value,`  
   `steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS code_value_CodeMeaning,`  
   `#*`  
 `FROM`  
   `SpecimenPreparationSequence_unnested`  
 `CROSS JOIN`  
   `UNNEST(steps_unnested1) AS steps_unnested2)`  
`SELECT`  
 `*`  
`FROM`  
 `steps_unnested`  
`WHERE`  
 `conceptName_CodeMeaning = "Embedding medium" and code_value_CodeMeaning = "Tissue freezing medium"`

## *Exploration of channels in HTAN collections* {#exploration-of-channels-in-htan-collections}

`WITH`  
`SpecimenPreparationSequence_unnested AS (`  
`SELECT`  
`gcs_url,`  
`collection_id,`  
`SOPInstanceUID,`  
`StudyInstanceUID,`  
`ContainerIdentifier,`  
`ARRAY_LENGTH(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence),`  
`steps_unnested.SpecimenPreparationStepContentItemSequence AS steps_unnested1,`  
`FROM`  
`` `bigquery-public-data.idc_current.dicom_all` ``  
`CROSS JOIN`  
`UNNEST (SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested`  
`WHERE`  
`Modality = "SM"),`  
`steps_unnested AS (`  
`SELECT`  
`SOPInstanceUID,`  
`StudyInstanceUID,`  
`collection_id,`  
`ContainerIdentifier,`  
`gcs_url,`  
`steps_unnested2.ValueType,`  
`steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS concept,`  
`steps_unnested2.TextValue AS text_value,`  
`steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS value,`  
`#*`  
`FROM`  
`SpecimenPreparationSequence_unnested`  
`CROSS JOIN`  
`UNNEST(steps_unnested1) AS steps_unnested2)`

`select *,`  
`concat("https://viewer.imaging.datacommons.cancer.gov/slim/studies/",StudyInstanceUID) as viewer_url`  
`from steps_unnested where collection_id LIKE "htan_hms" and concept = "Component investigated" and ValueType = "TEXT"`

~~`WITH`~~  
~~`SpecimenPreparationSequence_unnested AS (`~~  
~~`SELECT`~~  
  ~~`gcs_url,`~~  
  ~~`collection_id,`~~  
  ~~`SOPInstanceUID,`~~  
  ~~`StudyInstanceUID,`~~  
  ~~`ContainerIdentifier,`~~  
  ~~`ARRAY_LENGTH(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence),`~~  
  ~~`steps_unnested.SpecimenPreparationStepContentItemSequence AS steps_unnested1,`~~  
~~`FROM`~~  
  ~~`` #`bigquery-public-data.idc_current.dicom_all` ``~~  
  ~~`` `idc-dev-etl.idc_v10_pub.dicom_all` ``~~  
~~`CROSS JOIN`~~  
  ~~`UNNEST (SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested`~~  
~~`WHERE`~~  
  ~~`Modality = "SM"),`~~  
~~`steps_unnested AS (`~~  
~~`SELECT`~~  
  ~~`SOPInstanceUID,`~~  
  ~~`StudyInstanceUID,`~~  
  ~~`collection_id,`~~  
  ~~`ContainerIdentifier,`~~  
  ~~`gcs_url,`~~  
  ~~`steps_unnested2.ValueType,`~~  
  ~~`steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS concept,`~~  
  ~~`steps_unnested2.TextValue AS text_value,`~~  
  ~~`steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS value,`~~  
  ~~`#*`~~  
~~`FROM`~~  
  ~~`SpecimenPreparationSequence_unnested`~~  
~~`CROSS JOIN`~~  
  ~~`UNNEST(steps_unnested1) AS steps_unnested2)`~~

~~`#select distinct(collection_id) from steps_unnested`~~

~~`select distinct(concept), value from steps_unnested where collection_id LIKE "%tcga%"`~~

`#select *,`  
`#concat("https://testing-viewer.canceridc.dev/slim/studies/",StudyInstanceUID) as viewer_url`  
`# from steps_unnested where concept = "Component investigated" and value="CD163"`

`#select distinct(collection_id) from steps_unnested`

`#select *, concat("https://testing-viewer.canceridc.dev/slim/studies/",StudyInstanceUID) as viewer_url`  
`#from steps_unnested where collection_id = "htan_hms" and concept = "Component investigated"`

`#SELECT`  
`#DISTINCT(steps_unnested.conceptName_CodeMeaning) as code_meaning, steps_unnested.text_value, steps_unnested.code_value_CodeMeaning`  
`#from steps_unnested`  
`#order by code_meaning asc`

## *Select series that have more than one value of FrameOfReferenceUID* {#select-series-that-have-more-than-one-value-of-frameofreferenceuid}

`CREATE TEMP FUNCTION`  
 `array_distinct(value ANY TYPE) AS ((`  
   `SELECT`  
     `ARRAY_AGG(a.b)`  
   `FROM (`  
     `SELECT`  
       `DISTINCT *`  
     `FROM`  
       `UNNEST(value) b) a ));`  
`WITH`  
 `selection AS (`  
 `SELECT`  
   `SeriesInstanceUID,`  
   `any_value(StudyInstanceUID) as StudyInstanceUID,`  
   `COUNT(DISTINCT(FrameOfReferenceUID)) AS num_FoR,`  
   `ARRAY_AGG(ARRAY_TO_STRING(ImageType,"/")) AS image_types`  
 `FROM`  
   `` `bigquery-public-data.idc_current.dicom_all` ``  
 `WHERE`  
   `Modality = "SM"`  
 `GROUP BY`  
   `SeriesInstanceUID`  
 `ORDER BY`  
   `num_for DESC)`  
`SELECT`  
 `StudyInstanceUID,`  
 `SeriesInstanceUID,`  
 `num_FoR,`  
 `array_distinct(image_types),`  
 `concat("https://viewer.imaging.datacommons.cancer.gov/slim/studies/",StudyInstanceUID,"/series/",SeriesInstanceUID) as slim_url`  
`FROM`  
 `selection`  
`WHERE`  
 `num_FoR > 1`

## *Sample values of TransferSyntaxUID* {#sample-values-of-transfersyntaxuid}

`WITH`  
 `selection AS (`  
 `SELECT`  
   `TransferSyntaxUID,`  
   `ANY_VALUE(SOPInstanceUID) AS SOPInstanceUID,`  
 `FROM`  
   `` `bigquery-public-data.idc_current.dicom_all` ``  
 `WHERE`  
   `Modality = "SM"`  
 `GROUP BY`  
   `TransferSyntaxUID)`  
`SELECT`  
 `dicom_all.TransferSyntaxUID,`  
 `CASE dicom_all.TransferSyntaxUID`  
   `WHEN "1.2.840.10008.1.2.1" THEN "Explicit VR Big Endian"`  
   `WHEN "1.2.840.10008.1.2.4.50" THEN "JPEG Baseline (Process 1)"`  
   `WHEN "1.2.840.10008.1.2.4.90" THEN "JPEG 2000 Image Compression (Lossless Only)"`  
   `WHEN "1.2.840.10008.1.2.4.91" THEN "JPEG 2000 Image Compression"`  
`END`  
 `AS transferSyntax_readable,`  
 `dicom_all.StudyInstanceUID,`  
 `dicom_all.SeriesInstanceUID,`  
 `CONCAT("https://viewer.imaging.datacommons.cancer.gov/slim/studies/",StudyInstanceUID,"/series/",SeriesInstanceUID) AS slim_url`  
`FROM`  
 `selection`  
`JOIN`  
 `` `bigquery-public-data.idc_current.dicom_all` AS dicom_all ``  
`ON`  
 `selection.SOPInstanceUID = dicom_all.SOPInstanceUID`

An alternative query below will sample across modalities and encodings, and adjust the viewer URL as needed between Slim and OHIF

`WITH`  
`selection AS (`  
`SELECT`  
`TransferSyntaxUID,`  
`Modality,`  
`ANY_VALUE(SOPInstanceUID) AS SOPInstanceUID`  
`FROM`  
`` `bigquery-public-data.idc_current.dicom_all` ``  
`GROUP BY`  
`TransferSyntaxUID,`  
`Modality)`  
`SELECT`  
`dicom_all.TransferSyntaxUID,`  
`dicom_all.Modality,`  
`CASE dicom_all.TransferSyntaxUID`  
`WHEN "1.2.840.10008.1.2.1" THEN "Explicit VR Big Endian"`  
`WHEN "1.2.840.10008.1.2.4.50" THEN "JPEG Baseline (Process 1)"`  
`WHEN "1.2.840.10008.1.2.4.90" THEN "JPEG 2000 Image Compression (Lossless Only)"`  
`WHEN "1.2.840.10008.1.2.4.91" THEN "JPEG 2000 Image Compression"`  
`END`  
`AS transferSyntax_readable,`  
`dicom_all.StudyInstanceUID,`  
`dicom_all.SeriesInstanceUID,`  
`CASE dicom_all.Modality`  
`WHEN "SM" THEN CONCAT("https://viewer.imaging.datacommons.cancer.gov/slim/studies/",StudyInstanceUID,"/series/",SeriesInstanceUID)`  
`ELSE CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/",StudyInstanceUID,"?seriesInstanceUID=",SeriesInstanceUID)`  
`END`  
`AS viewer_url`  
`FROM`  
`selection`  
`JOIN`  
`` `bigquery-public-data.idc_current.dicom_all` AS dicom_all ``  
`ON`  
`selection.SOPInstanceUID = dicom_all.SOPInstanceUID`  
`ORDER BY`  
`TransferSyntaxUID, Modality`

# Collection-specific queries {#collection-specific-queries}

## *RMS-Mutation-Prediction* {#rms-mutation-prediction}

Merge information about annotations with the information about slides and clinical data

| ``WITH  annotations_details AS (  SELECT    PatientID,    StudyInstanceUID,    dicom_all.SeriesInstanceUID,    CurrentRequestedProcedureEvidenceSequence[SAFE_OFFSET(0)].ReferencedSeriesSequence[SAFE_OFFSET(0)].SeriesInstanceUID AS annotated_SeriesInstanceUID,    contentSequenceUnnested3.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning  FROM    `bigquery-public-data.idc_current.dicom_all` AS dicom_all  CROSS JOIN    UNNEST(ContentSequence) AS contentSequenceUnnested  CROSS JOIN    UNNEST(contentSequenceUnnested.ContentSequence) AS contentSequenceUnnested2  CROSS JOIN    UNNEST(contentSequenceUnnested2.ContentSequence) AS contentSequenceUnnested3  WHERE    dicom_all.analysis_result_id = "RMS-Mutation-Prediction-Expert-Annotations"    AND (contentSequenceUnnested3.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning = "Finding")),  rms_slides AS (  SELECT    DISTINCT(sm_metadata.SeriesInstanceUID) AS SeriesInstanceUID,    dicom_all.PatientID,    LEFT(dicom_all.PatientAge, LENGTH(dicom_all.PatientAge) - 1) as PatientAge,    dicom_all.StudyInstanceUID,    sm_metadata.* EXCEPT (SeriesInstanceUID)  FROM    `bigquery-public-data.idc_current.dicom_metadata_curated_series_level` AS sm_metadata  INNER JOIN    `bigquery-public-data.idc_current.dicom_all` AS dicom_all  ON    sm_metadata.SeriesInstanceUID = dicom_all.SeriesInstanceUID  WHERE    dicom_all.collection_id = "rms_mutation_prediction"    AND dicom_all.Modality = "SM"  ORDER BY    sm_metadata.SeriesInstanceUID    ) SELECT  rms_slides.*,  sample.* EXCEPT (dicom_patient_id,    participantparticipant_id),  diagnosis.* EXCEPT (dicom_patient_id,    participantparticipant_id),  demographics.* EXCEPT (dicom_patient_id),  annotations_details.* EXCEPT (SeriesInstanceUID),  annotations_details.SeriesInstanceUID AS annotation_SeriesInstanceUID FROM  rms_slides LEFT OUTER JOIN  annotations_details ON  rms_slides.SeriesInstanceUID = annotations_details.annotated_SeriesInstanceUID JOIN  `bigquery-public-data.idc_current_clinical.rms_mutation_prediction_sample` AS sample ON  rms_slides.PatientID = sample.dicom_patient_id JOIN  `bigquery-public-data.idc_current_clinical.rms_mutation_prediction_diagnosis` AS diagnosis ON  rms_slides.PatientID = diagnosis.dicom_patient_id JOIN  `bigquery-public-data.idc_current_clinical.rms_mutation_prediction_demographics` AS demographics ON  rms_slides.PatientID = demographics.dicom_patient_id ORDER BY  rms_slides.SeriesInstanceUID ``  |
| :---- |

## *List source files used for the conversion of DICOM SM slides* {#list-source-files-used-for-the-conversion-of-dicom-sm-slides}

| ``WITH  count_instances AS (  SELECT    ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID,    SeriesInstanceUID,    COUNT(DISTINCT(SOPInstanceUID)) AS num_instances,    STRING_AGG(DISTINCT(collection_id)) AS collection,    SAFE_CAST(ANY_VALUE(NumberOfFrames) AS NUMERIC) AS num_frames,    ANY_VALUE(OtherElements) AS other_elements  FROM    `bigquery-public-data.idc_current.dicom_all`  WHERE    Modality = "SM"  GROUP BY    SeriesInstanceUID  HAVING    num_instances =1 ) SELECT  SeriesInstanceUID,  num_instances,  collection,  num_frames,  other_elements.Data[SAFE_OFFSET(0)] AS source_file_path,  CONCAT("https://viewer.imaging.datacommons.cancer.gov/slim/studies/",StudyInstanceUID,"/series/",SeriesInstanceUID) AS idc_viewer_url FROM  count_instances,  UNNEST(other_elements) AS other_elements WHERE  num_instances = 1  AND other_elements.Tag = "Tag_00091001" ORDER BY  num_frames DESC``  |
| :---- |

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAaEAAAKDCAYAAACzJLViAACAAElEQVR4XuydCbxW0/7//TMlSS7JcDPPZCZDV1wJKXFp0ChNojRQEhUJpVBUhFKKTBUVZag0KIqIkkq6DRqUmYtLd/3v++u39l1nnWfv5zn7nN1zztP3/XqtV/vZ49prfdf3s9Z37dPa4d///rch/fOf/zSKoiiKsi3ZwRUhTZo0adKkaVumPCKkKIqiKNsSFSFFURQla6gIKYqiKFlDRUhRFEXJGipCiqIoStZQEVIURVGyhoqQoiiKkjVUhBRFUZSsoSKkKIqiZA0VIUVRFCVrqAgpiqIoWUNFSFEURckaWRWhn376yXz66afmhx9+yLP/X//6l/nwww/NunXr8uyHL774Qq4hrVq1yvznP//xTwngPpz33XffyW+uXbFiRZ5z/vjjDznnq6++kt+bNm0K7u8mP49r1641H330kfnll1/y7Oc8e83SpUvN999/n/I4eUnFsmXL5Pivv/6aZz+/2e/e7+uvv86XT5s+//xzOeezzz4zX375ZXCNJV3+bZlZNm7cKPujyruksHWrMYs++zlI6zb+FnncpiXL/5XnvB9+/sPM/fAH8891v5qtTrEs/u95azfkveea9b8F13//4x9yvx/++6/lX79szfc8N/379/89YMNX/5bnbtry72BfrhHmG2if77//vtm8eXOe/ZYw37H1v5XK/davX59nv7V3npcLuP7RTfiPlStXik9y27At5w0bNgRl5Cd8ksvPP/9sPvjgA7NkyRLz22//s3Prj9ATC8fZx7Ewf5VVEVq0aJGpX7++ee+994J9Y8eONQ0bNjQNGjSQYx06dDBbtmwJjt96662y36brrrvOPPzww3le3ILgcM706dPlt732k08+Cc758ccfZR/PhVGjRuW5v00LFiyQ4zSC9u3byz7ySF5feuml4H6c517HObfffruZO3dunuONGjXK18BWr14dXLdmzZo8x6ZOnSr7R4wYEex75ZVX8uXTJvIIjRs3NoMHDw6uyTT/d955Zx5jfeqpp2Q/ol3S+elfW031axfnSU26rjAjx28KPU6q0/ZTOf7t93+YLvf/09S47lNzScslcuyme76Q/VCrzVJz32N5neA9j641tdv8ef07C7+Xa9796Mfg+NIv/pXveW766ut/i4i1uuNz+W2fO+jp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t95q7r//fnPjjTeaevXqmUmTJuU7N+kUJ/9R6c033zRt2rQxP/30U75jmaapU6dK+fTo0SPYt3HjRtk3ZcqUfOdryr1U1HZ5yy23mHHjxuXbn2maP3++2N+cOXOCfZs3bzb169c3w4cPz3e+m1SEtu9U1LZsU5GI0LRp04J9t99+u2nXrl3wG6fLcRLGzr7ly5dLj8ye884775gNGzbI9ueffy6//WelS3Hyb9PSpUvN66+/br788kv5vXLlSvPII48E78bohf2bNm2S3zNmzAj2LVu2zCxYsMB888035o033jCffPJJcF8rQiTuz75UIvTBBx+YV1991XzxxRfBPu773nvvSY+VESbnsH/hwoXyHFuWpJ9//lmeyz14F/fdUiWEde7cuXnuwz14L8pgxYoVkl/ySuK8RYsW5buPpvQprl3++OOPYlczZ840X3/9teybNWuWadq0qenbt29gZ2F1//7778vvdevWia2tWbNG9lP3LVq0MAMHDgzOpX6xSXs9bRE7px1+9913wXlWhMgbtmLvSbvgt2tLqfIUlriO5yGMP/zwg+zD7rgn9m/LgefSNnkffI9/H03Jpri2nC4VuQjdc889plOnTrKNATZp0sRcf/31YsCtWrWScB0GRc8Lx43B161b1zz33HNyzUMPPWTuuuuufM9Kl+LknzRkyBDTsmVLyfc111wjIyAae4cOHeTdyAt5xDE3a9bMtG/f3jRv3lzekcY2atQo06hRI2nYjJx4F96Pe1sRGjBggLw/jdUXIcSO+/bu3ds0bNjQvPTSS7Lf3pey45lc06tXL9kmv5xrG/3QoUMl7126dJGR6Ntvv53vPd3Up08f06BBAzmf6+gQ0MB5Bu/Au/NsnkWy9yWM6N9LU3SKY5cIxU033WQ6d+5s7rjjDqkj7nPfffdJvd1www3BaCis7m+77TZz3XXXmdatW0sbJFnReOKJJ8TmqHN+Y/vUOdt0frBVrmcftm47XFaEEEVsBfFiPx0Ufn/66aeReUqVsGHyyL3pvPIvbQTh4Z5t27aVcqBd0cG19snvd999N9/9NCWX4thyJqlIRKh///7m+eeflx4a4kIPiOMYDQljx3Bx1K+88ooYHsaJoXEuDo+QHtdgdOli06lSnPzT66JRv/zyy/Kb3j+xcbYJKfJuNhx35513ikNgm0bCezKvg1jQO127dq28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uUJStqwipCgJonap5ApJ2XKxECEWN7v11ltlga6VK1fmO55JiltALMDGs0n33XefWbx4sX9KseGll17Ks+SzUvyJa5esE8US5TfddJPp169f7Pukg9WAWco8G7CwIsvbsyjjhg0b/MMpcRdhPO6448zbb7/tnRGPTz75xDz00EP+bsUhKRvMugiNGDFCjGnYsGGmW7dusqomSxj756VLcQuIlVWvu+46WY0TEWQ10auvvto/rVgwefJkM336dH93LCgzVlnlXyU54tgl7fHkk082V111lRkzZozp3LmzrNibxBpSrBwbJ4+FhZVi999/fxFYVoll9eLZs2f7p+WjqETIt3/K1l1VWMlPUnaSdRFiyezx48cHv0855RTp8fvnpUtxC8hf3pvVPcuXLy+9w+XLl5v33nvPvPnmm5Lgl19+MVOnTjXDhw83q1atCq4DenM4DZZbdmHVUO6D0C5ZsiTPsY8//tiMHDnSfPnll3n285v9HLcwYrQjtTlz5sg705tkmWe79LcFseJ5vMeUKVPyrNDKWkSjRo2Spa55d/LNMtruyqbUyZYtW+Q5q1evNhMmTJB39nus3B8BnzFjRp79yp/EscsPP/zQlC5dWuza0qxZM3HWdNCwP8qd+rV2aWEExWj5qaeeMps2bQr2//HHH/IX79T3119/HezHNlg+HKjzjRs3mtGjR4s9YFPUN7bCEuwuYc/BTrg/15NPnuuDDZcqVSrPdYMHDzaXX3558BvbY4l7kmu7USIUZot+u/Ttn2etWbMmTwcvrJ2na3e5TBxbzoSsi5CbWJK5UqVK5qOPPsp3LF2KW0C+CNFo6KG9//770kvcZ599TNWqVc2TTz4pTrpKlSrB6GmvvfYKGid5rlChgmnZsqWpU6eOufDCC4N70pM9/fTT5V/ubXt8t99+u9yre/fu8t6TJk2S/W+88YY5/PDDTY8ePcwZZ5whIQtwG+A//vEPc/TRR5vWrVubevXqSU/ZLiv+4IMPmj333NO0b9/eXHDBBWb33XfPE2Zcv369PJtGyL9r1641J554ojgOWLFihSlbtqyUK8859NBDTYcOHcy5555r9ttvv8Ap4HAOOuggyd+xxx4rvVolL3HskqW7sYf+/fvnW76dTgl1c9FFF5l27dqZPfbYw9x///1yDMdJHVFnzZs3l3v88MMPcqxp06bmhBNOkLo6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SMJevKcdsSECNEregfALHw1YwkQDmHzmvRBlnAE9ZMI75IcwBx8pQCYiBLz77rvvLiEXRm32iywVof+JEPVMqNKO2MNECOHhPOwYh82Xk+DbSlTdE47jYwJsjg8ObAguzK4BsaCDduCBB8qXpbZurQhh61xHtIPoA/C1JR0iPmQgz4yK/S/W6OzwJxu8D50xa1thIkT5cJ/ddttN5hoRQzsnlMnzlGji2HImFAsRKopU2ALiHowcXKwjpHzcz7Nd7FdsPvS43E+RCwvPSfX1WyZwXVjogfCN/97p4F5uXii7wsDzS/Jn2FEU1i7jEGaTPlF1H1YfYXZtP1xxccNhdgTiQx7SiQHnpHpmGKlCkpZMnqekJilbVhGKIFd640r2SMIuSwr+nJBSsknKllWEIiB2zjBeUeKShF2WFPighvleJTdIypZVhBQlQdQulVwhKVtWEVKUBFG7VHKFpGxZRUhREkTtUskVkrJlFSFFSRC1SyVXSMqWVYQUJUHULpVcISlbziNCmjRpKtrEMhr+Pk2aSmLClpNAR0KKkiBql0qukJQtqwgpSoKoXSq5QlK2rCKkKAmidqnkCknZsoqQoiSI2qWSKyRlyypCipIgapdKrpCULasIKUqCqF0quUJStqwipCgJonap5ApJ2XKxECFWaOzWrZsstR03H3EL6K677gqWlLawYJdd/C0MVjtlieBsoctMlAzi2mVJxF1gLoow23UXq8sGn3zyiawguy3JxjPjkpQtZ12EWA2SlRxZtrp79+6ygigLYPnnpUtxC4gGweqlLpUqVQpWSg2DtVLiPrMoCGvIUSCcJGXbkQ0bmT59erAs97akpIsQeXr88cf93bHItK0V5TOTJilbzroIsax1hw4dgt+VK1c2kyZNyndeuhS3gNKJECs6Tps2zbz44ot5VoecMmWKNBqYMGGCLH/Mkt9Tp07NswokSxSPGDFCziGPYX91zLLWI0eONB9//HGwDwN97733gt8sRW7zSr459vTTT8tzf/nll+C8VHmePXu2qV27tiS7HDT1TlmPGjUqeBdYvny5WbBggTxv+PDhwZLbFpY/5538keCWLVvMM888I8/V1Sv/JI5dUlerVq2SbVawfemll4JjjNDnzJkj26nqb9myZebWW281hx9+uNSDhbp64oknzIwZM4J91DM29Oabb0rywXYQFkTNtWny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>