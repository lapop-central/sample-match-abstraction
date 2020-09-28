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


outdir = ("C:/Users/schadem/Box/LAPOP Shared/2_Projects/"+
            "2019 APES/Matching process/out/panel_country/")


# In[4]:
## This defines the files we're using from Netquest. 
## They occasionally change their format/naming convention

paneldir = ("C:/Users/schadem/Box/LAPOP Shared/2_Projects/"+
            "2019 APES/Matching process/raw/netquest/"+paneldate+"/")
panelfile = [s for s in os.listdir(paneldir) if s.endswith(".csv")][0]
manualfile = "Manual2.xlsx"
print("loading panel data: ", panelfile)


# ### this can just do its thing

# In[5]:
## Here, we read in the most recent panelfile.
## If there are issues, try changing the encoding.

panels = pd.read_csv(paneldir+panelfile,
                     sep=';', 
#                      skiprows=2891450,
#                      nrows=1000000,
                     na_values=[' ','.'], 
                     encoding='latin1',
                     #error_bad_lines=False
                    )


# In[ ]:
## Check if certain columns are there, specifically those used later on

print([k for k in panels.columns if "municipio" in k])
print([k for k in panels.columns if "COUNTRY" in k])



# In[ ]:
# Creating a dictionary of individual country dataframes, and cleaning them up--pick out non-empty variables for each country.

panels_dict = {}
for p in panels.COUNTRY.unique():
    panels_dict[p] = panels[panels.COUNTRY==p].dropna(how='all', axis=1)


# In[ ]:
## Check that all the countries we want are there

panels_dict.keys()


# In[ ]:
## Writing out the individual countries' panel data files
for pais, data in panels_dict.items():
    # You can choose to just do this for one country, e.g. for testing
    # if pais=="BR":
    print("working on "+pais)
    print(data.columns)
    if not os.path.isdir(outdir):
        os.mkdir(outdir)
    data.columns = data.columns.str.strip() # get rid of whitespace
    data.to_csv(outdir+pais+"_netquest-panel.csv", encoding='utf8',index=False) #write out each country's panel file


# Next, bring the variables and labels in order.

# In[ ]:

# read in the auxiliary data, skipping the header
manual_dict = pd.read_excel(paneldir+manualfile,skiprows=1,sheet_name=None,)
# get the variable names
variables = manual_dict['Variables']
variables.Variable = variables.Variable.str.strip() # remove whitespace


# In[ ]:

# get well-formed table of variables, values, and labels (filling back
# the variable labels that are just in one cell each)
levels = pd.concat(
    [manual_dict[k] for k in manual_dict.keys() if "Código" in k]
).fillna(method='ffill')
levels.columns = ["Variable","Valor","Etiqueta"]
levels.Variable = levels.Variable.str.strip() # remove whitespace


# In[ ]:

# Check that all variables have value labels
print(("Variable" in variables.columns) & ("Variable" in levels.columns))


# In[ ]:

# Break these up by country, based on variables existing in each country

for pais in panels_dict:
    # for testing, you could just run this for one country
    # if pais=="BR":
    
    # we already filtered the variables that are in each country,
    # so just use the columns of the country's data frame
    var_df = variables[
        variables.Variable.isin(panels_dict[pais].columns)
                  ]
    # pick out all the levels for the variables
    lev_df = levels[levels.Variable.isin(var_df.Variable)]
    
    # write them all out    
    var_df.to_excel(outdir+pais+'_variables.xlsx',index=False)
    lev_df.to_excel(outdir+pais+'_levels.xlsx',index=False)





