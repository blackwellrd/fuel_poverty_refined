#*******************************************************************#
#                                                                   #
# File: fuel_poverty_refined.R                                      #
# Desc: Refine the BEIS sub-regional fuel poverty England 2022 with #
#       the NOMIS 2021 Census data on household deprivation.        #
# Auth: Richard Blackwell                                           #
# Date: 2027-06-18                                                  #
#                                                                   #
#*******************************************************************#

# 1. Load libraries ----
# **********************
library(tidyverse)
library(readxl)

# 2. Load data ----
# *****************

# These file locations should be altered to reflect the local installation
fuel_poverty_workbook <- './data/sub-regional-fuel-poverty-tables-2023-2021-data.xlsx'
fuel_poverty_worksheet <- 'Table 3'
household_deprivation_csvfile <- './data/census2021-ts011-oa.csv'
output_area_lookup_file <- './data/Output_Area_to_Lower_layer_Super_Output_Area_to_Middle_layer_Super_Output_Area_to_Local_Authority_District_(December_2021)_Lookup_in_England_and_Wales_v3.csv'
icb_lookup_file <- './data/Sub_ICB_Locations_to_Integrated_Care_Boards_to_NHS_England_(Region)_(April_2023)_Lookup_in_England.csv'
postcode_file <- './data/ONSPD_MAY_2023_UK.csv'
outputdir <- './output'

# * 2.1. Fuel poverty ----
# ````````````````````````
# Read in the LSOA level fuel poverty data from the Table 3 worksheet 
# ignoring the first 2 lines. Select only the essential fields and rename them, 
# and finally filter to English LSOAs only
df_fp <- read_excel(path = fuel_poverty_workbook, 
                    sheet = fuel_poverty_worksheet,
                    skip = 2) %>%
  select(1, 6:7) %>%
  rename_with(.fn = ~c('lsoa21cd', 'households', 'households_in_fp')) %>%
  filter(grepl('^E',lsoa21cd))

# * 2.2. Household deprivation ----
# `````````````````````````````````
# Read in the OA level household deprivation data, select only the essential
# fields and rename them. Finally calculate the percentage of households deprived 
# in zero through to all four domains.
df_hd <- read.csv(household_deprivation_csvfile, header = TRUE) %>% 
  select(-c(1, 3)) %>%
  rename_with(.fn = ~c('oa21cd', 'households', 'dim_0', 'dim_1', 'dim_2', 'dim_3', 'dim_4')) %>%
  mutate(across(.cols = 3:7, .fns = ~.x/households, .names = 'pct_{.col}')) %>%
  select(-c(3:7))

# * 2.3. OA21 to LSOA21 lookup ----
# `````````````````````````````````
# Read in the OA21 to LSOA21 lookup, keeping only the essential fields and rename them.
df_oa21_lsoa21_msoa21 <- read.csv(output_area_lookup_file) %>% 
  select(1, 2, 5, 9) %>%
  rename_with(.fn = ~c('oa21cd', 'lsoa21cd', 'msoa21cd', 'lad22nm'))

# * 2.4. ICB lookup ----
# ``````````````````````
# Read in the ICB lookup, keeping only the essential distinct fields and rename them.
df_icb <- read.csv(path = icb_lookup_file) %>% 
  select(4:9) %>%
  distinct() %>% 
  rename_with(.fn = ~c('ons_icbcd', 'icbcd', 'icbnm', 'ons_nhsercd', 'nhsercd', 'nhsernm')) %>%
  mutate(icb_label = gsub('_Integrated_Care_Board', 
                          '_ICB', 
                          gsub('__', 
                               '_', 
                               gsub('\\W', 
                                    '_', 
                                    paste0(df_icb$icbcd, '_', df_icb$icbnm)))),
         nhser_label = gsub('__', 
                            '_', 
                            gsub('\\W', 
                                 '_', 
                                 paste0(df_icb$nhsercd, '_', df_icb$nhsernm))))


# * 2.5. Postcode data ----
# `````````````````````````
# Read in the postcode data, keeping only the essential fields and rename them and filter on
# postcodes that are active and linked to an English ICB.
df_pcd <- read.csv(postcode_file) %>% 
  select(3, 51, 50, 5) %>%
  rename_with(.fn = ~c('pcds', 'oa21cd', 'icbcd', 'doterm')) %>%
  filter(icbcd!='' & grepl('^E', icbcd) & is.na(doterm)) %>%
  select(-doterm)

# 3. Process the fuel poverty risk data ----
# ******************************************

# Join the LSOA level fuel poverty data to the OA21 to LSOA21 lookup to obtain OA level fuel poverty data
df_fp <- df_fp %>% 
  inner_join(df_oa21_lsoa21_msoa21, by = 'lsoa21cd') %>% 
  # and then join to the household deprivation data
  inner_join(df_hd, by = 'oa21cd') %>%
  transmute(oa21cd, lsoa21cd, msoa21cd, lad22nm, 
            households_lsoa = households.x, households_in_fp, fp_pct = households_in_fp/households.x,
            households_oa = households.y, hd_pct_0 = pct_dim_0,
            hd_pct_1 = pct_dim_1, hd_pct_2 = pct_dim_2,
            hd_pct_3 = pct_dim_3, hd_pct_4 = pct_dim_4) %>%
  # Order by fuel poverty, then most deprived in 4 dimension, 3, 2, 1 all descending and finally zero ascending
  arrange(desc(fp_pct), 
          desc(hd_pct_4), desc(hd_pct_3), 
          desc(hd_pct_2), desc(hd_pct_1), hd_pct_0) %>%
  # Add in a rank and a decile for all the variables
  mutate(
    fp_rank = rank(desc(fp_pct), ties.method = 'average'),
    hp4_rank = rank(desc(hd_pct_4), ties.method = 'average'),
    hp3_rank = rank(desc(hd_pct_3), ties.method = 'average'),
    hp2_rank = rank(desc(hd_pct_2), ties.method = 'average'),
    hp1_rank = rank(desc(hd_pct_1), ties.method = 'average'),
    hp0_rank = rank(asc(hd_pct_0), ties.method = 'average'),
    overall_rank = seq_along(oa21cd),
    fp_decile = ntile(desc(fp_pct), n = 10),
    hp4_decile = ntile(desc(hd_pct_4), n = 10),
    hp3_decile = ntile(desc(hd_pct_3), n = 10),
    hp2_decile = ntile(desc(hd_pct_2), n = 10),
    hp1_decile = ntile(desc(hd_pct_1), n = 10),
    hp0_decile = ntile(asc(hd_pct_0), n = 10)
  ) %>% 
  mutate(overall_decile = ntile(overall_rank, n = 10))

# 4. Output results ----
# **********************

# Create the output directory
dir.create(outputdir, showWarnings = FALSE, recursive = TRUE)

# Write the fuel poverty risk data frame and zip
write.csv(df_fp %>% arrange(overall_rank), paste0(outputdir, '/fp_refined.csv'), row.names = FALSE)
zip(paste0(outputdir, '/fp_refined.zip'), paste0(outputdir, '/fp_refined.csv'), flags = "-m")

# Iterate through each NHS England Region and output a file for each ICB and zip 
for(nhser in df_icb %>% distinct(ons_nhsercd) %>% .$ons_nhsercd){
  d <- paste0(outputdir, 
              '/', 
              df_icb %>% 
                filter(ons_nhsercd==nhser) %>% 
                distinct(nhser_label) %>% 
                .$nhser_label) 
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
  for(icb in df_icb %>% filter(ons_nhsercd==nhser) %>% .$ons_icbcd){
    f <- paste0(d, 
                '/', 
                df_icb %>% 
                  filter(ons_icbcd==icb) %>% 
                  .$icb_label, 
                '.csv')
    write.csv(df_pcd %>% 
                filter(icbcd == icb) %>%
                inner_join(df_fp %>% 
                             select(oa21cd, fp_pct, overall_rank, overall_decile),
                           by = 'oa21cd') %>%
                arrange(pcds),
              f,
              row.names = FALSE)
    zip(gsub('\\.csv', '\\.zip', f), f, flags = "-mjD")
  }
}


