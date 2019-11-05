countryRecode <- function(dt, source, country){
  require(plyr)
  ###Function to recode census datatables.
  # Takes as input a datatable or similar object, an indication where 
  # it came from (ipums or dt), and the country it pertains to.
  # Returns the dataframe with the variables added in as defined below.
  # 
  # To add further countries: add the various recoding steps for ipums
  # and netquest below.
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
   
  } else if(country=="MX"){
    if(source=="ipums"){
      #Gender:  
      dt$gend <- dt$SEX
      #Age:     
      dt$age <- mapvalues(dt$AGE, from=c(999), to=c(NA))
      #Education:    
      dt$ed <- rep(NA,length=length(dt$EDUCMX))
      dt$ed[dt$EDUCMX== 10] <- 1
      dt$ed[dt$EDUCMX>= 20 & dt$EDUCMX<= 29] <- 2
      dt$ed[dt$EDUCMX>=100 & dt$EDUCMX<=109] <- 3
      dt$ed[dt$MX2015A_EDLEVEL==2] <- 4
      dt$ed[dt$EDUCMX>=200 & dt$EDUCMX<=229] <- 5
      dt$ed[dt$MX2015A_EDLEVEL==3] <- 6
      dt$ed[dt$MX2015A_EDLEVEL%in%c(6,7,8,9)] <- 7
      dt$ed[dt$EDUCMX>=300 & dt$EDUCMX<=339] <- 8
      dt$ed[dt$MX2015A_EDLEVEL%in%c(4,5)] <- 9
      dt$ed[dt$EDUCMX>=610 & dt$EDUCMX<=619] <- 10
      dt$ed[dt$MX2015A_EDLEVEL%in%c(10,11)] <- 11
      dt$ed[dt$MX2015A_EDLEVEL%in%c(12,13)] <- 12
      dt$ed[dt$MX2015A_EDLEVEL==14] <- 13
      #Education HHH
      dt$ed_hhh <- rep(NA,length=length(dt$EDUCMX_HEAD))
      dt$ed_hhh[dt$EDUCMX_HEAD== 10] <- 1
      dt$ed_hhh[dt$EDUCMX_HEAD>= 20 & dt$EDUCMX_HEAD<= 29] <- 2
      dt$ed_hhh[dt$EDUCMX_HEAD>=100 & dt$EDUCMX_HEAD<=109 & dt$MX2015A_EDLEVEL_HEAD<2] <- 3
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD==2] <- 4
      dt$ed_hhh[dt$EDUCMX_HEAD>=200 & dt$EDUCMX_HEAD<=229 & dt$MX2015A_EDLEVEL_HEAD< 3] <- 5
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD==3] <- 6
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD%in%c(6,7,8,9)] <- 7
      dt$ed_hhh[dt$EDUCMX_HEAD>=300 & dt$EDUCMX_HEAD<=339 & dt$MX2015A_EDLEVEL_HEAD< 4] <- 8
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD%in%c(4,5)] <- 9
      dt$ed_hhh[dt$EDUCMX_HEAD>=610 & dt$EDUCMX_HEAD<=619 & dt$MX2015A_EDLEVEL_HEAD<10] <- 10
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD%in%c(10,11)] <- 11
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD%in%c(12,13)] <- 12
      dt$ed_hhh[dt$MX2015A_EDLEVEL_HEAD==14] <- 13
      #Employment. RECONSIDER ORDERING.
      dt$emp <- rep(NA,length=length(dt$EDUCMX_HEAD))
      dt$emp[dt$MX2015A_EMPSTAT%in%c(10,12,16)] <- 1 
      dt$emp[dt$MX2015A_CLASSWK%in%c(4,5)] <- 1     # Trabajo actualmente por cuenta propia
      dt$emp[dt$MX2015A_EMPSTAT%in%c(11,13,14,15)] <- 3 
      dt$emp[dt$MX2015A_CLASSWK%in%c(1,2,3)] <- 2   # Trabajo actualmente como empleado
      dt$emp[dt$MX2015A_EMPSTAT== 31] <- 3          # Estudiante (sin trabajar)
      dt$emp[dt$MX2015A_EMPSTAT== 20] <- 4          # Desempleado
      dt$emp[dt$MX2015A_EMPSTAT== 32] <- 5          # Retirado/Pensionista
      dt$emp[dt$MX2015A_EMPSTAT== 34] <- 6          # Incapacitado
      dt$emp[dt$MX2015A_EMPSTAT== 33] <- 7          # Labores del hogar
      dt$emp[dt$MX2015A_EMPSTAT== 35] <- 7          # Did not work--assume that means they did housework
      #  Employment of head of household: see above
      dt$emp_hhh <- rep(NA,length=length(dt$EDUCMX_HEAD))
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD%in%c(10,12,16)] <- 1 
      dt$emp_hhh[dt$MX2015A_CLASSWK_HEAD%in%c(4,5)] <- 1     # Trabajo actualmente por cuenta propia
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD%in%c(11,13,14,15)] <- 3 
      dt$emp_hhh[dt$MX2015A_CLASSWK_HEAD%in%c(1,2,3)] <- 2   # Trabajo actualmente como empleado
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD== 31] <- 3          # Estudiante (sin trabajar)
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD== 20] <- 4          # Desempleado
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD== 32] <- 5          # Retirado/Pensionista
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD== 34] <- 6          # Incapacitado
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD== 33] <- 7          # Labores del hogar
      dt$emp_hhh[dt$MX2015A_EMPSTAT_HEAD== 35] <- 7          # Did not work--assume that means they did housework
      #Auto
      dt$auto <- mapvalues(dt$AUTOS,
              from=c(0,7,8,9),
              to=  c(2,1,NA,NA))
      #Computer?
      dt$pc <- mapvalues(dt$COMPUTER, 
                             from=c(0,1,2,9), 
                             to=c(NA,2,1,NA))
      #Internet?
      dt$web <- mapvalues(dt$INTERNET, from=c(0,1,2,9), to=c(NA,2,1,NA))
      #Lightbulbs?
      dt$lightbulb <- rep(NA,length=length(dt$MX2015A_LIGHTBULB))
      dt$lightbulb[dt$MX2015A_LIGHTBULB>= 0 & dt$MX2015A_LIGHTBULB<= 5] <- 1
      dt$lightbulb[dt$MX2015A_LIGHTBULB>= 6 & dt$MX2015A_LIGHTBULB<=10] <- 2
      dt$lightbulb[dt$MX2015A_LIGHTBULB>=11 & dt$MX2015A_LIGHTBULB<=15] <- 3
      dt$lightbulb[dt$MX2015A_LIGHTBULB>=16 & dt$MX2015A_LIGHTBULB<=20] <- 4
      dt$lightbulb[dt$MX2015A_LIGHTBULB>=21 & dt$MX2015A_LIGHTBULB<=90] <- 5
      #When going numeric, must replace NA with the average
      dt$floors <- mapvalues(dt$MX2015A_FLOOR,
              from=c(1, 2, 3, 8, 9),
              to=  c(1, 1, 2,NA,NA))
      #Number of rooms
      dt$nrooms <- rep(NA,length=length(dt$MX2015A_ROOMS))
      dt$nrooms[dt$MX2015A_ROOMS<7] <- dt$MX2015A_ROOMS[dt$MX2015A_ROOMS<7]
      dt$nrooms[dt$MX2015A_ROOMS>=7 & dt$MX2015A_ROOMS<=20] <- 7 
      #Shower?
      dt$shower <- rep(NA,length=length(dt$MX2015A_SHOWER))
      dt$shower[dt$MX2015A_SHOWER<3] <-  dt$MX2015A_SHOWER[dt$MX2015A_SHOWER<3]
      #Number of TVs
      dt$tv[dt$MX2015A_TV%in%c(1,2)] <- dt$MX2015A_TV[dt$MX2015A_TV%in%c(1,2)]
      #Children
      dt$child<-rep(NA, length=length(dt$NCHILD))
      dt$child[dt$NCHILD<=7] <- dt$NCHILD[dt$NCHILD<=7]
      dt$child[dt$NCHILD>7] <- 7
      #Marital status: 
      dt$marst <- mapvalues(dt$MARST,
                                from=c(1,2,3,4,9),
                                to  =c(1,4,2,3,NA)
                                )
      #number of persons in household
      dt$pern <- dt$PERSONS
      #type of household
      dt$hhtype <- mapvalues(dt$HHTYPE,
                                from=c(1,5,6,7,8,2,3,4,11,99, 0),
                                to  =c(1,5,5,6,6,2,4,3, 0, 0,NA)
                                )
      #head of household?
      dt$hhh <- rep(NA,length=length(dt$RELATE))
      dt$hhh[dt$RELATE>1] <- 2
      dt$hhh[dt$RELATE==1] <- 1
      
      
    } else if(source=='netquest'){
      #Gender:         
      dt$gend <- dt$p_sexo
      #Age:       
      dt$age <- dt$panelistAge
      dt$age[dt$panelistAge>100] <- 100
      #Education:    
      dt$ed <- mapvalues(dt$MX_education_level_merge,
                               from=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14),
                               to  =c(1,2,3,4,5,6,7,7,8, 9,10,11,12,13)
                               )
      #Education HHH
      dt$ed_hhh <- mapvalues(dt$MX_education_level_hhousehold_merge,
                               from=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14),
                               to  =c(1,2,3,4,5,6,7,7,8, 9,10,11,12,13)
                               )
      #Employment. RECONSIDER ORDERING.
      dt$emp <- mapvalues(dt$MX_laboral_situation,
             from=c(1,2,3,4,5,6,7,8,9),
             to=  c(1,2,3,4,4,5,5,6,7))
      #  Employment of head of household: see above
      dt$emp_hhh <- mapvalues(dt$MX_laboral_situation_hhousehold,
             from=c(1,2,3,4,5,6,7,8,9),
             to=  c(1,2,3,4,4,5,5,6,7))
      #Auto
      dt$auto <- mapvalues(dt$MX_NSE_cars,
             from=c(1,2,3,4),
             to=  c(2,1,1,1))
      #Computer?
      dt$pc <- mapvalues(dt$MX_NSE_computer,
                               from=c(1,2,3),
                               to  =c(2,1,1)
                               )
      #Internet?
      dt$web <- mapvalues(dt$MX_NSE_internet_at_home, from = c(1,2), to=c(1,2))
      #Lightbulbs?
      dt$lightbulb <- dt$MX_NSE_lights
      #Floors
      dt$floors <- mapvalues(dt$MX_NSE_pavement,
              from=c(1, 2),
              to=  c(1, 2))
      #Number of rooms
      dt$nrooms <- dt$MX_NSE_rooms
      #Shower?
      dt$shower <- dt$MX_NSE_shower
      #Number of TVs
      dt$tv <- mapvalues(dt$MX_NSE_tv,
                               from=c(1,2,3,4),
                               to  =c(2,1,1,1)
                               )
      #Children
      dt$child <- dt$number_P3
      dt$child[dt$P3==2] <- 0
      #Marital status: need P1 from dt!
      dt$marst <- mapvalues(dt$P1,
                                from=c(1,2,3,4),
                                to  =c(1,4,2,3)
                                )

      #number of persons in household
      dt$pern <- dt$P2
      
      #type of household
      dt$hhtype <- mapvalues(dt$P8,
                                from=c(1,2,3,4,5,6,7,99),
                                to  =c(1,5,6,2,4,3,5, 0)
                                )
      
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
