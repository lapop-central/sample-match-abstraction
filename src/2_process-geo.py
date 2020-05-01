#!/usr/bin/env python
# coding: utf-8

# Loading packages

# In[263]:


import pandas as pd
pd.options.display.width = 0 #setting flexible print output width
pd.set_option('display.max_columns', 500)
from fuzzywuzzy import fuzz, process
#import re
import numpy as np



# Defining specific parameters
# In[1]:
params = pd.read_csv("./country_parameters1.csv")
params

# In[265]:


for country in ['AR','BR','CL',"CO",'MX',"PE"]:


# In[271]:

    
    if country == "AR":
        ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00015.csv"
    
    elif country == "BR":
        ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00026.csv"
        
    elif country == "CL":
        ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00020.csv"
        
    elif country=="CO":
        ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00022.csv"
        
    elif country=="MX":
        ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00021.csv"
        
    elif country=="PE":
        geo2_nq = "PE_provincia"
        geo1_nq = "PE_departamento"
        geo1_ipums = "GEO1_PE2007" # department
        geo2_ipums = "GEO2_PE2007" # province
        year = '2007'
        ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00032.csv"
      
    year = str(params[params.country==country].year.values[0])
    geo1_nq = params[params.country==country].geo1_nq.values[0]
    geo2_nq = params[params.country==country].geo2_nq.values[0]
    geo1_ipums = "GEO1_"+ country + year
    geo2_ipums = "GEO2_"+ country + year
    
    netquestfile = "../out/panel_country/"+country+"_netquest-panel.csv"
    dictfile = "../out/panel_country/"+country+"_levels.xlsx"
    geo2file = '../out/ipums_country/ipums_codebook_'+geo2_ipums+'.csv'
    geo1file = '../out/ipums_country/ipums_codebook_'+geo1_ipums+'.csv'
    centroidfile = '../out/geo/'+country+'_geo_centroids.csv'
    panelout = '../out/panel_country/'+country+'_netquest-panel_geo.csv'
    ipumsout = '../out/ipums_country/'+country+'_ipums-census_geo.csv'
    codebook1out = '../out/geo/'+country+'_geo1_codebook.csv'
    codebook2out = '../out/geo/'+country+'_geo2_codebook.csv'
    
    
    # Loading things
    
    # In[272]:
    
    
    netquestfile
    
    
    # In[278]:
    
    print("Reading in data...")
    census = pd.read_csv(ipumsfile)
    netquest = pd.read_csv(netquestfile)
    nq_dict = pd.read_excel(dictfile)
    if country=="AR":
        # deal with mis-stored values in the current extract
        nq_dict.Valor = nq_dict.Valor.astype(str).str.replace(",00","").astype(int)
    if country=="PE":
        ipums_geo2 = pd.read_csv(geo2file, names=['code','name'], skiprows=1)
        ipums_geo1 = pd.read_csv(geo1file, names=['code','name'], skiprows=1)
    else:
        ipums_geo2 = pd.read_csv(geo2file,encoding='Latin1', names=['code','name'], skiprows=1)
        ipums_geo1 = pd.read_csv(geo1file,encoding='Latin1', names=['code','name'], skiprows=1)
    
    
    geo2_centroids = pd.read_csv(centroidfile, encoding='latin1')
    
    
    # In[270]:
    
    
    [k for k in netquest.columns if k.startswith('AR')]
    
    
    # Defining functions
    
    # In[279]:
    
    
    # one for fuzzy-joining dataframes
    def fuzzy_join(df1, df2, varname, subset=False, cutoff=90):
        '''Returns a dataframe the length of df1, with the matches on the given variable
        
            Assumes the var is named the same in both dataframes.
            
            subset is a tuple or list of length 2 whose first element is a string indicating which
            variable in df1 has to be equal to which variable in df2 (specified by 2nd element)
            '''
        #figure out if there is a constraint
        if not subset:
            #match #1
            ratio_matches = df1.astype(str).apply(
                    lambda d: process.extract(d[varname], 
                                                 df2[varname].astype(str).drop_duplicates(),
                                                 scorer=fuzz.ratio, limit=2
                                                ), axis=1)
            #match #2
            parti_matches = df1.astype(str).apply(
                    lambda d: process.extract(d[varname], 
                                                 df2[varname].astype(str).drop_duplicates(),
                                                 scorer=fuzz.partial_ratio, limit=2
                                                ), axis=1)
            
        else:
            #match #1
            ratio_matches = df1.astype(str).apply(
                    lambda d: process.extract(d[varname], 
                                                 df2[varname][df2[subset[1]]==d[subset[0]]].astype(str).drop_duplicates(),
                                                 scorer=fuzz.ratio, limit=2
                                                ), axis=1)
            #match #2
            parti_matches = df1.astype(str).apply(
                    lambda d: process.extract(d[varname], 
                                                 df2[varname][df2[subset[1]]==d[subset[0]]].astype(str).drop_duplicates(),
                                                 scorer=fuzz.partial_ratio, limit=2
                                                ), axis=1)    
    
        
        # different match cases
        #morRatioMatch = ratio_matches.apply(lambda l: (l[0][1]==100)&(l[1][1]==100))
        oneRatioMatch = ratio_matches.apply(lambda l: (l[0][1]>=cutoff))#&(l[1][1]<100))
        noRatioMatch = ratio_matches.apply(lambda l: (l[0][1]<cutoff))
    
        #morPartiMatch = parti_matches.apply(lambda l: (l[0][1]==100)&(l[1][1]==100))
        onePartiMatch = parti_matches.apply(lambda l: (l[0][1]>=cutoff))#&(l[1][1]<100))
        noPartiMatch = parti_matches.apply(lambda l: (l[0][1]<cutoff))
        
        # pick out what's better
        matches = pd.Series([(np.nan,np.nan,np.nan)]*len(df1),index=df1.index)
        matches.loc[oneRatioMatch] = ratio_matches.loc[oneRatioMatch].apply(lambda l: l[0])
        matches.loc[(noRatioMatch&onePartiMatch)] = parti_matches.loc[(noRatioMatch&onePartiMatch)]        .apply(lambda l: l[0])
        matches.loc[(noRatioMatch&noPartiMatch)] = parti_matches.loc[(noRatioMatch&noPartiMatch)]        .apply(lambda l: l[0])
        
        df = pd.DataFrame()
        df['name'] = matches.apply(lambda l: l[0])
        df['score'] = matches.apply(lambda l: l[1])
        df['index'] = matches.apply(lambda l: l[2])
        df['parti_matches'] = parti_matches
        df['ratio_matches'] = ratio_matches
        
        return df
    
    
    # Setting up helper structures
    
    # In[280]:
    print("Setting up helper structures...")
    
    nq_geo1 = nq_dict[nq_dict.Variable==geo1_nq]
    nq_geo1.columns = ["Variable",geo1_nq,geo1_nq+"_name"]
    nq_geo1 = nq_geo1[[geo1_nq,geo1_nq+"_name"]]
    
    nq_geo2 = nq_dict[nq_dict.Variable==geo2_nq]
    nq_geo2.columns = ["Variable",geo2_nq,geo2_nq+"_name"]
    nq_geo2 = nq_geo2[[geo2_nq,geo2_nq+"_name"]]
    
    # setting up unique DF for geographies
    ipums_geodf = census[[geo1_ipums,geo2_ipums]]
    ipums_geodf.columns = ['geo1_code','geo2_code']
    ipums_geodf.drop_duplicates(subset=['geo1_code','geo2_code'],inplace=True)
    
    ipums_geodf['geo1_name'] = ipums_geodf.merge(ipums_geo1, 
                                                 how='left', 
                                                 left_on = "geo1_code", 
                                                 right_on = 'code', 
                                                 copy=False)['name'].values
    
    ipums_geodf['geo2_name'] = ipums_geodf.merge(ipums_geo2, 
                                                 how='left', 
                                                 left_on = "geo2_code", 
                                                 right_on = 'code', 
                                                 copy=False)['name'].values
    
    # Melting doubled-up geographies
    ipums_geodf = ipums_geodf.geo2_name.str.split(',').apply(pd.Series)     .merge(ipums_geodf, right_index = True, left_index = True)     .drop(["geo2_name"], axis = 1)     .melt(id_vars = [k for k in ipums_geodf.columns if not (type(k)==int)|(k=='geo2_name')], value_name = "geo2_name")     .drop("variable", axis = 1)     .dropna(subset=['geo2_name'])
    ipums_geodf.geo2_name = ipums_geodf.geo2_name.str.strip()
    
    ipums_geodf = ipums_geodf.geo1_name.str.split(',').apply(pd.Series)     .merge(ipums_geodf, right_index = True, left_index = True)     .drop(["geo1_name"], axis = 1)     .melt(id_vars = [k for k in ipums_geodf.columns if not (type(k)==int)|(k=='geo1_name')], value_name = "geo1_name")     .drop("variable", axis = 1)     .dropna(subset=['geo1_name'])
    ipums_geodf.geo1_name = ipums_geodf.geo1_name.str.strip()
    
    
    # Country-specific pre-processing
    
    # In[284]:
    # Create the netquest geoframe
    
    if country=="AR":
        # Consolidating all of CABA into one geography
        ipums_geodf.loc[ipums_geodf.geo1_name=="City of Buenos Aires",
                 'geo1_name'] = 'CABA'
        ipums_geodf.loc[(ipums_geodf.geo1_name=="CABA"),'geo2_name'] = 'CABA'
        caba_codes = ipums_geodf[ipums_geodf.geo1_name=="CABA"].geo2_code
        # dropping CABA-related duplicates
        ipums_geodf.drop_duplicates(subset=["geo1_name","geo2_name"], inplace=True)
        # make sure there is only one CABA-code left
        # print(len(ipums_geodf[ipums_geodf.geo1_name=="CABA"].geo2_code.values)==1)
        # set all the IPUMS records with CABA GEO2-codes to the one that is left in the geodf
        census.loc[census[geo2_ipums].isin(caba_codes),geo2_ipums] =  len(census.loc[census[geo2_ipums].isin(caba_codes),geo2_ipums])*[ipums_geodf[ipums_geodf.geo1_name=="CABA"].geo2_code[0]]
        
        # give Netquest CABA locations without geo2 a specific code: 999
        netquest.loc[netquest[geo2_nq].isna()&(netquest[geo1_nq]==1),geo2_nq] = 999
        # generate a df of geographies
        nq_geodf = netquest.merge(nq_geo2, on=geo2_nq, how='left'
                            ).merge(nq_geo1, on=geo1_nq, how='left')[[geo1_nq,geo1_nq+'_name',geo2_nq,geo2_nq+'_name']]
        nq_geodf.columns = ['geo1_code','geo1_name','geo2_code','geo2_name']
        nq_geodf.drop_duplicates(inplace=True)
        
        # Fixing CABA not having Dept.
        # Where province is CABA and no departamento exists, call these "CABA"
        nq_geodf.loc[nq_geodf.geo1_name=="Ciudad Autónoma de Buenos Aires",
                     'geo1_name'] = 'CABA'
        nq_geodf = nq_geodf[(nq_geodf['geo1_code'].notna()) & (nq_geodf['geo2_code'].notna())] 
        nq_geodf[nq_geodf.geo1_code==1]
    else:
        nq_geodf = netquest.merge(nq_geo2, on=geo2_nq, how='left')                       .merge(nq_geo1, on=geo1_nq, how='left')[[geo1_nq,geo1_nq+'_name',geo2_nq,geo2_nq+'_name']]
        nq_geodf.columns = ['geo1_code','geo1_name','geo2_code','geo2_name']
    
        nq_geodf.drop_duplicates(inplace=True)
    
    
    # Country-independent pre-processing
    
    # In[285]:
    
    
    #Finding the duplicates in nq_geodf.geo2_code, and keeping the combinations that occur most often (which are quite clearly the good ones).
    nq_geodf['count'] = nq_geodf.apply(
        lambda r: sum((netquest[geo1_nq]==r['geo1_code'])&
                      (netquest[geo2_nq]==r['geo2_code'])),
                                       axis=1)
    nq_geodf = nq_geodf.sort_values(['geo2_code','count'])     [~(nq_geodf.sort_values(['geo2_code','count']).duplicated('geo2_code',keep='last'))]
    
    nq_geodf.geo1_name = nq_geodf.geo1_name.str.title()
    nq_geodf.geo2_name = nq_geodf.geo2_name.str.title()
    
    
    # In[286]:
    
    
    nq_geodf
    
    
    # More country-specific processing--manual fixes:
    
    # In[290]:
    
    print("Cleaning up names...")
    if country=="AR":
        # Fix the location-NAs as CABA
        nq_geodf.loc[nq_geodf.geo2_code==999, 'geo2_name'] = "CABA"
        
        # harmonize IPUMS and Netquest
        ipums_geodf.loc[ipums_geodf.geo1_name.str.contains("Buenos Aires province"),
                     'geo1_name'] = "Buenos Aires"
        ipums_geodf.loc[ipums_geodf.geo2_name.str.contains("Puan"),
                        'geo2_name'] = "Puán"
        
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Chascomus")),
                        'geo2_name'] = "Chascomús"
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Jose C. Paz")),
                        'geo2_name'] = "José C. Paz"
        nq_geodf.loc[(nq_geodf.geo2_name.str.contains("Paso De Indios"))                    &(nq_geodf.geo1_name=="Chubut"),
                        'geo2_name'] = "Paso de los Indios"
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Coronel de Marine L. Rosales"))&(ipums_geodf.geo1_name=="Buenos Aires"),
                        'geo2_name'] = "Coronel De Marina Leonardo Rosales"
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Veinticinco de Mayo"))                    &(ipums_geodf.geo1_name=="Buenos Aires"),
                        'geo2_name'] = "25 de Mayo"
        nq_geodf.loc[(nq_geodf.geo2_name.str.contains("Pueyrredón"))                    &(nq_geodf.geo1_name=="Buenos Aires"),
                        'geo2_name'] = "General Pueyrredón"
                        
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("La Capital"))                    &(ipums_geodf.geo1_name=="San Luis"),
                        'geo2_name'] = "Juan Martín de Pueyrredón"
                        # La Capital renamed to JMdP in 2010
