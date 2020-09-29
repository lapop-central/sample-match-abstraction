# Code to handle mapping into regions, if used for sampling
# Somewhat deprecated, since now we only use CAPITAL

# ---
# title: "Combine regions"
# author: "Maita Schade"
# date: "Sep 28, 2020"
# ---

# clear space
rm(list = ls(all=T))

# necessary packages
library(data.table)

#files
prepdir <- "C:/Users/schadem/Box Sync/LAPOP Shared/2_Projects/Archive/2020 IDB Trust/prep/out/geo/"
outdir <- "C:/Users/schadem/Box Sync/LAPOP Shared/2_Projects/Archive/2020 IDB Trust/doc/design/geo/"

# AR
# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread(paste0(
  prepdir,"AR_geo2_regions_crosswalk.csv"),
  encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread(paste0(
  prepdir,"AR_geo2_codebook.csv"),
  encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2010,geo2_code),on="IPUMS_geo2_code==IPUM2010"]
regions_table[,REGION_n:=as.numeric(as.factor(REGION))]
# write out the regions table
write.csv(regions_table,
          paste0(outdir,"AR_regions.csv"))

# BR
# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread(paste0(
  prepdir,"BR_geo1_regions_crosswalk.csv"),
  encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread(paste0(
  prepdir,"BR_geo1_codebook.csv"),
  encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2010,geo1_code),on="IPUMS_geo1_code==IPUM2010"]
regions_table[,REGION_n:=as.numeric(as.factor(REGION))]
# write out the regions table
write.csv(regions_table,
          paste0(outdir,"BR_regions.csv"))

# CL
# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread(paste0(
  prepdir,"CL_geo1_regions_crosswalk.csv"),
  encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread(paste0(
  prepdir,"CL_geo1_codebook.csv"),
  encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2002,geo1_code),on="IPUMS_geo1_code==IPUM2002"]
regions_table[,REGION_n:=as.numeric(as.factor(REGION))]
# write out the regions table
write.csv(regions_table,
          paste0(outdir,"CL_regions.csv"))

# CO
# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread(paste0(
  prepdir,"CO_geo1_regions_crosswalk.csv"),
  encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread(paste0(
  prepdir,"CO_geo1_codebook.csv"),
  encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2005,geo1_code),on="IPUMS_geo1_code==IPUM2005"]
regions_table[,REGION_n:=as.numeric(as.factor(REGION))]
# write out the regions table
write.csv(regions_table,
          paste0(outdir,"CO_regions.csv"))

# MX
# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread(paste0(
  prepdir,"MX_geo1_regions_crosswalk.csv"),
  encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread(paste0(
  prepdir,"MX_geo1_codebook.csv"),
  encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2015,geo1_code),on="IPUMS_geo1_code==IPUM2015"]
regions_table[,REGION_n:=as.numeric(as.factor(REGION))]
# write out the regions table
write.csv(regions_table,
          paste0(outdir,"MX_regions.csv"))

# PE
# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread(paste0(
  prepdir,"PE_geo2_regions_crosswalk.csv"),
  encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread(paste0(
  prepdir,"PE_geo2_codebook.csv"),
  encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2007,geo2_code),on="IPUMS_geo2_code==IPUM2007"]
regions_table[,REGION_n:=as.numeric(as.factor(REGION))]
# write out the regions table
write.csv(regions_table,
          paste0(outdir,"PE_regions.csv"))
