# ---
# title: "Match (APES Wave 3)"
# author: "Maita Schade"
# date: "Sep 28, 2020"
# ---
# 

# Given a target sample, recoded panel, and possibly previous invites and completes, this notebook 
# produces a new set of panelists to invite, with flexible number of columns (for larger batches).

# Make sure we're dealing with a clear space:
rm(list = ls(all = TRUE))

# define project path
prpath <- 'C:/Users/schadem/Box/LAPOP Shared/2_Projects/2019 APES/'

# set working dir
#setwd(paste0(prpath, 'src/'))



# Set the space up. Country is the only thing you should need to set manually, 
# if the files are all set up properly.

countries = c("AR")#,"MX","CL","AR","CO","PE")
country.names = c("AR"="Argentina","BR"="Brazil","CL"="Chile", "MX"="Mexico","CO"="Colombia","MX"="Mexico","PE"="Peru")
n <- 3 # batch depth--how many panelists per target?


# Defining files--make sure the dirs are okay; other than that you shouldn't need
# to touch this if the file structure is set up properly.


datadir <- paste0(prpath, 'Matching process/out/') #where we look for files to use/save
respdir <- paste0(prpath, 'Data processing/Data/') #where survey data are stored

varpath <- paste0(prpath, "Matching process/src/matching_vars.csv")
parampath <- paste0(prpath, "Matching process/src/country_parameters.csv") # set specefic parameters in this file


library('MatchIt')
library('data.table')
#library('openxlsx')
library(stringr)

