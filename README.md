# Fuel Poverty Programme

### Author: Richard Blackwell

### Email: richard.blackwell@swahsn.com

### Date: 2023-08-18

----

## Data

### Fuel Poverty data

Source: [Department for Energy Security and Net Zero](https://www.gov.uk/government/organisations/department-for-energy-security-and-net-zero)

Landing Page: [Sub-Regional Fuel Poverty Data](https://www.gov.uk/government/statistics/sub-regional-fuel-poverty-data-2023-2021-data)

Example Data: [2023 publication (2021 data)](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1153252/sub-regional-fuel-poverty-tables-2023-2021-data.xlsx)

Notes: Total number of households and number of those households in fuel poverty by 2021 Lower-layer Super Output Areas (LSOA 2021) using 2021 modelled data.

### Household Deprivation data

Source: [NOMIS](https://www.nomisweb.co.uk/sources/census_2021)

Landing Page: [2021 Census Bulk Data Download](https://www.nomisweb.co.uk/sources/census_2021_bulk)

Example Data: [TS011 - Households by deprivation dimensions](https://www.nomisweb.co.uk/output/census/2021/census2021-ts011.zip)

Notes: The `census2021-ts011-oa.csv` file in the zip file is the file used in the calculation and contains the household deprivation data at 2021 Output Area (OA 2021) level.

### 2021 Output Area to 2021 Lower-layer Super Output Area lookup data

Source: [ONS Open Geography Portal](https://geoportal.statistics.gov.uk/)

Landing Page: [Output Area (2021) Lookups](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(LUP_OA_2021))

Example Data: [December 2021 data](https://geoportal.statistics.gov.uk/datasets/ons::output-area-to-lower-layer-super-output-area-to-middle-layer-super-output-area-to-local-authority-district-december-2021-lookup-in-england-and-wales-v3/explore)

Notes: The OA (2021) to LSOA (2021) data is used to link the fuel poverty data (published at LSOA 2021 level) to household deprivation data (published at OA 2021 level)

### Sub ICB Locations to Integrated Care Boards to NHS England Region Lookup

Source: [ONS Open Geography Portal](https://geoportal.statistics.gov.uk/)

Landing Page: [Sub ICB Locations to to Integrated Care Boards to NHS England Regions](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(LUP_SICBL_ICB_NHSER))

Example Data: [April 2023 data](https://geoportal.statistics.gov.uk/datasets/ons::sub-icb-locations-to-integrated-care-boards-to-nhs-england-region-april-2023-lookup-in-england/explore)

Notes: This data is used to create the postcode to refined fuel poverty risk for individual ICB by NHS England Region output files

### ONS Postcode data

Source: [ONS Open Geography Portal](https://geoportal.statistics.gov.uk/)

Landing Page: [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD%2CMAY_2023))

Example Data: [May 2023 data](https://geoportal.statistics.gov.uk/datasets/ons-postcode-directory-may-2023/about)

Notes: The `ONSPD_MAY_2023_UK.csv` file in the `Data` directory in the zip file is is used to map active postocde to Output Area 2021 in order to map patient's postcodeto fuel poverty risk.

----

## Methodology

The fuel poverty risk is defined as the percentage of households in each Lower-layer Super Output Area (2021) deemed to be fuel poor and this is linked to the 2021 Census household deprivation data using the output area to lower-layer super output area lookup. This linked data is then ordered in the following way

 - Percentage of households deemed to by fuel poor in **descending** order (LSOA level)
 - Percentage of households deemed to be deprived in all four dimensions of household deprivation used in the 2021 census; education, employment, health and housing in **descending** order (OA level)
 - Percentage of households deemed to be deprived in three of the four dimensions of household deprivation in **descending** order (OA level)
 - Percentage of households deemed to be deprived in two of the four dimensions of household deprivation in **descending** order (OA level) 
 - Percentage of households deemed to be deprived in one of the four dimensions of household deprivation in **descending** order (OA level) 
  - Percentage of households deemed to be deprived in none of the four dimensions of household deprivation in **ascending** order (OA level) 

A ascending rank is then applied to this order list so the first output area listed (rank = 1) will be the most at risk in terms of the refined fuel poverty indicator (i.e fuel poverty and deprivation) and the last output area listed (rank = 178,605) will be the least at risk.

For each NHS England region the and for each Integrated Care Board in that region the postcode that are in that area are matched to the refined fuel poverty risk by using the output area and these list are output as comma separated value (csv) files

----

## Outputs

### Full refined fuel poverty risk data

The file fp_refined.csv in the fp_refined.zip file consisted of the following fields

 - `oa21cd`, `lsoa21cd` and `msoa21cd`	- 2021 Output Area, Lower-Layer Super Output Area and Middle-layer Super Output Area codes respectively
 - `lad22nm` - 2022 Local Authority Name 
 - `households_lsoa` - Number of households in LSOA from fuel poverty data	
 - `households_in_fp` - Number of households in LSOA deemed to be fuel poor
 - `fp_pct` - Percentage of households in LSOA deemed to be fuel poor
 - `households_oa` - Number of households in OA from census household deprivation data
 - `hd_pct_0`, `hd_pct_1`, `hd_pct_2`, `hd_pct_3` and `hd_pct_0` - Percentage of households deprived in OA deprived in 0, 1, 2, 3 and all 4 dimensions respectively
 - `fp_rank` - Rank of percentage of households in LSOA deemed to be fuel poor (where rank 1 is the LSOA with the highest percentage of households deemed to be fuel poor)
 - `hp4_rank`, `hp3_rank`, `hp2_rank` and `hp1_rank` - Rank of percentage of households in OA deprived in all 4, 3, 2 and 1 dimension respectively (where rank 1 is the OA with the highest percentage of households deprived in that number of dimensions)
 - `hp0_rank`	- Rank of percentage of households in OA not deprived in any dimension (where rank 1 is the OA with the **lowest** percentage of households not deprived in any dimension)
 - `overall_rank`	
 - `fp_decile`	
 - `hp4_decile`	
 - `hp3_decile`	
 - `hp2_decile`	
 - `hp1_decile`	
 - `hp0_decile`	
 - `overall_decile`

