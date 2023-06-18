#####################################################################
#                                                                   #
# File: fuel_poverty_refined.R                                      #
# Desc: Refine the BEIS sub-regional fuel poverty England 2022 with #
#       the DWP Universal and Pensions Credit data at output area.  #
# Auth: Richard Blackwell                                           #
# Date: 2023-06-18                                                  #
#                                                                   #
#####################################################################

# ==============
# Load libraries
# ==============
library(tidyverse)
library(readxl)

# =========
# Load data
# =========
# Fuel poverty
# ------------
df_fp <- read_excel(path = '.\\data\\fp\\sub-regional-fuel-poverty-tables-2023-2021-data.xlsx', 
                    sheet = 'Table 3',
                    skip = 2) %>%
  select(1, 6:7) %>%
  rename_with(.fn = function(x){c('lsoa21cd', 'households', 'households_in_fp')})

# Universal credit
# ----------------
df_uc <- read.csv('.\\data\\uc\\england_uc_oa.csv', skip = 11, header = FALSE) %>%
  select(1, seq(2,25,2)) %>%
  rename_with(.fn = function(x){c('oa11cd', paste0('m', str_sub(paste0('0', c(1:12)), -2)))})
df_uc <- df_uc %>% 
  slice_head( n = which(df_uc$oa11cd=='Total')-1 ) %>%
  mutate(across(.cols = 2:13, as.integer))
df_uc[is.na(df_uc)] <- 0
df_uc$median_uc <- apply(df_uc[,2:13], 1, median)
df_uc <- df_uc %>% select(oa11cd, median_uc)

# Pension credit
# --------------
df_pc <- read.csv('.\\data\\pc\\england_pc_oa.csv', skip = 11, header = FALSE) %>%
  select(1, seq(2,9,2)) %>%
  rename_with(.fn = function(x){c('oa11cd', paste0('q', str_sub(paste0('0', c(1:4)), -2)))})
df_pc <- df_pc %>% 
  slice_head( n = which(df_pc$oa11cd=='Total')-1 ) %>%
  mutate(across(.cols = 2:5, as.integer))
df_pc[is.na(df_pc)] <- 0
df_pc$median_pc <- apply(df_pc[,2:5], 1, median)
df_pc <- df_pc %>% select(oa11cd, median_pc)

# LSOA11 to LSOA21 lookup
# -----------------------
df_lsoa11_lsoa21 <- read.csv('.\\data\\lu\\LSOA_(2011)_to_LSOA_(2021)_to_Local_Authority_District_(2022)_Lookup_for_England_and_Wales.csv') %>%
  select(1, 3, 5) %>%
  rename_with(.fn = function(x){c('lsoa11cd', 'lsoa21cd', 'chgind')}) %>%
  filter(grepl('^E', lsoa11cd))

df_lsoa11_lsoa21 <- df_lsoa11_lsoa21 %>% 
  filter(!(lsoa11cd %in% c('E01008187','E01023508','E01023679','E01023768','E01023964','E01027506'))) %>%
  bind_rows(
    data.frame(lsoa11cd = c('E01008187','E01023508','E01023679','E01023768','E01023964','E01027506'),
               lsoa21cd = c('E01035624','E01035609','E01035581','E01035582','E01035608','E01035637'),
               chgind = rep('X',6)))

# OA11 to LSOA11 lookup
# ---------------------
df_oa11_lsoa11_msoa11 <- read.csv('.\\data\\lu\\Output_Area_to_Lower_Layer_Super_Output_Area_to_Middle_Layer_Super_Output_Area_to_Local_Authority_District_(December_2011)_Lookup_in_England_and_Wales.csv') %>%
  select(1, 2, 4) %>%
  rename_with(.fn = function(x){c('oa11cd', 'lsoa11cd', 'msoa11cd')})

# ===========================
# Convert 2021 data into 2011
# ===========================

# If unchanged or if the 2011 LSOAs were merged into a 2021 LSOA then the 2021 data can be assigned to the 
# 2011 LSOA.
df_fp <- df_fp %>% 
  inner_join(df_lsoa11_lsoa21 %>% filter(chgind!='S') %>% select(-chgind), by = 'lsoa21cd') %>% 
  select(lsoa11cd, households, households_in_fp) %>%
  bind_rows(
    # If the 2011 LSOAs were split into a number of 2021 LSOA then the 2021 data can be assigned to the 
    # 2011 LSOA by taking an average of the 2021 areas
    df_fp %>% inner_join(df_lsoa11_lsoa21 %>% filter(chgind=='S') %>% select(-chgind), by = 'lsoa21cd') %>% 
      select(lsoa11cd, households, households_in_fp) %>% 
      group_by(lsoa11cd) %>%
      summarise(households = sum(households), households_in_fp = sum(households_in_fp)) %>%
      ungroup()
  ) %>%
  mutate(pct_households_in_fp = households_in_fp / households)

# Create the output area level data by joining with the oa11 to lsoa11 lookup data
df_fp_refined <- df_fp %>% left_join(df_oa11_lsoa11_msoa11 %>% select(oa11cd, lsoa11cd), by = 'lsoa11cd') %>%
  select(oa11cd, pct_households_in_fp) %>%
  left_join(df_uc, by = 'oa11cd') %>%
  left_join(df_pc, by = 'oa11cd') %>%
  rename_with(.fn = function(x){c('oa11cd','fp','uc','pc')}) %>%
  mutate(fp_rank = rank(desc(fp), ties.method = 'average'),
         uc_rank = rank(desc(uc), ties.method = 'average'),
         pc_rank = rank(desc(pc), ties.method = 'average')) %>%
  mutate(combined_rank = fp_rank + uc_rank + pc_rank) %>%
  mutate(combined_rank = rank(combined_rank, ties.method = 'average')) %>%
  arrange(combined_rank) %>%
  mutate(combined_decile = ntile(combined_rank, n = 10))

write.csv(df_fp_refined, 'fp_refined.csv')