# Loop over countries.
#for (country in countries){
  # For testing/dev, set country right here
  country <- "AR"
  print(paste0("Working on ", country, "..."))
  
  # set panel file
  panelfile <- paste0(datadir,'panel_country/', country, '_netquest_recoded.csv')

  # Load country-specific parameters:
  params <- fread(parampath,key = "country")[country,]
  target.date <- params[,target.date]
  print(paste0("Target date is ", target.date))
  NQ_id <- params[,NQ_id]
  
  targetfile <- paste0(datadir, "sample/", country, "_target_", target.date, ".csv")
  
  # Load data
  target <- fread(targetfile, colClasses = c(sampleId="character")) #make sure the sampleId has leading zeroes
  panel <- fread(panelfile)
  if(exists("recyclefile")){ # if there are previous invites that were not sent, set this above
    recycle <- fread(recyclefile)}
  length(unique(panel$X))
  length(unique(target$X))
  
  # get filename for previous responses, by listing corresponding directory:
  # UNCOMMENT WHEN YOU HAVE PREVIOUS RESONSES!
  
  # responsefile <- grep(paste0(country.names[country],".*\\.csv"),
  #                      list.files(respdir,
  #                                 full.names = T),
  #                      value = T)

  # Are there exclusions from a prior survey?
  # UNCOMMENT WHEN YOU WANT TO EXCLUDE OTHER LISTS OF IDs
  # IDs to exclude
  excludefiles <- (
    # e.g. prior waves of same study
    list.files(c(paste0(respdir,"Wave1"), paste0(respdir,"Wave2")),
               pattern = paste0("complete_ids.*\\.csv"),
               full.names = T)
  )
 # If so, remove them from the panel.
  if (exists("excludefiles")){
    for (excludefile in excludefiles){
      print(paste0("excluding previous respondents from ",excludefile))
    
      #The following will depend on the file that we're reading exclusions from
      exclude <- fread(excludefile)
      if("ticket"%in%names(exclude)){
        print("ticket")
        exclude[,"panelId" := substr(ticket,1,16)]
        # print(exclude$panelId)
      } else {if ("pid"%in%names(exclude)){
        print("pid")
        exclude[,"panelId":=pid]
      } else {if ("panelId"%in%names(exclude)){
        print("panelId")
        exclude <- melt(exclude,
             measure.vars = grep("panelId", names(exclude), value = T),
             value.name = "panelId")
      }}}
      # Prune panel to exclude previous respondents
      panel <- panel[!panelId %in% exclude$panelId,]
    print(dim(panel))
    }  
  }

  # Are there previous invites? If so, load them.
  # Also, prune the panel to just those not previously invited.

  if (length(list.files(path=paste0(datadir,"matches/"), 
                        pattern = paste0(country,"_selected_batch")))>0){ 
    # !! check this before the first time you create additional invite table
    print("previous invites found")
    # Printing what invites are considered
    cat(paste0("Included invite files: \n"))
  
    # Reading in invite files from all batches. Here, batch means batch of invites!
    batches <- lapply(list.files(path=paste0(datadir,"matches/"), pattern = country),
      function (x){
        cat(paste0("    ",x,"\n"))
      ## We make sure the individual batches have distinguishable names by attaching suffixes
    
        df<-fread(paste0(datadir, "matches/",x),colClasses = c(sampleId="character"))
        df[,sampleId := str_pad(string = sampleId, width = max(nchar(sampleId)), side = "left", pad = "0")]
        nbatch=as.numeric(str_match(x, "batch(\\d+)")[2])
        # select columns that have a number in the name, and create a suffix combined of batch and pass number
        suffixed <- paste("panelId",nbatch,str_match(grep("\\d",names(df),value = T),"\\d*$"),sep=".")
        # replace those colnames by "panelId" + suffix
        names(df)[grep("\\d",names(df))] <- suffixed
        return(df)
  
     }
    )
  
  # The target is a table of target records, with selected panelist IDs for each batch
  # target <- target[names(target)[,-grep("targetId|X",names(target))]]
  
  # "selected" is a long list of all NQ panelists selected from our end
    selected.wide <- Reduce(function(dtf1, dtf2) {merge(dtf1, dtf2,
                                                 by = c("sampleId"),
                                                 all.x = TRUE, all.y = TRUE)},
                     batches)
    selected <- melt(data = selected.wide,measure.vars = c(grep("panelId",names(selected.wide))))
    
    names(selected)<-c("sampleId",   "variable",   "panelId")
    selected[,pass:= str_match(variable,"\\d+\\.\\d+")]
    
    selected<-selected[selected[,!is.na(panelId)],]
 
    # Prune panel to exclude selected/invited
    panel <- panel[!panelId %in% selected$panelId,]
    
    # set batch
    batch <- length(batches)+1
    
  
  } else {batch <- 1}

  # Are there previous completes? If so, load them.

  if (exists("responsefile")){ #Check this before the first time using a responsefile
    print("completes found!")
    
    # # "responded" can be loaded straight from Qualtrics
    responded <- fread(responsefile,na.strings = "")
    # THE FOLLOWING DEFINES WHAT A COMPLETE RESPONSE LOOKS LIKE
    # PLEASE ADJUST FOR NEW STUDIES!
    completed <- responded[Finished==1 & CONSENT==1]
    
    #... for identifying how many targets have been hit, attach to each respondent its unique SAMPID
    completed <- selected[panelId%in%completed$pid]
    completed <- completed[!duplicated(panelId,fromLast = TRUE),]
    
    
    
    # Counting duplicates by counting occurrence of sampleId in respondents:
    # !!! Make sure you only count the full responses here! 
    nsamp_resp <- table(completed$sampleId)
   
    dupes <- sum(nsamp_resp-1)
    
    legit <- nrow(completed)-dupes
  
    cat(paste0("\nDuplicates in ", country, ": ", dupes,"\n"))
    cat(paste0("\nLegit responses: ", legit))
    
    # If you're only interested in complete/dupe-counts, uncomment this to skip the actual matching:
    # next
    
    ## Prune target to exclude filled slots
    # create list of respondents in wide sample id format--actually this shouldn't be necessary here, but let's not futz with it for now
    selected.resp <- selected[(panelId %in% completed$panelId),] #those that were selected and actually responded
    completed.wide <- dcast(selected.resp, ... ~ variable)
    
    # Check that no sampleId's are duplicated:
    if (sum(duplicated(completed.wide$sampleId))!= 0){
      print("Alert! Somehow you have duplicated sampleIds!")
      }
    
    # keep only targets that are not included in existing response set
    target.pruned <- target[!sampleId%in%completed.wide$sampleId,]
    dim(selected.resp)
    dim(completed)
    dim(completed.wide)
    print("Dimensions of pruned target:")
    print(dim(target.pruned))
  } else {
    target.pruned <- target
  }
  nrow(target.pruned)

  # Add a "treatment" into it, for sample matching
  # 0 is the panel, 1 is the target
  panel[,'treat':= rep(0,nrow(panel))]
  target.pruned[,'treat':=rep(1,nrow(target.pruned))]


  # Now join this data together:

  alldata <- rbind(panel, 
                   target.pruned[,grep("GEO",names(target.pruned),invert = T,value = T),with=F], 
                   fill=T)
  #fill NA
  alldata[is.na(panelId),panelId:="9999999999"]
  alldata[is.na(sampleId),sampleId:="9999999999"]


  # Load in matching.vars from recodefile

  matching.vars <- grep(".",fread(varpath)[[country]],value = T) #grab variables from file, excluding empty strings
  matching.vars <- grep("region",matching.vars,value = T, invert = T)
  # Now carry out the matching. 
  # Formula for matching:
  matching.form <- as.formula(paste0("treat ~ ", paste(matching.vars, collapse=' + ')))

  # We'll have to repeat this process (at least for everything except PS). 
  # * start empty dataframe initialized with target IDs
  # * make a copy of the data to alter
  # * for each i in range:
  #   + run the matching
  #   + store the matched IDs
  #   + store some overall metrics about the match
  #   + reduce the panel data
  # * return the match objects

  matchRatio <- function(data, metric, n, exact = c()){
    # A wrapper for the MatchIt framework to carry out arbitrary numbers of successive matches
    # data must have:
    #   * sampleId
    #   * panelId
    #   * treat
    require(MatchIt)
      
    # assign the dataframe to hold the matching results
    df <- data.frame(matrix(ncol=1, nrow=sum(data$treat==1)))
    names(df) <- c("sampleId")
    df$sampleId <- data$sampleId[data$treat==1]
    
    # assign the object to hold all the matching information
    matches <- vector("list",n)
    
    # make a copy of the passed-in data
    data.copy <- data.frame(data)
    
    # loop over the number of respondents per target
    for(i in 1:n){
      print(paste('i = ',as.character(i)))
      m <- matchit(matching.form, 
                   data = data.copy, exact=exact, method = "nearest", distance = metric)
      controls <- match.data(m, group='control')
      
      try({matches[[i]] <- m
          sampleids <- data.copy[row.names(m$match.matrix), "sampleId"]
          panelids <- data.copy[m$match.matrix,"panelId"]
          # setting column names of the ids so they'll be easy to read and tell apart
          print(paste("panelId",batch,i,sep="."))
          ids <- data.frame(sampleId=sampleids, panelId=panelids, stringsAsFactors = F)
          names(ids)[grep("panelId",names(ids))] <- paste("panelId",batch,i,sep=".")
          # adding them to already matched ids
          df <- merge(x=df, y=ids, by="sampleId", all.x = TRUE, suffixes=c("",as.character(i)))
          } 
      )
      data.copy <- data.copy[!data.copy$panelId %in% controls$panelId,] # not relying on rownames
      
    }
    return(list("ids"=df, "matches"=matches))
  }

  
  # Check if we have a good final sample...
  done<-F
  n_age_group <- 5
  
  # If not, assign age groups and match
  
  # Divide target sample into age quantiles (in this case, deciles) and add that to the data:
  # This may need adjustment if you run out of panelists to match to.

  while(!done & n_age_group>0){
    age_q <- quantile(target$age,prob = seq(0,1,1/n_age_group)) #this is the full target
    alldata[,'age_group' :=  as.integer(cut(alldata$age,breaks = age_q, include.lowest = TRUE))]
    alldata[is.na(age_group),age]
    alldata$age_group[is.na(alldata$age_group)] <- n_age_group #highest age-group can get lost; fill it in
    
    
    
    matches = matchRatio(alldata[,grep("region",names(alldata),value = T, invert = T),with=F],
                         "mahalanobis", n, exact = c("age_group","gend","capital"))
    
    # issue with NAs?
    problematic <- alldata[as.data.table(matches$ids)[!complete.cases(matches$ids)],
                           .(gend,age_group,region,capital),
                           on="sampleId"]
    if(dim(problematic)[1]==0){
      print(paste0("Successfully created match in ",country," with ",n_age_group," age groups."))
      done <- T
    } else {
      print(paste0(country,": With ",n_age_group," age groups, ",dim(problematic)[1]," NAs in match"))
      n_age_group <- n_age_group-1
    }
  }

  # Save the id's of the matches to a file

  write.csv(
    matches$ids, 
    file=paste0(datadir,"matches/",country,"_selected_batch",batch,"_",format(Sys.time(),"%y%m%d"),".csv"),
    row.names = F)
  
