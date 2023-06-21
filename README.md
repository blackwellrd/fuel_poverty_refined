# Refined Fuel Poverty Risk

**Author:** Richard Blackwell **Date:**   2023-06-21

A refinement of the **[Department of Energy Security and Net Zero - Sub-regional fuel poverty in England 2023](https://www.gov.uk/government/statistics/sub-regional-fuel-poverty-data-2023-2021-data)** using **[Department of Work and Pensions - StatXplorer data for Universal and Pension Credit](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml)** and **[Office for National Statistics - Open Geography Portal](https://geoportal.statistics.gov.uk/)**

### Acknowledgements

Source: Department of Energy Security and Net Zero

Source: Department of Work and Pensions

Source: Office for National Statistics licensed under the Open Government Licence v.3.0


## Methodology

+ Datasets
  + Source: Department of Energy Security and Net Zero
    + Data: Sub-regional Fuel Poverty 2023
      + Measure: Proportion of households at risk of fuel poverty (from total number of households and number of households at risk)
      + Period: 2021
      + Geography: Lower-layer Super Output Area (LSOA) 2021
  + Source: Department of Work and Pensions
    + Data: Universal Credit
      + Measure: Number of people receiving Universal Credit in that month
      + Period: Jun-22 to May-23 (monthly)
      + Geography: Output Area (OA) 2011
    + Data: Pensions Credit
      + Measure: Number of people receiving Pension Credit as at end of quarter
      + Period: Feb-22 to Nov-22 (quarterly)
      + Geography: Output Area (OA) 2011
  + Source: Office for National Statistics
    + Data: Lower-layer Super Output Area (LSOA) 2011 to 2021 lookup
    + Data: Census Output Area (OA) 2011 to LSOA 2011 lookup

### Gathering the data

The first step is to obtain the data from the relevant organisations, provided in this repository are the relevant downloads required to refine the fuel poverty measure but if updates are required or you wish add other data to enhance the process the links above will take you to the main pages for the data from those organisations.

### Standardising geography versions

As the datasets use different versions of the census output areas (2011) and (2021) the second step is to convert the Sub-regional Fuel Poverty data from LSOA (2021) to LSOA (2011). The Sub-regional Fuel Poverty data consists of the number of households in the LSOA and the number of households at risk of fuel poverty in that LSOA

The census output areas change every 10 years, some of the output areas are unchanged, some are split into two or more new output areas, some are merged with one or more output areas to create a new output area and some have complex boundary changes.

For those areas that are unchanged the same fuel poverty values will be used for the LSOA (2011) as the LSOA (2021).

For those 2011 areas that were merged into a new 2021 area the fuel poverty values will be used for the LSOA (2011) as the LSOA (2021), as essentially the 2011 areas created the 2021 area.

For those 2011 areas that were split into a new 2021 areas the fuel poverty values of the new 2021 areas will be combined and those values will be used for the LSOA (2011) as the LSOA (2021), as essentially the 2011 areas created the multiple 2021 areas.

For those 2011 areas that have complex boundary changes the fuel poverty values will be used for the LSOA (2011) as the LSOA (2021), as the complex changes are more boundary tweaks rather than splits or mergers.

### Standardising geography areas

The third step is to ensure that we has consistancy across geographical areas. The fuel poverty data is at LSOA level and the Universal Credit and Pension Credit is at OA level. If we use the same fuel poverty data for the constituent output areas of the lower-layer super output area we will then have all our data at output area.

In order to do this we join the output area to lower-layer super output area lookup data to the fuel poverty data to add in the output area detail.

### Processing the data

The penultimate step is to convert the data into a ranking, this is done simply by ordering the data in descending order (the area ranked 1 has the highest need) in turn for each of the metrics, i.e. fuel poverty, universal credit and pension credit.

### Combining the data

The final stage is to combine the rankings into one overall ranking. This is done by summing the rank for each of the metrics and then ordering by that sum in descending order and calculating the new overall rank. In addition to the rank we will also calculate the decile for use in choropleth mapping. 
