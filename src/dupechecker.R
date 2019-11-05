dupechecker <- function(responsefile, datadir, pattern="wave"){
  require(data.table)
  require(stringr)

## check formatting of datadir
  if (substr(datadir,nchar(datadir),nchar(datadir))!="/"){
    datadir <- paste0(datadir, "/")
  }

## invite loading
  invitefiles <- list.files(path=datadir, pattern = pattern)

  stopifnot(!is.null(invitefiles))
  # Printing what invites are considered
  cat(paste0("Included invite files: \n"))

  # Reading in invite files from all waves, excluding ones marked for quality control
  waves <- lapply(grep("QC",invitefiles,
                       invert = T, value = T),     
                  function (x){      
                    cat(paste0("    ",x,"\n"))
    ## We make sure the individual waves have distinguishable names in the tabel by attaching suffixes
                    df<-fread(paste0(datadir,x),
                              colClasses = c(sampleId="character"))
                    #check format of datatable
                    stopifnot("sampleId"%in%names(df),"panelId"%in%names(df))
                    
                    #making sampleId comparable
                    df[,sampleId := str_pad(string = sampleId, width = max(nchar(sampleId)), side = "left", pad = "0")]
                    nwave=as.numeric(str_match(x, paste0(pattern,"(\\d+)"))[2])
                    suffix=paste0(".",nwave,".",1:(ncol(df)-1))
                    print(suffix)
                    names(df)[grep("panelId.?",names(df))] <- paste0("panelId",suffix)
                    return(df)
                    }
    )
  
  # The target is a table of target records, with selected panelist IDs for each wave
  target.select <- Reduce(function(dtf1, dtf2) {merge(dtf1, dtf2,
                                               by = c("sampleId"),
                                               all.x = TRUE)},
                   waves)
    
  # "selected" is a long list of all NQ panelists selected from our end
  selected.wide <- Reduce(function(dtf1, dtf2) {merge(dtf1, dtf2,
                                               by = c("sampleId"),
                                               all.x = TRUE, all.y = TRUE)},
                   waves)
  selected <- melt(data = selected.wide,measure.vars = c(grep("panelId",names(selected.wide))))
  
  names(selected)<-c("sampleId",   "variable",   "panelId")
  selected[,batch:= str_match(variable,"\\d\\d?.\\d\\d?")]
  
  selected<-selected[selected[,!is.na(panelId)],]
    
  
## response loading

  # # "responded" can be loaded straight from Qualtrics 
  responses <- fread(responsefile)
  if (is.null(responses)){stop("Responsefile not found!")}
  stopifnot("pid"%in%names(responses))
  responses[,"panelId" := str_to_lower(pid)]
  # take care not to count incompletes here
  responded <- responses[(Finished=="1")&(AGECONF=="1"),panelId]
  #get the sample information for the responded response-ids
  responded <- selected[panelId%in%responded]
  responded <- responded[!duplicated(panelId,fromLast = TRUE),]
  
## Dupe checking
  # Counting duplicates by counting occurrence of sampleId in respondents:
  nsamp_resp <- table(responded$sampleId)
 
  ndupes <- sum(nsamp_resp-1)  
    
  legit <- nrow(responded)-ndupes

  cat(paste0("\nDuplicates: ", ndupes,"\n"))
  cat(paste0("\nLegit responses: ", legit))
  
  # Other quantities of interest: which IDs got duplicates; who got what responses
  selected.resp <- selected[(panelId %in% responded$panelId),] #those that were invited and actually responded
  table.of.responses <- dcast(selected.resp, sampleId ~ batch,value.var = list("panelId"))
  
  
  sampleId.duped <- names(nsamp_resp[nsamp_resp>1])
 
  return(list(ndupes=ndupes, sampleId.duped=sampleId.duped, table.of.responses=table.of.responses))
}

########################
### Sample usage below
########################
# responsefile <- 'C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Crime/Data processing/Data/IADB+Argentina+Questionnaire+-+Netquest+v2_October+28%2C+2019_08.59.csv'
# datadir <-  datadir <- paste0('C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Crime/Matching process/Data/AR/panel/') 
# pattern <- "wave"
# 
# dupeinfo <- dupechecker(responsefile = responsefile,datadir = datadir)
# write.csv(dupeinfo$sampleId.duped,"C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Crime/Matching process/Data/AR/panel/dupes_291028.csv" )
# write.csv(dupeinfo$table.of.responses, 
#           "C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Crime/Matching process/Data/AR/panel/responses_291028.csv",
#           na = "",
#           row.names = F)

