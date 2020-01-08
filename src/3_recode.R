# ---
# title: "recode (IDB Trust)"
# author: "Maita Schade"
# date: "Sep 8, 2019"
# output: html_notebook
# ---

# This notebook helps in recoding panel and census datasets to a compatible format.
# Important input that need to be adjusted with country specifics:
#   * recode_Netquest_IPUMS_COUNTRY.csv currently supplies matching variables
#   * country_parameters.csv supplies parameters (such as specific labels or strata)
#   * recode_country.R contains the individual recodes for each country

# Make sure we're dealing with a clear space:
rm(list = ls(all = TRUE))

# loading packages
library(data.table)
library(bit64)
# set working dir
setwd('C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/prep/src/')

# Setting specifics--may want to iterate over countries rather than set things individually, eventually.

for (country in c("BR","CL","CO","PE")){

# Defining files--make sure the dirs are okay; other than that you shouldn't need to touch this if the file structure is set up properly.

datadir <-  paste0('../out/')

censuspath <- paste0(datadir,'ipums_country/',country,'_ipums-census_geo.csv')

netquestpath <- paste0(datadir, "panel_country/", country, "_netquest-panel_geo.csv")

varpath <- paste0("../../doc/matching/matching-vars.csv") #table specifying matching vars by country
parampath <- "./country_parameters.csv" # set specific parameters in this file


# Load external function to do the dirty work, depending on country etc.
# Note that this function will need to get updated when adding new countries/data sources.
source("./recode_country.R")

#Load country-specific parameters:
params <- fread(parampath,key = "country")[country,]
NQ_id <- params$NQ_id
strats <- unlist(Filter(f = Negate(is.na), params[,c("strat1","strat2")]))

# We have to recode the various characteristics we have at our disposal.

matching.vars <- Filter(
  f=Negate(is.na),
  fread("../../doc/matching/matching_vars.csv",na.strings = "")[[country]]
)
cat("Matching on: ")
cat(matching.vars)


## Recode IPUMS

# Load datafile
print(censuspath)
census<- fread(censuspath)
# Recode
census.proc <- countryRecode(dt = census, source = 'ipums', country = country)
# Summarize
# summary(census.proc)
cat("Census vars ending up with lots of NA: ")
cat(Filter(function(name){sum(is.na(census.proc[[name]]))}/nrow(census.proc) > 0.2, names(census.proc)))

# Investigate ones with lots of NA (as needed):
# table(census.proc[age>17,c("PE2007A_SEWAGE")])
# sum(is.na(census.proc$bath))

# These are not in universe.
# nrow(census.proc[PE2007A_CABLETV==1,cable:=1])
# This is special ed, and not in universe.


# Give ID to all members
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

# Then cut things down                         
census.proc <- census.proc[census.proc$age>17,]
census.proc <- census.proc[,c('censusId','PERWT',matching.vars,strats[strats!=""]),with=F]
census.proc <- na.omit(census.proc)
#head(census.proc)

# summary(census.proc)

# what proportion ends up in sampling frame
cat("Proportion of census in sampling frame: ")
cat(dim(census.proc)/dim(census))

# Save to disk:
write.csv(x = census.proc, 
          file = paste0(datadir,'ipums_country/', country,'_ipums_recoded.csv'),
          row.names = F
)



## Recode Netquest

# Load datafile
netquest <- fread(netquestpath)
# sort(unique(netquest$X))

# Recode
netquest.proc <- countryRecode(dt = netquest, source = 'netquest', country = country)

cat("Netquest vars ending with lots of NA: ")
cat(Filter(function(name){sum(is.na(netquest.proc[[name]]))}/nrow(netquest.proc) > 0.1, names(netquest.proc)))

dim(netquest.proc)/dim(netquest)

# Reduce to what we need:
netquest.proc$panelId  <- netquest.proc[[NQ_id]]
netquest.proc <- netquest.proc[netquest.proc$age>17,]
netquest.proc <- netquest.proc[,c(matching.vars, 'panelId'),with=F]
# experimenting with leaving out certain variables to get a higher survival rate of panelists
# netquest.proc <- netquest.proc[,grep("floor|health",names(netquest.proc), invert = T, value = T),with=F]
netquest.proc <- na.omit(netquest.proc)     

# what proportion ends up in sampling frame
cat("\n\nProportion of Netquest available: ")
cat(dim(netquest.proc)/dim(netquest))

# Save to disk:
write.csv(x = netquest.proc, 
          file = paste0(datadir,'panel_country/', country, '_netquest_recoded.csv'),
          row.names = F
)

}