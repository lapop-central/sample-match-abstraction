#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import re
import os


# ## The panelists by country

# Reading in the panel information Netquest gave us.

# ### may need to be set

# In[2]:

# date of Netquest panel export
paneldate = "200612"


# ### needs oversight

# In[3]:


outdir = "../out/panel_country/"


# In[4]:


paneldir = ("C:/Users/schadem/Box/LAPOP Shared/2_Projects/"+
            "2020 IDB Trust/raw/netquest/"+paneldate+"/")
panelfile = [s for s in os.listdir(paneldir) if s.endswith(".csv")][0]
manualfile = "Manual2.xlsx"
print("loading panel data: ", panelfile)


# ### this can just do its thing

# In[5]:


panels = pd.read_csv(paneldir+panelfile,
                     sep=';', 
#                      skiprows=2891450,
#                      nrows=1000000,
                     na_values=[' ','.'], 
                     encoding='latin1',
                     #error_bad_lines=False
                    )


# In[ ]:


[k for k in panels.columns if "municipio" in k]
#[k for k in panels.columns if "COUNTRY" in k]


# Creating a dictionary of individual country dataframes, and cleaning them up--pick out non-empty variables for each country.

# In[ ]:


panels_dict = {}
for p in panels.COUNTRY.unique():
    panels_dict[p] = panels[panels.COUNTRY==p].dropna(how='all', axis=1)


# In[ ]:


panels_dict.keys()


# Where does the data go?

# In[ ]:


for pais, data in panels_dict.items():
    # if pais=="BR":
    print("working on "+pais)
    print(data.columns)
    if not os.path.isdir(outdir):
        os.mkdir(outdir)
    data.columns = data.columns.str.strip()
    data.to_csv(outdir+pais+"_netquest-panel.csv", encoding='utf8',index=False)


# Next, bring the variables and labels in order.

# In[ ]:


manual_dict = pd.read_excel(paneldir+manualfile,skiprows=1,sheet_name=None,)
variables = manual_dict['Variables']
variables.Variable = variables.Variable.str.strip()


# In[ ]:


levels = pd.concat(
    [manual_dict[k] for k in manual_dict.keys() if "Código" in k]
).fillna(method='ffill')
levels.columns = ["Variable","Valor","Etiqueta"]
levels.Variable = levels.Variable.str.strip()
#levels = pd.read_excel(paneldir+"manual_levels.xlsx")
# this expects a the first and second sheet of netquest background export manual
# with first line (title) removed


# In[ ]:


print(("Variable" in variables.columns) & ("Variable" in levels.columns))


# In[ ]:


variables_dict = {}
levels_dict = {}
countryexp = re.compile("^([A-Z]{2,2})_")

for pais in panels_dict:
    # if pais=="BR":
    all_countries = variables.Variable.apply(countryexp.findall).apply(lambda l: l[0].lower() if len(l)>0 else "None").unique()
    other_countries = [p.lower() for p in all_countries if not p==pais]
    var_df = variables[
        variables.Variable.isin(panels_dict[pais].columns)
        #remove variables that don't show up in pais
#         [k for k in variables if k in panels_dict[pais].columns]
#         (variables.Variable.str.lower().str.startswith(pais.lower())) #country-specific var
#                    | (variables.Variable.apply(lambda s: sum([s.lower().startswith(k+"_") for k in all_countries]))==0) #not specific for another country
#                    | variables.Variable.isin(["panelistAge","DESKTOP_RESPONDENT","DEVICE","DESK","TARGET",
#                                               "SOCIODEMOGRAPHICS_DATE_V0","SOCIODEMOGRAPHICS_QUEST_V0",
#                                               "int_municipio_delegacion"
#                                              ])
#                    | variables.Variable.str.contains("PNuevo")
                  ]

    lev_df = levels[levels.Variable.isin(var_df.Variable)]

    variables_dict[pais] = var_df
    levels_dict[pais] = lev_df

    var_df.to_excel(outdir+pais+'_variables.xlsx',index=False)
    lev_df.to_excel(outdir+pais+'_levels.xlsx',index=False)


# ## needs supervision
# Check which variables are dropped at this stage

# In[ ]:


list(filter(lambda x: sum([x in v[1].Variable.unique() for v in variables_dict.items()])==0, variables.Variable))


# In[ ]:




