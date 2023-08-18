# Refined Fuel Poverty Risk

**Author:** Richard Blackwell **Date:** 2023-06-27

A refinement of the **[Department of Energy Security and Net Zero - Sub-regional fuel poverty in England 2023](https://www.gov.uk/government/statistics/sub-regional-fuel-poverty-data-2023-2021-data)** using **[NOMIS - Census 2021 data](https://www.nomisweb.co.uk/sources/census_2021)** and **[Office for National Statistics - Open Geography Portal](https://geoportal.statistics.gov.uk/)**

### Acknowledgements

Source: Department of Energy Security and Net Zero

Source: NOMIS Official Census and Labour Market Statistics

Source: Office for National Statistics licensed under the Open Government Licence v.3.0


## Methodology

+ Datasets
  + Source: Department of Energy Security and Net Zero
    + Data: Sub-regional Fuel Poverty 2023
      + Measure: Proportion of households at risk of fuel poverty (from total number of households and number of households at risk)
      + Period: 2021
      + Geography: Lower-layer Super Output Area (LSOA) 2021
  + Source: NOMIS
    + Data: Household Deprivation
      + Measure: Number households deprived in zero, 1, 2, 3 or all 4 dimensions
      + Period: 2021 Census
      + Geography: Output Area (OA) 2021
  + Source: Office for National Statistics
    + Data: Census Output Area (OA) 2021 to LSOA 2021 lookup

### Gathering the data

The first step is to obtain the data from the relevant organisations, provided in this repository are the relevant downloads required to refine the fuel poverty measure but if updates are required or you wish add other data to enhance the process the links above will take you to the main pages for the data from those organisations.

### Standardising geography areas

The next step is to ensure that we has consistancy across geographical areas. The fuel poverty data is at LSOA level and the census data is at OA level. If we use the same fuel poverty data for the constituent output areas of the lower-layer super output area we will then have all our data at output area.

In order to do this we join the output area to lower-layer super output area lookup data to the fuel poverty data to add in the output area detail.

### Processing the data

The penultimate step is to convert the data into a ranking, this is done simply by ordering the data in descending order (the area ranked 1 has the highest need) by fuel poverty risk and then the proportion of households deprived in all 4 dimensions, 3, 2 and only 1.

### Combining the data

The final stage is to add an overall rankings. In addition to the rank we will also calculate the deciles for each metric and overall for use in choropleth mapping.