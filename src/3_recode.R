# ---
# title: "Recode"
# author: "Maita Schade"
# date: "Sep 28, 2020"
# ---

# This notebook helps in recoding panel and census datasets to a compatible format.
# Important input that need to be adjusted with country specifics:
#   * matching-vars.csv currently supplies matching variables
#   * country_parameters.csv supplies parameters (such as specific labels or strata)
#   * recode_country.R contains the individual recodes for each country

# Make sure we're dealing with a clear space:
rm(list = ls(all = TRUE))

# loading packages
library(data.table)
library(bit64)
# set working dir
setwd('C:/Users/schadem/Box/LAPOP Shared/2_Projects/2019 APES/Matching process/src/')

# Setting specifics--iterate over countries.

for (country in c("AR")){ # "CL","BR","CO","MX","PE"

# For testing/dev, just set one country
country<-"AR"
# Defining files--make sure the dirs are okay; other than that you shouldn't need to touch this if the file structure is set up properly.

datadir <-  paste0('../out/')

censuspath <- paste0(datadir,'ipums_country/',country,'_ipums-census_geo.csv')

netquestpath <- paste0(datadir, "panel_country/", country, "_netquest-panel_geo.csv")

varpath <- "./matching_vars.csv" #table specifying matching vars by country
parampath <- "./country_parameters.csv" # set specific parameters in this file
regiopath <- paste0("../doc/design/geo/",country,"_regions.csv")

# Load external function to do the dirty work, depending on country etc.
# Note that this function will need to get updated when adding new countries/data sources.
source("./recode_country.R")

#Load country-specific parameters:
params <- fread(parampath,key = "country")[country,]
NQ_id <- params$NQ_id #netquest ID label used in panel extract
strats <- unlist(Filter(f = Negate(is.na), params[,c("strat1","strat2")])) #strata variables

# We have to recode the various characteristics we have at our disposal.

matching.vars <- Filter(
  f=Negate(is.na),
  fread(varpath,na.strings = "")[[country]]
)
cat("Matching on: ")
cat(matching.vars)


## Recode IPUMS

# Load IPUMS datafile
print(censuspath)
census<- fread(censuspath)

# Recode
census.proc <- countryRecode(dt = census, source = 'ipums', country = country)
# give warning of variables that have a lot of NA in the end--records
# with NA in matching vars are dropped, so if some variable excludes 
# a lot of records we need to remove that variable from matching
cat("Census vars ending up with lots of NA: ")
cat(Filter(function(name){sum(is.na(census.proc[[name]]))}/nrow(census.proc) > 0.2, names(census.proc)))

# Investigate ones with lots of NA (as needed):
# table(census.proc[age>17,c("PE2007A_SEWAGE")])
# sum(is.na(census.proc$bath))

# These are not in universe.
# nrow(census.proc[PE2007A_CABLETV==1,cable:=1])
# This is special ed, and not in universe.

# Add the region and capital flag
regio_dict <- fread(regiopath)
## Figure out what we are lining up
codevars <- list(IPUMS=grep("IPUM",names(regio_dict),value=T),
                 netquest=grep("geo\\d_code",names(regio_dict),value=T))
geotype <- regmatches(codevars$netquest,regexpr("\\d",codevars$netquest))
ipum_geovar <- grep(paste0("GEO",geotype,"_",country,"\\d{4,4}"), 
                     names(census.proc),
                     value = T)
## Get just unique geo for IPUMS
regio_dict <- unique(regio_dict,by = codevars$IPUMS)
## join to census info
census.proc[,c("region","capital"):=regio_dict[census.proc,
                                               .(REGION_n,CAPITAL),
                                               on=paste0(codevars$IPUMS,"==",ipum_geovar)]]
### test a little bit
# unique(census.proc[region==3,.(ADMIN_NAME)])

# Give ID to all members, as combination of household and person ID
nSERIAL <- max(nchar(as.character(census.proc$SERIAL)))
nPERN <- max(nchar(as.character(census.proc$PERNUM)))
# it's twice as fast to pull the calculation of the width of these out front
census.proc[,censusId:=paste0(
  sprintf(
    paste0('%0',nSERIAL,'.0f'),as.double(SERIAL)
  ),
  sprintf(
    paste0('%0',nPERN,'.0f'),as.double(PERNUM)
  )
)]

cat("\ncensusId is unique: ")
cat(max(table(census.proc$censusId)) == 1) #make sure is unique!
# if this is FALSE, asses what is going on with these supposedly unique IDs

# Then cut things down                         
census.proc <- census.proc[census.proc$age>17,]
census.proc <- census.proc[,c('censusId','PERWT',matching.vars,strats[strats!=""]),with=F]
census.proc <- na.omit(census.proc)

# what proportion ends up in sampling frame
cat("Proportion of census in sampling frame: ")
cat((dim(census.proc)/dim(census))[1])

# Save to disk:
fwrite(x = census.proc, 
          file = paste0(datadir,'ipums_country/', country,'_ipums_recoded.csv')
)



## Recode Netquest

# Load datafile
netquest <- fread(netquestpath)

# Recode
netquest.proc <- countryRecode(dt = netquest, source = 'netquest', country = country)

cat("Netquest vars ending with lots of NA: ")
cat(Filter(function(name){sum(is.na(netquest.proc[[name]]))}/nrow(netquest.proc) > 0.1, names(netquest.proc)))
# If any of the matching variables have a lot of NA, investigate and consider dropping that one

# Add the region
regio_dict <- fread(regiopath)
## Figure out what we are lining up
codevars <- list(IPUMS=grep("IPUM",names(regio_dict),value=T),
                 netquest=grep("geo\\d_code",names(regio_dict),value=T))
geotype <- regmatches(codevars$netquest,regexpr("\\d",codevars$netquest))
nq_geovar <- params[[paste0("geo",geotype,"_nq")]]

## Get just unique geo for Netquest
regio_dict <- unique(regio_dict,by = codevars$netquest)
## join to census info
#netquest.proc[,region:=regio_dict[netquest.proc,.(REGION_n,CAPITAL),on=paste0(codevars$netquest,"==",nq_geovar)]]
netquest.proc[,c("region","capital"):=regio_dict[netquest.proc,
                                               .(REGION_n,CAPITAL),
                                               on=paste0(codevars$netquest,"==",nq_geovar)]]
### test a little bit
#unique(netquest.proc[region==3,.(CO_departamento)])

# Reduce to what we need:
netquest.proc$panelId  <- netquest.proc[[NQ_id]]
netquest.proc <- netquest.proc[netquest.proc$age>17,]
netquest.proc <- netquest.proc[,c(matching.vars, 'panelId'),with=F]
# experimenting with leaving out certain variables to get a higher survival rate of panelists
# netquest.proc <- netquest.proc[,grep("floor|health",names(netquest.proc), invert = T, value = T),with=F]
netquest.proc <- na.omit(netquest.proc)     

# what proportion ends up in sampling frame
cat("\n\nProportion of Netquest available: ")
cat((dim(netquest.proc)/dim(netquest))[1])

# Save to disk:
fwrite(x = netquest.proc, 
          file = paste0(datadir,'panel_country/', country, '_netquest_recoded.csv')
)

}