#        ipums_geodf.loc[(ipums_geodf.geo2_name=="Maipú")                    &(ipums_geodf.geo2_code==6050),
#                        'geo2_name'] = "Marcos Paz"
                        # problem with IPUMS data
        nq_geodf.loc[(nq_geodf.geo2_name==("Ciudad Libertador San Martín"))                    &(nq_geodf.geo1_name=="Buenos Aires"),
                        'geo2_name'] = "General San Martín"
                     # switching to official partido name
        
        
        
    elif country=="BR":
        # basic harmonization
        ipums_geodf.loc[ipums_geodf.geo1_name.str.contains("Federal District"),
                    'geo1_name'] = "Distrito Federal"
    
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Santarém"))& (ipums_geodf.geo1_name.str.contains("Paraíba")),
                        'geo2_name'] = "Joca Claudino"
                        # name change in 2010; using new name here
    
        ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Presidente Juscelino"))&                     (ipums_geodf.geo1_name.str.contains("Rio Grande do Norte")),
                        'geo2_name'] = "Serra Caiada"
                        # name change; using new name here        
    
        nq_geodf.loc[nq_geodf.geo2_name=="Pescaria Brava",'geo2_name'] = 'Laguna'
            # Pescaria Brava established 2013
        nq_geodf.loc[nq_geodf.geo2_name=="Balneário Rincão",'geo2_name'] = 'Içara'
            # B.R. est. 2013
        nq_geodf.loc[nq_geodf.geo2_name=="Pinto Bandeira",'geo2_name'] = 'Bento Gonçalves'
            # P.B. est. 2013
        nq_geodf.loc[nq_geodf.geo2_name=="Paraíso Das Águas",'geo2_name'] = 'Costa Rica'
            # P.d.A. est. 2012
    
    elif country=="CL":
        nq_geodf.geo1_name = nq_geodf.geo1_name.str.replace("Provincia ","")
        # Removing province moniker
        ipums_geodf.loc[(ipums_geodf.geo1_name=="Iquique") & (ipums_geodf.geo2_name=="Iquique"),["geo1_name","geo2_name"]] = ["Tarapacá", "Iquique"]
        ipums_geodf.loc[(ipums_geodf.geo1_name=="Iquique") & (ipums_geodf.geo2_name!="Iquique"),["geo1_name","geo2_name"]] = ["Tarapacá", "Tamarugal"]
        nq_geodf.loc[(nq_geodf.geo1_name=="Tamarugal"),["geo1_name","geo2_name"]] = ["Tarapacá", "Tamarugal"]
        nq_geodf.loc[(nq_geodf.geo1_name=="Iquique"),["geo1_name","geo2_name"]] = ["Tarapacá", "Iquique"]        
            # This is all Tarapacá region, with two provinces, which are IPUMS' smallest subdivision
        nq_geodf.loc[nq_geodf.geo1_name=="Diguillin",'geo1_name'] = 'Ñuble'
        nq_geodf.loc[nq_geodf.geo1_name=="Itata",'geo1_name'] = 'Ñuble'
        nq_geodf.loc[nq_geodf.geo1_name=="Punilla",'geo1_name'] = 'Ñuble'
            # The region is Ñuble, with comunas given in both IPUMS and Netquest
        nq_geodf.loc[nq_geodf.geo2_name=="Hualpén",'geo2_name'] = 'Talcahuano'
            # Hualpén separated from Talcahuano in 2004
        nq_geodf.loc[nq_geodf.geo2_name=="Cholchol",'geo2_name'] = 'Nueva Imperial'
            # Cholchol separated from Nueva Imperial in 2004
        nq_geodf.loc[nq_geodf.geo2_name=="Alto Bío-Bío",'geo2_name'] = 'Santa Bárbara'
            # Alto Bíobío separated from Santa Bárbara in 2003
        ipums_geodf.loc[ipums_geodf.geo1_code==63,"geo1_name"] = "Colchagua"
            # mistake in IPUMS dataset
        ipums_geodf.loc[ipums_geodf.geo2_name.isin(["Lago Ranco", "Futrono", "Río Bueno", 
                                                    "La Unión"
                                               ]),
                   'geo1_name'] = "Ranco"
            # Ranco separated from Valdivia in 2007; comunas given in both Netquest and IPUMS
        nq_geodf.loc[nq_geodf.geo2_name.isin(["Olmué","Limache"]),'geo1_name'] = 'Quillota'
        nq_geodf.loc[nq_geodf.geo2_name.isin(["Villa Alemana","Quilpué"]),'geo1_name'] = 'Valparaíso'
            # Marga Marga was put together with provinces from Valparaíso and Quillota in 2009. 
        # harmonizing with IPUMS
        
        nq_geodf.loc[nq_geodf.geo1_name=="Aysen",'geo1_name'] = 'Aisén'
        nq_geodf.loc[nq_geodf.geo2_name=="Aysen",'geo2_name'] = 'Aisén'
        # typos and spelling differences
        
    elif country=="CO":
        ipums_geodf.loc[(ipums_geodf.geo1_name=="Guania"),'geo1_name'] = 'Guainía'
        ipums_geodf.loc[(ipums_geodf.geo1_name=="Valle"),'geo1_name'] = 'Valle del Cauca'
        ipums_geodf.loc[(ipums_geodf.geo2_name=="Itagui"),'geo2_name'] = 'Itagüí'
        ipums_geodf.loc[(ipums_geodf.geo2_name=="Macheta"),'geo2_name'] = 'Machetá'
        ipums_geodf.loc[(ipums_geodf.geo2_name=="Mompós"),'geo2_name'] = "Santa Cruz de Mompox"
        ipums_geodf.loc[(ipums_geodf.geo2_name=="Anza"),'geo2_name'] = 'Anzá'
            # fixing/elaborating IPUMS names
        nq_geodf.loc[(nq_geodf.geo2_name.str.lower()=="san jose de ure"),'geo2_name'] = 'Montelíbano'
            # San José separated in 2007; still part of Montelíbano in IPUMS
        nq_geodf.loc[(nq_geodf.geo2_name=="Guachene"),'geo2_name'] = 'Caloto'
            # Guachené separated from Caloto in 2006
        nq_geodf.loc[(nq_geodf.geo2_name=="Tuchin"),'geo2_name'] = 'San Andrés Sotavento'
            # separated from San Andrés in 2008
        nq_geodf.loc[(nq_geodf.geo2_name=="Ramiquirí"),'geo2_name'] = 'Ramiriquí'
        nq_geodf.loc[(nq_geodf.geo2_name=="Villa Gamuez (La Hormiga)"),'geo2_name'] = 'Valle del Guamuez'
        nq_geodf.loc[(nq_geodf.geo2_name=="Imúes"),'geo2_name'] = 'Imués'
            # typo
        nq_geodf.loc[(nq_geodf.geo2_name=="Bogotá Distrito Capital (D. C.)"),'geo2_name'] = 'Bogotá'
        nq_geodf.loc[(nq_geodf.geo2_name=="Ubaté"),'geo2_name'] = 'Villa de San Diego de Ubate'
        nq_geodf.loc[(nq_geodf.geo2_name=="Suán"),'geo2_name'] = 'Suan'
        nq_geodf.loc[(nq_geodf.geo2_name=="Toluviejo"),'geo2_name'] = 'Tolú Viejo'
        nq_geodf.loc[(nq_geodf.geo2_name=="Páez (Belalcazar)"),'geo2_name'] = 'Paez'
            # harmonizing with IPUMS

    elif country=="MX":
        nq_geodf.loc[(nq_geodf.geo2_name=="Puerto Morelos")&(~nq_geodf.geo2_name.isna()),'geo2_name'] = 'Benito Juárez'
            # separated from Benito Juárez in 2015; still Benito Juárez in IPUMS
        ipums_geodf.loc[ipums_geodf.geo1_name.str.contains("Distrito Federal"),
                        'geo1_name'] = "Ciudad de México"
                        # Harmonizing naming--now Ciudad de Mexico
        nq_geodf.loc[nq_geodf.geo2_name.str.contains("Túxpam")&(~nq_geodf.geo2_name.isna()),
                        'geo2_name'] = "Tuxpan"
                     # Harmonizing naming
    
        nq_geodf.geo2_name = nq_geodf.geo2_name.str.replace("- Dto.", "Distrito").str.replace("Dr.", "Doctor")                                .str.replace("Gral.", "General")
            # Standardizing abbreviations
    elif country=="PE":
        ipums_geodf.loc[ipums_geodf.geo2_name==("Huzánuco"),
                        'geo2_name'] = "Huánuco" 
        nq_geodf.loc[nq_geodf.geo2_name==("Putumayo"),
                        'geo2_name'] = "Maynas"
    
    
    # Actual computing
    
    # In[291]:
    
    
    # The fuzzy join
    print("Finding matching geographies...")
    nq_geodf[['geo1_match_name','geo1_match_score','geo1_match_index']] = fuzzy_join(nq_geodf, ipums_geodf, 'geo1_name')[['name','score','index']]
    nq_geodf[['geo2_match_name','geo2_match_score','geo2_match_index']] = fuzzy_join(nq_geodf, ipums_geodf, 'geo2_name', 
                 subset=['geo1_match_name','geo1_name']
                )[['name','score','index']]
    
    # confirmation of results
    print("Are there no more duplicates?")
    print(
        len(nq_geodf[nq_geodf.duplicated('geo2_code', keep=False)].sort_values('geo2_code')\
        [["geo1_code","geo2_code",
          "geo1_name","geo1_match_name",
          "geo2_name","geo2_match_name",
          "count"]]
        )==0
    )      
        
    # determination of cutoff
    print("Showing problematic geographies...")
    print(
          nq_geodf[(nq_geodf.geo2_match_score<80)][['geo1_name',
                                              'geo1_code',
                                            'geo1_match_name',
                                            'geo2_name',
                                            'geo2_code',
                                            'geo2_match_name',
                                            'geo2_match_score'
                                           ]
                    ].sort_values('geo1_name'))
    cutoff = input(country + ": Decide at what level to cut off matches: ")
    
    has_ipums_geo = nq_geodf.geo2_match_score>int(cutoff )
    
    # attaching geography codes
    nq_geodf['IPUMS_geo1_code'] = np.nan
    nq_geodf['IPUMS_geo2_code'] = np.nan
    
    nq_geodf.loc[has_ipums_geo,'IPUMS_geo2_code'] = nq_geodf[has_ipums_geo]                            .geo2_match_index                            .astype(int)                            .apply(
                                    lambda i: ipums_geodf.loc[i,'geo2_code']
                                .astype(int)
    )
    nq_geodf.loc[has_ipums_geo,'IPUMS_geo1_code'] = nq_geodf[has_ipums_geo]                            .geo1_match_index                            .astype(int)                            .apply(
                                    lambda i: ipums_geodf.loc[i,'geo1_code']
                                .astype(int)
    )
                                
    # Merge centroids onto NQ geometries:
    nq_geodf_merged = nq_geodf.merge(geo2_centroids[['ADMIN_NAME','Y','X','IPUM'+year]], 
                   left_on='IPUMS_geo2_code',
                   right_on="IPUM"+year,
                   how='left'
                  ).drop('IPUM'+year, axis=1)
    #Merge NQ geometries onto NQ data:
    panel_geo = netquest.merge(nq_geodf_merged[['X','Y','geo2_code']],
                   left_on=geo2_nq,
                   right_on='geo2_code',
                   how='left'
                  )
    #Merge census geometries onto census data
    census_geo = census.merge(geo2_centroids[['ADMIN_NAME','X',"Y",'IPUM'+year]],
                              left_on = geo2_ipums,
                              right_on='IPUM'+year,
                              how='left'
                             ).drop('IPUM'+year,axis=1)
    
    
    # Writing out
    
    # In[]:
    print("Saving the geo codebook...")
    
    codebook_geo2 = nq_geodf[["geo1_name","geo1_code","geo2_name","geo2_code","geo1_match_name","IPUMS_geo1_code","geo2_match_name","IPUMS_geo2_code"]]
    codebook_geo1 = codebook_geo2.drop_duplicates(subset=["geo1_code","IPUMS_geo1_code"])[["geo1_name","geo1_code","geo1_match_name","IPUMS_geo1_code"]]
    
    codebook_geo1.to_csv(codebook1out)    
    codebook_geo2.to_csv(codebook2out)
    # In[292]:
    print("Writing out the result...")
    
    if panel_geo.shape[0]!=netquest.shape[0]:
        print("Problem with panel shape match")
    if census_geo.shape[0]!=census.shape[0]:
        print("Problem with census shape match")
    panel_geo.loc[:,[not("Unnamed" in k) for k in panel_geo.columns]].to_csv(panelout)
    census_geo.loc[:,[not("Unnamed" in k) for k in census_geo.columns]].to_csv(ipumsout)


# In[ ]:




