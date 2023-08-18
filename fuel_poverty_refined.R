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

fuel_poverty_excel_workbook <- './data/fp/sub-regional-fuel-poverty-tables-2023-2021-data.xlsx'
fuel_poverty_excel_worksheet <- 'Table 3'
household_deprivation_csvfile <- './data/census/census2021-ts011-oa.csv'

# * 2.1. Fuel poverty ----
# ````````````````````````
# Read in the LSOA level fuel poverty data from the Table 3 worksheet 
# ignoring the first 2 lines. Select only the essential fields and rename them, 
# and finally filter to English LSOAs only
df_fp <- read_excel(path = fuel_poverty_excel_workbook, 
                    sheet = fuel_poverty_excel_worksheet,
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
df_oa21_lsoa21_msoa21 <- read.csv('.\\data\\lu\\Output_Area_to_Lower_layer_Super_Output_Area_to_Middle_layer_Super_Output_Area_to_Local_Authority_District_(December_2021)_Lookup_in_England_and_Wales_v3.csv') %>% 
  select(1, 2, 5, 9) %>%
  rename_with(.fn = ~c('oa21cd', 'lsoa21cd', 'msoa21cd', 'lad22nm'))

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
    hp0_rank = rank(desc(hd_pct_4), ties.method = 'average'),
    overall_rank = seq_along(oa21cd),
    fp_decile = ntile(desc(fp_pct), n = 10),
    hp4_decile = ntile(desc(hd_pct_4), n = 10),
    hp3_decile = ntile(desc(hd_pct_3), n = 10),
    hp2_decile = ntile(desc(hd_pct_2), n = 10),
    hp1_decile = ntile(desc(hd_pct_1), n = 10),
    hp0_decile = ntile(desc(hd_pct_4), n = 10)
  ) %>% 
  mutate(overall_decile = ntile(overall_rank, n = 10)) 

# 4. Output results ----
# **********************
write.csv(df_fp, 'fp_refined.csv')
zip('fp_refined.zip', 'fp_refined.csv', flags = "-m")