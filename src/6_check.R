# ---
# title: "test (IDB Trust)"
# author: "Maita Schade"
# date: "Mar 17, 2020"
# output: html_notebook
# ---
# 


# Make sure we're dealing with a clear space:
rm(list = ls(all = TRUE))

# set working dir
setwd('C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/prep/src/')
# set data dir
datadir <- paste0('C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Trust/prep/out/')
# set parameter path
parampath <- "./country_parameters1.csv" # set specefic parameters in this file

# set wave to check
wave <- 1


# load libraries
library(data.table)
#install.packages("questionr")
library(questionr)

library(ggplot2)
library(dplyr)

country <- "PE"
# Load country-specific parameters:
params <- fread(parampath,key = "country")[country,]
target.date <- params[,target.date]

# load census with recoded vars
ipumspath <- paste0(datadir,'ipums_country/', country,'_ipums_recoded.csv')
ipums <- fread(ipumspath)
ipums.18 <- ipums[age>17]
# load netquest with recoded vars
netquestpath <-  paste0(datadir,'panel_country/', country, '_netquest_recoded.csv')
netquest <- fread(netquestpath)

# load target sample & merge census vars
targetfile <- paste0(datadir, "sample/", country, "_target_", target.date, ".csv")
target <- fread(targetfile, colClasses = c(sampleId="character"))
target[,censusId:=as.double(substr(sampleId, 1, nchar(sampleId)-1))]
target.all <- ipums[target[,.(censusId)],on="censusId"]

# load matched sample & merge netquest vars
matchfile <- paste0(datadir, "matches/",
                    list.files(paste0(datadir, "matches/"),
                               pattern = paste0(country,"_selected_wave",wave)))
matches <- fread(matchfile)
matches.all <- netquest[melt(matches, id= c("sampleId")),on="panelId==value"]

# # set up output to pdf
# outputpath = paste0("./",country,"_match-check.pdf")
# pdf(file=outputpath)  

# for each variable:
for(var in names(ipums)[names(ipums)%in%names(netquest)]){
  var <- "emp"
  print(paste0(country,": ",var))
  # percent-tab categories in ipums
  ipums.tab <- data.table(wtd.table(ipums.18[[var]],weights=ipums.18$PERWT)/sum(ipums.18$PERWT)*100)
  setnames(ipums.tab, c("V1","N"),c("category","ipums"))
  # percent-tab categories in target
  target.tab <- data.table(table(target.all[[var]])/nrow(target.all)*100)
  setnames(target.tab, c("V1","N"),c("category","target"))
  # percent-tab categories in match
  match.tab <- data.table(table(matches.all[[var]])/nrow(matches.all)*100)
  setnames(match.tab, c("V1","N"),c("category","match"))
  # plot ipums & difference tabs
  tabs <- Reduce(function(x,y){merge(x,y,by="category",all=T)},
                 list(ipums.tab, target.tab, match.tab)) 
                  # data.table(t(cbind(ipums.tab,target.tab,match.tab)))
  tabs[,target.diff:=target-ipums]  
  tabs[,match.diff:=match-ipums]
  tabs[,category:=as.integer(category)]
  tabs.melted <- melt(tabs, id="category")
  print(ggplot(tabs.melted[variable%in%c("ipums","target","match")], 
         aes(x=category, y=value,fill=variable)) + 
    geom_col(position = position_dodge(width=0.5)) +
    ggtitle(paste0(country,": ",var)) +
    ylab("percentage"))
    }

  