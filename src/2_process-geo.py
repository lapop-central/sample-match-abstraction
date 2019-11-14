# -*- coding: utf-8 -*-

"""
Loading packages
"""
import pandas as pd
from fuzzywuzzy import fuzz, process
#import re
import numpy as np
#import os
#import time

"""
Defining specific parameters
"""
country = "AR"
nq_date = "190628"
geo1_nq = "AR_provincia"
geo2_nq = "AR_departamento"
geo1_ipums = 'GEO1_AR2010'
geo2_ipums = 'GEO2_AR2010'
year = '2010'
ipumsfile = "../../raw/ipums/"+country+"/ipumsi_00015.csv"
netquestfile = "../out/panel_country/"+country+"_netquest-panel.csv"
dictfile = "../out/panel_country/"+country+"_levels.xlsx"
geo2file = '../out/ipums_country/ipums_codebook_'+geo2_ipums+'.csv'
geo1file = '../out/ipums_country/ipums_codebook_'+geo1_ipums+'.csv'
centroidfile = '../out/geo/'+country+'_geo2_centroids.csv'
panelout = '../out/panel_country/'+country+'_netquest-panel_geo.csv'
ipumsout = '../out/ipums_country/'+country+'_ipums-census_geo.csv'

"""
Loading things
"""
census = pd.read_csv(ipumsfile)
netquest = pd.read_csv(netquestfile)
nq_dict = pd.read_excel(dictfile)
ipums_geo2 = pd.read_csv(geo2file,encoding='Latin1', names=['code','name'], skiprows=1)
ipums_geo1 = pd.read_csv(geo1file,encoding='Latin1', names=['code','name'], skiprows=1)
geo2_centroids = pd.read_csv(centroidfile, encoding='latin1')
"""
Defining functions
"""
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
    matches.loc[(noRatioMatch&onePartiMatch)] = parti_matches.loc[(noRatioMatch&onePartiMatch)]\
        .apply(lambda l: l[0])
    matches.loc[(noRatioMatch&noPartiMatch)] = parti_matches.loc[(noRatioMatch&noPartiMatch)]\
        .apply(lambda l: l[0])
    
    df = pd.DataFrame()
    df['name'] = matches.apply(lambda l: l[0])
    df['score'] = matches.apply(lambda l: l[1])
    df['index'] = matches.apply(lambda l: l[2])
    df['parti_matches'] = parti_matches
    df['ratio_matches'] = ratio_matches
    
    return df


"""
Setting up helper structures
"""
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
ipums_geodf = ipums_geodf.geo2_name.str.split(',').apply(pd.Series) \
    .merge(ipums_geodf, right_index = True, left_index = True) \
    .drop(["geo2_name"], axis = 1) \
    .melt(id_vars = [k for k in ipums_geodf.columns if not (type(k)==int)|(k=='geo2_name')], value_name = "geo2_name") \
    .drop("variable", axis = 1) \
    .dropna(subset=['geo2_name'])
ipums_geodf.geo2_name = ipums_geodf.geo2_name.str.strip()

ipums_geodf = ipums_geodf.geo1_name.str.split(',').apply(pd.Series) \
    .merge(ipums_geodf, right_index = True, left_index = True) \
    .drop(["geo1_name"], axis = 1) \
    .melt(id_vars = [k for k in ipums_geodf.columns if not (type(k)==int)|(k=='geo1_name')], value_name = "geo1_name") \
    .drop("variable", axis = 1) \
    .dropna(subset=['geo1_name'])
ipums_geodf.geo1_name = ipums_geodf.geo1_name.str.strip()

"""
Country-specific pre-processing
"""
if country=="AR":
    # accounting for the CABA mess
    ipums_geodf.loc[ipums_geodf.geo1_name=="City of Buenos Aires",
             'geo1_name'] = 'CABA'
    ipums_geodf.loc[(ipums_geodf.geo1_name=="CABA"),'geo2_name'] = 'CABA'
    caba_codes = ipums_geodf[ipums_geodf.geo1_name=="CABA"].geo2_code
    # dropping CABA-related duplicates
    ipums_geodf.drop_duplicates(subset=["geo1_name","geo2_name"], inplace=True)
    # make sure there is only one CABA-code left
    #print(len(ipums_geodf[ipums_geodf.geo1_name=="CABA"].geo2_code.values[0])==1)
    census.loc[census[geo2_ipums].isin(caba_codes),geo2_ipums] = \
    len(census.loc[census[geo2_ipums].isin(caba_codes),geo2_ipums])*[ipums_geodf[ipums_geodf.geo1_name=="CABA"].geo2_code[0]]
    # give CABA locations without geo2 a specific code: 999
    netquest.loc[netquest[geo2_nq].isna()&(netquest[geo1_nq]==1),geo2_nq] = 999
    nq_geodf = netquest.merge(nq_geo2, on=geo2_nq, how='left')\
                       .merge(nq_geo1, on=geo1_nq, how='left')[[geo1_nq,geo1_nq+'_name',geo2_nq,geo2_nq+'_name']]
    nq_geodf.columns = ['geo1_code','geo1_name','geo2_code','geo2_name']
    nq_geodf.drop_duplicates(inplace=True)
    
    # Fixing CABA not having Dept.
    # Where province is CABA and no departamento exists, call these "CABA"
    nq_geodf.loc[nq_geodf.geo1_name=="Ciudad Autónoma de Buenos Aires",
                 'geo1_name'] = 'CABA'
    nq_geodf = nq_geodf[(nq_geodf['geo1_code'].notna()) & (nq_geodf['geo2_code'].notna())] 

