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
    
    
   
  
    } else if(country=='BR'){
    if(source=='ipums'){
      # Gender:         
      dt$gend <- dt$SEX
      # Age:
      dt$age <- mapvalues(dt$AGE, from=c(999), to=c(NA))
      # Education:    
      dt$ed <- rep(NA, length=length(dt$EDUCBR))
      dt$ed[dt$EDUCBR==0] <- 1
      dt$ed[dt$EDUCBR>=1000 & dt$EDUCBR<=2140] <- 2
      dt$ed[(dt$EDUCBR==2141)|(dt$EDUCBR==2190)] <- 3
      dt$ed[(dt$EDUCBR>=2210 & dt$EDUCBR<=2230)|dt$EDUCBR==2900] <- 4
      dt$ed[(dt$EDUCBR==2241)|(dt$EDUCBR==2290)] <- 5
      dt$ed[dt$EDUCBR>=3100 & dt$EDUCBR<=3200] <- 6
      dt$ed[dt$EDUCBR %in% c(3300, 3900)] <- 7
      dt$ed[dt$EDUCBR %in% c(4170, 4180)] <- 8
      dt$ed[dt$EDUCBR==4190] <- 9
      dt$ed[dt$EDUCBR %in% c(4270, 4280)] <- 10
      dt$ed[dt$EDUCBR %in% c(4230, 4240)] <- 11
      dt$ed[dt$EDUCBR %in% c(4250, 4260)] <- 12
      #Employment. RECONSIDER ORDERING.
      dt$emp <- mapvalues(dt$EMPSTAT,
              from=c(1, 2, 3,  0),
              to=  c(1, 3, 4, NA))
      dt$emp[dt$CLASSWK==2]<- 2   # Wage/salary worker
      # Auto:
      dt$auto <- mapvalues(dt$AUTOS,
        from=c(0,7,9),
        to=  c(2,1,NA))
      #Have Bath?
      dt$nbath <- mapvalues(dt$BATH,
              from=c(1,2,0),
              to=  c(2,1,NA))
      # Computer:
      dt$pc <- mapvalues(dt$COMPUTER,
                       from=c(1,2,0),
                       to  =c(2,1,NA)
                       )
      # fridge:
      dt$fridg <- mapvalues(dt$REFRIG,
                       from=c(1,2,0),
                       to  =c(2,1,NA)
                       )
      # Washing machine:
      dt$washer <- mapvalues(dt$WASHER,
                       from=c(1,2,0),
                       to  =c(2,1,NA)
                       )
      # Children:
      dt$child<-dt$NCHILD
      dt$child[dt$NCHILD>7] <- 7
      # marital status:
      
      dt$marst <- mapvalues(dt$MARST,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                            )
      # radio:
      dt$radio <- mapvalues(dt$RADIO,
                       from=c(1,2,0),
                       to  =c(2,1,NA)
                       )
      # TV:
      dt$tv <- mapvalues(dt$TV,
                       from=c(10,20,0),
                       to  =c(2,1,NA)
                       )

      #number of persons in household
      dt$pern <- dt$PERSONS
      # type of household
      dt$hhtype <- mapvalues(dt$HHTYPE,
                          from=c(1,5,6,7,8,2,3,4,6,11,99, 0),
                          to  =c(1,5,5,6,6,2,4,3,5, 0, 0,NA)
                          )

      #head of household?
      dt$hhh <- vector(length=length(dt$RELATE))
      dt$hhh[dt$RELATE>1] <- 2
      dt$hhh[dt$RELATE==1] <- 1
    }
    else if(source=='netquest'){
      # Gender:
      dt$gend <- dt$p_sexo
      #Age:         
      dt$age <- dt$panelistAge
      dt$age[dt$panelistAge>100] <- 100
      #Education:    EDUCCL partially matches CL_education_level; the census doesn't count postgrad so have to collapse in panel
      dt$ed <- as.integer(dt$BR_education_level_full)
      #Employment. RECONSIDER ORDERING.
      dt$emp <- mapvalues(dt$BR_laboral_situation,
             from=c(1,2,3,4,5,6,7,8,9),
             to=  c(2,1,4,3,4,3,4,4,4))
      # Auto:
      dt$auto <- mapvalues(dt$BR_numAutos,
       from=c(1,2,3,4,5),
       to=  c(2,1,1,1,1))
      #Have Bath?
      dt$nbath <- mapvalues(dt$BR_numBaths,
             from=c(1,2,3,4,5),
             to=  c(2,1,1,1,1))
      
      # Computer:
      dt$pc <- mapvalues(dt$BR_numComputer,
                         from=c(1,2,3,4,5),
                         to  =c(2,1,1,1,1)
                         )
      # Fridge:
      dt$fridg <- mapvalues(dt$BR_numFridge,
                         from=c(1,2,3,4,5),
                         to  =c(2,1,1,1,1)
                         )
      # Washer:
      dt$washer <- mapvalues(dt$BR_numWashmachine,
                         from=c(1,2,3,4,5),
                         to  =c(2,1,1,1,1)
                         )
      # child:
      dt$child <- dt$number_P3
      dt$child[dt$P3==2] <- 0
      # marital status:
      dt$marst <- mapvalues(dt$P1,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                          )
      # radio:
      dt$radio <- mapvalues(dt$BR_2012_numRadio,
                         from=c(1,2,3,4,5),
                         to  =c(2,1,1,1,1)
                         )
      # TV:
      dt$tv <- mapvalues(dt$BR_2012_numTV,
                         from=c(1,2,3,4,5),
                         to  =c(2,1,1,1,1)
                         )

      #number of persons in household
      dt$pern <- dt$P2
      # household type
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
    
      } else if(country=='CL'){
    if(source=='ipums'){
      # Gender:         
      dt$gend <- dt$SEX
      # Age:
      dt$age <- mapvalues(dt$AGE, from=c(999), to=c(NA))
      # Education:    
      dt$ed[dt$EDUCCL==0] <- 1
      dt$ed[dt$EDUCCL>=221 & dt$EDUCCL<=227] <- 2
      dt$ed[dt$EDUCCL==228] <- 3
      dt$ed[dt$EDUCCL>=311 & dt$EDUCCL<=393] <- 4
      dt$ed[dt$EDUCCL %in% c(316, 324,325, 334,335, 344, 345, 354, 355, 364, 365, 386, 387, 394)] <- 5
      dt$ed[dt$EDUCCL>=400] <- 6
      # Education head of household:
      dt$ed_hhh[dt$EDUCCL_HEAD==0] <- 1
      dt$ed_hhh[dt$EDUCCL_HEAD>=221 & dt$EDUCCL_HEAD<=227] <- 2
      dt$ed_hhh[dt$EDUCCL_HEAD==228] <- 3
      dt$ed_hhh[dt$EDUCCL_HEAD>=311 & dt$EDUCCL_HEAD<=393] <- 4
      dt$ed_hhh[dt$EDUCCL_HEAD %in% c(316, 324,325, 334,335, 344, 345, 354, 355, 364, 365, 386, 387, 394)] <- 5
      dt$ed_hhh[dt$EDUCCL_HEAD>=400] <- 6

      #Employment. RECONSIDER ORDERING.
      dt$emp <- mapvalues(dt$EMPSTATD,
          from=c(110,120,330,210,220,390,340,320,310,  0),
          to=  c(  1,  1,  4,  6,  5,  8,  8,  9,  3, NA))
      dt$emp[dt$CLASSWK==2]<- 2   # Wage/salary worker
      # Employment HHH:
      dt$emp_hhh <- mapvalues(dt$EMPSTATD_HEAD,
          from=c(110,120,330,210,220,390,340,320,310,  0),
          to=  c(  1,  1,  4,  6,  5,  8,  8,  9,  3, NA))
      dt$emp_hhh[dt$CLASSWK_HEAD==2]<- 2
      # Auto:
      dt$auto <- mapvalues(dt$AUTOS,
        from=c(0,7,9),
        to=  c(2,1,NA))
      # Cellphone (this may be a bad variable in Chile given the changes since 2002)
      dt$cell <- mapvalues(dt$CL2002A_CELLPH,
          from=c(1,2,0),
          to=  c(1,2,NA))
      # Children:
      dt$child<-dt$NCHILD
      dt$child[dt$NCHILD>7] <- 7
      # marital status:
      
      dt$marst <- mapvalues(dt$MARST,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                            )
      # number of persons in household
      dt$pern <- dt$PERSONS
      # type of household
      dt$hhtype <- mapvalues(dt$HHTYPE,
                          from=c(1,5,6,7,8,2,3,4,6,11,99, 0),
                          to  =c(1,5,5,6,6,2,4,3,5, 0, 0,NA)
                          )

      #head of household?
      dt$hhh <- vector(length=length(dt$RELATE))
      dt$hhh[dt$RELATE>1] <- 2
      dt$hhh[dt$RELATE==1] <- 1
    }
    else if(source=='netquest'){
      # Gender:
      dt$gend <- dt$p_sexo
      #Age:         
      dt$age <- dt$panelistAge
      dt$age[dt$panelistAge>100] <- 100
      #Education:    EDUCCL partially matches CL_education_level; the census doesn't count postgrad so have to collapse in panel
      dt$ed <- mapvalues(as.integer(dt$CL_education_level),
        from=c(6, 7, 8, 9),
        to=  c(6, 6, 6, 6))
      # Education HHH
      dt$ed_hhh <- mapvalues(as.integer(dt$CL_education_level_hhousehold),
          from=c(6, 7, 8, 9),
          to=  c(6, 6, 6, 6))
      #Employment. RECONSIDER ORDERING.
      dt$emp <- mapvalues(dt$CL_laboral_situation,
         from=c(1,2,3,4,5,6,7,8,9),
         to=  c(1,2,4,6,5,8,8,9,3))
      # Employment HHH:
      dt$emp_hhh <- mapvalues(dt$CL_laboral_situation_hhousehold,
       from=c(1,2,3,4,5,6,7,8,9),
       to=  c(1,2,4,6,5,8,8,9,3))
      # Auto:
      dt$auto <- mapvalues(dt$CL_NSE_hasvehicle_hhousehold,
          from=c(1,2),
          to=  c(1,2))
      # cellphone: 
      dt$cell <- mapvalues(dt$CL_NSE_mobilecontract_hhousehold,
         from=c(1,2,3),
         to=  c(1,1,2))
      # child:
      dt$child <- dt$number_P3
      dt$child[dt$P3==2] <- 0
      # marital status:
      dt$marst <- mapvalues(dt$P1,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                          )
      #number of persons in household
      dt$pern <- dt$P2
      # household type
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
    
      
      } else if(country=='CO'){
    if(source=='ipums'){
      # Gender:         
      dt$gend <- dt$SEX
      # Age:
      dt$age <- mapvalues(dt$AGE, from=c(999), to=c(NA))
      # Education:    
      census$ed[census$EDUCCO<=250 | census$EDUCCO==270] <- 1
      census$ed[census$EDUCCO==260] <- 2
      census$ed[census$EDUCCO>=320 & census$EDUCCO<=380] <- 3
      census$ed[census$EDUCCO>=390 & census$EDUCCO<=439] <- 4
      census$ed[census$EDUCCO>=440 & census$EDUCCO<=449] <- 5
      census$ed[census$EDUCCO>=500 & census$EDUCCO<=590] <- 6
      # Education head of household:
      census$ed_hhh[census$EDUCCO_HEAD<=250 | census$EDUCCO_HEAD==270] <- 1
      census$ed_hhh[census$EDUCCO_HEAD==260] <- 2
      census$ed_hhh[census$EDUCCO_HEAD>=320 & census$EDUCCO_HEAD<=380] <- 3
      census$ed_hhh[census$EDUCCO_HEAD>=390 & census$EDUCCO_HEAD<=439] <- 4
      census$ed_hhh[census$EDUCCO_HEAD>=440 & census$EDUCCO_HEAD<=449] <- 5
      census$ed_hhh[census$EDUCCO_HEAD>=500 & census$EDUCCO_HEAD<=590] <- 6

      #Employment. RECONSIDER ORDERING.
      census$emp <- mapvalues(census$CO2005A_EMPSTAT,
        from=c(  1,  5,  3,  4,  8,  7,  6,  9, 98, 99),
        to=  c(  1,  4,  6,  5,  8,  9,  3, NA, NA, NA))
      census$emp[census$CLASSWK==2]<- 2

      # Employment HHH:
      census$emp_hhh <- mapvalues(census$CO2005A_EMPSTAT_HEAD,
        from=c(  1,  5,  3,  4,  8,  7,  6,  9, 98, 99),
        to=  c(  1,  4,  6,  5,  8,  9,  3, NA, NA, NA))
      census$emp_hhh[census$CLASSWK_HEAD==2]<- 2
      # Children:
      dt$child<-dt$NCHILD
      dt$child[dt$NCHILD>7] <- 7
      # marital status:
      
      dt$marst <- mapvalues(dt$MARST,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                            )
      # number of persons in household
      dt$pern <- dt$PERSONS
      # type of household
      dt$hhtype <- mapvalues(dt$HHTYPE,
                          from=c(1,5,6,7,8,2,3,4,6,11,99, 0),
                          to  =c(1,5,5,6,6,2,4,3,5, 0, 0,NA)
                          )

      #head of household?
      dt$hhh <- vector(length=length(dt$RELATE))
      dt$hhh[dt$RELATE>1] <- 2
      dt$hhh[dt$RELATE==1] <- 1
    }
    else if(source=='netquest'){
      # Gender:
      dt$gend <- dt$p_sexo
      #Age:         
      dt$age <- dt$panelistAge
      dt$age[dt$panelistAge>100] <- 100
      #Education:    EDUCCL partially matches CL_education_level; the census doesn't count postgrad so have to collapse in panel
      netquest$ed <- as.integer(netquest$CO_education_level)
      # Education HHH
      netquest$ed_hhh <- as.integer(netquest$CO_education_level_hhousehold)
      #Employment. RECONSIDER ORDERING.
      netquest$emp <- mapvalues(netquest$CO_laboral_situation,
             from=c(1,2,3,4,5,6,7,8,9),
             to=  c(1,2,4,6,5,8,8,9,3))
      # Employment HHH:
      netquest$emp_hhh <- mapvalues(netquest$CO_laboral_situation_hhousehold,
             from=c(1,2,3,4,5,6,7,8,9),
             to=  c(1,2,4,6,5,8,8,9,3))
      # child:
      dt$child <- dt$number_P3
      dt$child[dt$P3==2] <- 0
      # marital status:
      dt$marst <- mapvalues(dt$P1,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                          )
      #number of persons in household
      dt$pern <- dt$P2
      # household type
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
      
      
    
      } 
        else if(source=='netquest'){
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
  
      } else if (country=="PE"){
     if(source=='ipums'){
      # Gender:         
      dt$gend <- dt$SEX
      # Age:
      dt$age <- mapvalues(dt$AGE, from=c(999), to=c(NA))
      # Education:    
      dt$ed[dt$EDUCPE==100] <- 1
      dt$ed[dt$EDUCPE>= 110 & dt$EDUCPE<=305] <- 2
      dt$ed[dt$EDUCPE==306 | dt$EDUCPE==611] <- 3
      dt$ed[dt$EDUCPE==612] <- 4
      dt$ed[dt$EDUCPE==621] <- 5
      dt$ed[dt$EDUCPE==622] <- 6
      # Education head of household:
      dt$ed_hhh[dt$EDUCPE_HEAD==100] <- 1
      dt$ed_hhh[dt$EDUCPE_HEAD>= 110 & dt$EDUCPE_HEAD<=305] <- 2
      dt$ed_hhh[dt$EDUCPE_HEAD==306 | dt$EDUCPE_HEAD==611] <- 3
      dt$ed_hhh[dt$EDUCPE_HEAD==612] <- 4
      dt$ed_hhh[dt$EDUCPE_HEAD==621] <- 5
      dt$ed_hhh[dt$EDUCPE_HEAD==622] <- 6

      #Employment. RECONSIDER ORDERING.
      dt$emp[dt$EMPSTATD==117] <- 1
      dt$emp[dt$EMPSTATD==110 | dt$EMPSTATD==120] <- 2
      dt$emp[dt$EMPSTATD==330] <- 3
      dt$emp[dt$EMPSTATD==210] <- 4
      dt$emp[dt$EMPSTATD==220] <- 5
      dt$emp[dt$EMPSTATD==341 | dt$EMPSTATD==343] <- 6
      dt$emp[dt$EMPSTATD==310] <- 8
      dt$emp[dt$DISEMP==1]<- 7
      # Employment HHH:
      dt$emp_hhh[dt$EMPSTATD_HEAD_HEAD==117] <- 1
      dt$emp_hhh[dt$EMPSTATD_HEAD==110 | dt$EMPSTATD_HEAD==120] <- 2
      dt$emp_hhh[dt$EMPSTATD_HEAD==330] <- 3
      dt$emp_hhh[dt$EMPSTATD_HEAD==210] <- 4
      dt$emp_hhh[dt$EMPSTATD_HEAD==220] <- 5
      dt$emp_hhh[dt$EMPSTATD_HEAD==341 | dt$EMPSTATD_HEAD==343] <- 6
      dt$emp_hhh[dt$EMPSTATD_HEAD==310] <- 8
      dt$emp_hhh[dt$DISEMP_HEAD==1]<- 7
      # Offwater:
      dt$bath[dt$PE2007A_SEWAGE==6] <- 1
      dt$bath[dt$PE2007A_SEWAGE%in%c(3, 4, 5)] <- 2
      dt$bath[dt$PE2007A_SEWAGE==2] <- 3
      dt$bath[dt$PE2007A_SEWAGE==6] <- 4
      # Health insurance:
      dt$health[dt$PE2007A_INSURSIS_HEAD==1 | dt$PE2007A_INSURNON_HEAD==1] <- 1
      dt$health[dt$PE2007A_INSURESS_HEAD==1] <- 2
      dt$health[dt$PE2007A_INSUROTH_HEAD==1] <- 3
      # Floor:
      dt$floor[dt$PE2007A_FLOOR==1] <- 1
      dt$floor[dt$PE2007A_FLOOR%in%c(2,5)] <- 2
      dt$floor[dt$PE2007A_FLOOR%in%c(3,6)] <- 3
      dt$floor[dt$PE2007A_FLOOR==4] <- 4
      dt$floor[dt$PE2007A_FLOOR==7] <- NaN
      # Walls:
      dt$wall[dt$PE2007A_WALL==5] <- 1
      dt$wall[dt$PE2007A_WALL%in%c(2,3,4,6)] <- 2
      dt$wall[dt$PE2007A_WALL==7] <- 3
      dt$wall[dt$PE2007A_WALL==1] <- 4
      # Children:
      dt$child<-dt$NCHILD
      dt$child[dt$NCHILD>7] <- 7
      # marital status:
      dt$marst <- mapvalues(dt$MARST,
                          from=c(1,2,3,4),
                          to  =c(1,4,2,3)
                            )
      # type of household
      dt$hhtype <- mapvalues(dt$HHTYPE,
                          from=c(1,5,6,7,8,2,3,4,6,11,99, 0),
                          to  =c(1,5,5,6,6,2,4,3,5, 0, 0,NA)
                          )
      #head of household?
      dt$hhh <- vector(length=length(dt$RELATE))
      dt$hhh[dt$RELATE>1] <- 2
      dt$hhh[dt$RELATE==1] <- 1
      # number of persons in household
      dt$pern <- dt$PERSONS
    } 
        else if (source=='netquest'){
          # Gender:         
          dt$gend <- dt$p_sexo
          #Age:       
          dt$age <- dt$panelistAge
          dt$age[dt$panelistAge>100] <- 100
          # Education:    
          dt$ed[dt$PE_education_level==1] <- 1
          dt$ed[dt$PE_education_level==2] <- 2
          dt$ed[dt$PE_education_level==3] <- 3
          dt$ed[dt$PE_education_level==4] <- 4
          dt$ed[dt$PE_education_level==5] <- 5
          dt$ed[dt$PE_education_level%in%c(6,7)] <- 6
          # Education head of household:
          dt$ed[dt$PE_education_level_hhousehold==1] <- 1
          dt$ed[dt$PE_education_level_hhousehold==2] <- 2
          dt$ed[dt$PE_education_level_hhousehold==3] <- 3
          dt$ed[dt$PE_education_level_hhousehold==4] <- 4
          dt$ed[dt$PE_education_level_hhousehold==5] <- 5
          dt$ed[dt$PE_education_level_hhousehold%in%c(6,7)] <- 6
          #Employment. RECONSIDER ORDERING.
          dt$emp <- dt$PE_laboral_situation
          dt$emp[dt$PE_laboral_situation==7] <- 6
          dt$emp[dt$PE_laboral_situation==8] <- 7
          dt$emp[dt$PE_laboral_situation==9] <- 8
          # Employment HHH:
          dt$emp <- dt$PE_laboral_situation_hhousehold
          dt$emp[dt$PE_laboral_situation_hhousehold==7] <- 6
          dt$emp[dt$PE_laboral_situation_hhousehold==8] <- 7
          dt$emp[dt$PE_laboral_situation_hhousehold==9] <- 8
          # Offwater:
          dt$bath <- dt$PE_NSE_bath
          # Health insurance:
          dt$health <- dt$PE_NSE_health
          dt$health[dt$PE_NSE_health==4] <- 3
          dt$health[dt$PE_NSE_health==5] <- NaN
          # Floor:
          dt$floor <- dt$PE_NSE_pavement
          dt$floor[dt$PE_NSE_pavement==4] <- 3
          dt$floor[dt$PE_NSE_pavement==5] <- 4
          # Walls:
          dt$wall[dt$PE2007A_WALL==5] <- 1
          dt$wall[dt$PE2007A_WALL%in%c(2,3,4,6)] <- 2
          dt$wall[dt$PE2007A_WALL==7] <- 3
          dt$wall[dt$PE2007A_WALL==1] <- 4
          # Children:
          dt$child <- dt$number_P3
          dt$child[dt$P3==2] <- 0
          # marital status:
          dt$marst <- mapvalues(dt$P1,
                                    from=c(1,2,3,4),
                                    to  =c(1,4,2,3)
                                    )
          # type of household
          dt$hhtype <- mapvalues(dt$P8,
                                    from=c(1,2,3,4,5,6,7,99),
                                    to  =c(1,5,6,2,4,3,5, 0)
                                    )
          # head of household?
          dt$hhh <- mapvalues(dt$P12,
                                    from=c(1,2,3),
                                    to  =c(1,2,1)
                                    )
          # number of persons in household
          dt$pern <- dt$P2
        }
        else {print("Unknown source!")}  
      }
  else {print("Unknown country!")}
  return(dt)
}
