rm(list=ls(all=T))
library(data.table)

# set working dir
setwd('C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/prep/src/')
targetdate <- "200323"
datadir <-  paste0('../out/')


for (country in c("AR","BR","CL","CO","MX","PE")){
  print(country)
  ipumspath <- paste0(datadir,'ipums_country/',country,'_ipums-census_geo.csv')
  
  samplepath <- paste0(
    datadir, 'sample/', country, "_target_",targetdate,".csv")
  
  ipums <- fread(ipumspath,drop="V1")
  sample <- fread(samplepath, colClasses = c(sampleId="character"))  
  
  # Give ID to all members
  nSERIAL <- max(nchar(as.character(ipums$SERIAL)))
  nPERN <- max(nchar(as.character(ipums$PERNUM)))
  # it's twice as fast to pull the calculation of the width of these out front
  ipums[,censusId:=paste0(
    sprintf(
      paste0('%0',nSERIAL,'.0f'),as.double(SERIAL)
    ),
    sprintf(
      paste0('%0',nPERN,'.0f'),as.double(PERNUM)
    )
  )]
  
  # get back censusId for sample
  sample[,censusId:=substr(sampleId, 1, nchar(sampleId)-1)]

  sample.all <- ipums[sample$censusId,on="censusId"]
  
  fwrite(sample.all, paste0(datadir,"sample/",country,"_target_allvars_",targetdate,".csv"))
  fwrite(ipums, paste0(datadir,"ipums_country/",country,"_ipums-census_withId.csv"))
}  