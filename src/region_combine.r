# clear space
rm(list = ls(all=T))

# necessary packages
library(data.table)

# load IPUMS with regions--manually created in QGIS
IPUMS_regions <- fread("C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/prep/out/geo/PE_geo2_regions_crosswalk.csv",encoding="UTF-8")
# load IPUMS with Netquest--out of Netquest processing
IPUMS_Netquest <- fread("C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/prep/out/geo/PE_geo2_codebook.csv",encoding = 'UTF-8')
regions_table <- IPUMS_Netquest[IPUMS_regions,.(REGION,ADMIN_NAME,IPUM2007,geo2_code),on="IPUMS_geo2_code==IPUM2007"]
# write out the regions table
write.xlsx(regions_table,"C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/doc/design/geo/PE_regions.xlsx")