"""
Country-independent pre-processing
"""
#Finding the duplicates in nq_geodf.geo2_code, and keeping the combinations that occur most often (which are quite clearly the good ones).
nq_geodf['count'] = nq_geodf.apply(
    lambda r: sum((netquest[geo1_nq]==r['geo1_code'])&
                  (netquest[geo2_nq]==r['geo2_code'])),
                                   axis=1)
nq_geodf = nq_geodf.sort_values(['geo2_code','count']) \
    [~(nq_geodf.sort_values(['geo2_code','count']).duplicated('geo2_code',keep='last'))]

"""
More country-specific processing
"""
if country=="AR":
    nq_geodf.loc[nq_geodf.geo2_code==999, 'geo2_name'] = "CABA"

    ipums_geodf.loc[ipums_geodf.geo1_name.str.contains("Buenos Aires province"),
                 'geo1_name'] = "Buenos Aires"
    
    ipums_geodf.loc[ipums_geodf.geo2_name.str.contains("Puan"),
                    'geo2_name'] = "Puán"
    ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("General San Martín"))\
                    &(ipums_geodf.geo1_name=="Buenos Aires"),
                    'geo2_name'] = "Ciudad Libertador San Martín"
    ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("La Capital"))\
                    &(ipums_geodf.geo1_name=="San Luis"),
                    'geo2_name'] = "Juan Martín de Pueyrredón"
    ipums_geodf.loc[(ipums_geodf.geo2_name=="Maipú")\
                    &(ipums_geodf.geo2_code==6050),
                    'geo2_name'] = "Marcos Paz"
    
    
    
    ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Chascomus")),
                    'geo2_name'] = "Chascomús"
    ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Jose C. Paz")),
                    'geo2_name'] = "José C. Paz"
    nq_geodf.loc[(nq_geodf.geo2_name.str.contains("Paso de Indios"))\
                    &(nq_geodf.geo1_name=="Chubut"),
                    'geo2_name'] = "Paso de los Indios"
    nq_geodf.loc[(nq_geodf.geo2_name.str.contains("Coronel de Marina Leonardo Rosales"))\
                    &(nq_geodf.geo1_name=="Buenos Aires"),
                    'geo2_name'] = "Coronel de Marine L. Rosales"
    ipums_geodf.loc[(ipums_geodf.geo2_name.str.contains("Veinticinco de Mayo"))\
                    &(ipums_geodf.geo1_name=="Buenos Aires"),
                    'geo2_name'] = "25 de Mayo"
    nq_geodf.loc[(nq_geodf.geo2_name.str.contains("Pueyrredón"))\
                    &(nq_geodf.geo1_name=="Buenos Aires"),
                    'geo2_name'] = "General Pueyrredón"

"""
Actual computing
"""
# The fuzzy join
nq_geodf[['geo1_match_name','geo1_match_score','geo1_match_index']] \
= fuzzy_join(nq_geodf, ipums_geodf, 'geo1_name')[['name','score','index']]
nq_geodf[['geo2_match_name','geo2_match_score','geo2_match_index']] \
= fuzzy_join(nq_geodf, ipums_geodf, 'geo2_name', 
             subset=['geo1_match_name','geo1_name']
            )[['name','score','index']]

# confirmation of results
print(
    len(nq_geodf[nq_geodf.duplicated('geo2_code', keep=False)].sort_values('geo2_code')\
    [["geo1_code","geo2_code",
      "geo1_name","geo1_match_name",
      "geo2_name","geo2_match_name",
      "count"]]
    )==0
)      
    
# determination of cutoff
print(
      nq_geodf[(nq_geodf.geo2_match_score<80)][['geo1_name',
                                          'geo1_code',
#                                         'geo1_match_name',
                                        'geo2_name',
                                        'geo2_code',
                                        'geo2_match_name',
                                        'geo2_match_score'
                                       ]
                ].sort_values('geo1_name'))
cutoff = input("AR: Decide at what level to cut off matches: ")
has_ipums_geo = nq_geodf.geo2_match_score>cutoff 

# attaching geography codes
nq_geodf['IPUMS_geo2_code'] = np.nan

nq_geodf.loc[has_ipums_geo,'IPUMS_geo2_code'] = nq_geodf[has_ipums_geo]\
                            .geo2_match_index\
                            .astype(int)\
                            .apply(
                                lambda i: ipums_geodf.loc[i,'geo2_code']
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
"""
Writing out
"""
if panel_geo.shape[0]!=netquest.shape[0]:
    print("Problem with panel shape match")
if census_geo.shape[0]!=census.shape[0]:
    print("Problem with census shape match")
panel_geo.to_csv(panelout)
census_geo.to_csv(ipumsout)

