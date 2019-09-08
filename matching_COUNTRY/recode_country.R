countryRecode <- function(dt, source, country){
  ###Function to recode census datatables.
  # Takes as input a datatable or similar object, an indication where 
  # it came from (ipums or dt), and the country it pertains to.
  # Returns the dataframe with the variables added in as defined below.
  # 
  # Dirty preliminary fix; hopefully in the future this will take a file 
  # as an input and read the recodes from there.
  if(country=='AR'){
    if(source=='ipums'){
      # Gender:         
      dt$gend <- dt$SEX
      # Age:
      dt$age <- mapvalues(dt$AGE, from=c(999), to=c(NA))
      # Education:    
      dt$ed <- rep(NA,length=length(dt$AR2010A_EDLEV))
      dt$ed[dt$AR2010A_EDLEV%in%c(1)] <- 1
      dt$ed[dt$AR2010A_EDLEV%in%c(2,3)] <- 2
      dt$ed[dt$AR2010A_EDLEV%in%c(4,5)] <- 3
      dt$ed[dt$AR2010A_EDLEV%in%c(6)] <- 4
      dt$ed[dt$AR2010A_EDLEV%in%c(7)] <- 5
      dt$ed[dt$AR2010A_EDLEV%in%c(8)] <- 6
      #Employment. RECONSIDER ORDERING.
      dt$emp <- rep(NA,length=length(dt$EMPSTAT))
      dt$emp[dt$EMPSTAT==1] <- 1 # working
      dt$emp[dt$EMPSTAT==2] <- 2 # unemployed
      dt$emp[dt$EMPSTAT==3] <- 3 # not in workforce
      #Have Bath?
      dt$bath[dt$BATH==1] <- 2
      dt$bath[dt$BATH%in%c(3,4)] <- 1
      #number of persons in household
      dt$pern <- dt$PERSONS
      #head of household?
      dt$hhh <- rep(NA,length=length(dt$RELATE))
      dt$hhh[dt$RELATE>1] <- 2
      dt$hhh[dt$RELATE==1] <- 1
    }
    else if(source=='netquest'){
      # Gender:
      dt$gend <- dt$p_sexo
      #Age:          is fine, need to filter these to make sure we exclude too young respondents.
      dt$age <- dt$panelistAge
      dt$age[dt$panelistAge>100] <- 100
      #Education:    EDUCCL partially matches CL_education_level; the census doesn't count postgrad so have to collapse in panel
      dt$ed <- mapvalues(dt$AR_education_level,
                               from=c(1,2,3,4,5,6,7,8,9,10,11),
                               to  =c(1,1,2,2,3,3,4,4,5, 6,NA)
                               )
      #Employment. RECONSIDER ORDERING.
      dt$emp <- mapvalues(dt$AR_laboral_situation,
             from=c(1,2,3,4,5,6),
             to=  c(1,2,3,3,3,3))
      #Have Bath?
      dt$bath <- dt$AR_bath_athome
      #number of persons in household
      dt$pern <- dt$P2
      #head of household?
      dt$hhh <- mapvalues(dt$P12,
                                from=c(1,2,3),
                                to  =c(1,2,1)
                                )    
    }
    else {print("Unknown source!")}
   
  }
  else {print("Unknown country!")}
  return(dt)
}