# }

  # # Double check a few things as needed...
  # 
  # # Do I have a good number of discrete location codes?
  # length(unique(panel$X))
  # length(unique(target$X))
  # sort(table(target$X))
  # 
  # 
  # # What are these NAs? --oh, it was the censusId! fixed now.
  # 
  # lapply(names(alldata), function(x){
  #   print(x)
  #   alldata[is.na(alldata[[x]]),]
  #   })
  # 
  # # What does the sample look like?
  # set <- matches$ids
  # set <- Reduce(x = set[,grep("panelId",names(set),value = T)],f = append)
  # set <- panel[panelId%in%set,]
  # 
  # table(target.pruned$ed)/nrow(target.pruned)
  # table(set$ed)/nrow(set)
  # 
  # target.pruned[,censusId:=substr(sampleId,1,12)]
  # target.pruned[,PERNUM:=substr(censusId,11,12)]
  # target.pruned[,SERIAL:=substr(censusId,1,10)]
  # write.csv(target.pruned,paste0("pruned_target_", format(Sys.time(),"%y%m%d"),".csv"))
  # write.csv(set,paste0("selected_IDs_", format(Sys.time(),"%y%m%d"),".csv"))
  # 
  # # What about the regions? did it work?
  # table(set$region)
  # table(target$region)
