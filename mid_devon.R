# Prepare Mid Devon Fuel Poverty Data
library(tidyverse)
library(leaflet)
library(sf)
library(rgdal)

# Load fule poverty data
df_fp_refined <- read.csv(unzip(zipfile = 'fp_refined.zip', 'fp_refined.csv'))

# Define catchment area
df_gpreg <- read.csv('D:\\Data\\NHSD\\GPREGLSOA\\20230401\\gp-reg-pat-prac-lsoa-all.csv') %>% 
  select(3, 5, 7) %>% rename_with(.fn = function(x){c('prac_code', 'lsoa11cd', 'popn')}) %>%
  filter(grepl('^E', lsoa11cd ))

# Calculate proportions
df_gpreg <- df_gpreg %>% 
  left_join(df_gpreg %>% group_by(lsoa11cd) %>% summarise(total = sum(popn)), by = 'lsoa11cd') %>%
  mutate(pct = popn / total)

# Filter for Mid Devon Healthcare PCN practices
df_mid_devon_pcn <- df_gpreg %>% 
  filter(prac_code %in% c('L83023', 'L83025', 'L83065', 'L83098', 'L83127', 'Y02633')) %>%
  arrange(desc(pct)) %>%
  mutate(dec = floor(pct*10) + 1)
  
# Load LSOA shapefile and join to the population data
sf_lsoa11 <- st_read(dsn = 'D:\\Data\\OpenGeography\\Shapefiles\\LSOA11', layer = 'lsoa11') %>%
  st_transform(crs = 4326) %>%
  left_join(df_mid_devon_pcn, by = c('LSOA11CD' = 'lsoa11cd'))

# Load the LAD boundaries  
sf_lad22 <- st_read(dsn = 'D:\\Data\\OpenGeography\\Shapefiles\\LAD22', layer = 'lad22') %>%
  st_transform(crs = 4326)

palPCT <- colorFactor(palette = 'Blues', domain = as.factor(sf_lsoa11$dec))

map <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = sf_lsoa11, 
              fillColor = ~palPCT(pct)
  ) 
map  

floor(sf_lsoa11$pct * 10)