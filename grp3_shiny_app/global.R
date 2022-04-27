## Group 3 Dashboard - Global Script

# This code script will be used to :
# To run the necessary libraries.
# Load in raw_data e.g. csv's & to assign to object name;
# Clean & wrangle raw_data and re-assign to object name;
# To write clean data e.g. csv's, to project clean_data folders;
# To develop global ggplot and palette parameters.
# To develop functions that can be used in the server.


###############################################.
## Packages ----
###############################################.

#librarys <- function(){
library(here) # for reading in data from repo.
library(janitor) # for cleaning names when reading in raw-data.
library(lubridate) # for handling dates and times in R.
library(tidyverse) # for cleaning and wrangling data using dplyr.
library(ggplot2) # for developing plots.
library(shiny) # for developing app UI and Server.
library(readr) # use to run in different data files.
library(stringr) #use of stringr.
library(assertr) # used for assertive programming (e.g. Unit Testing)
library(e1071) # to facilitate measure of distribution skewness.
library(shinythemes) # adding additional themes to shiny app. 
library(plotly) # for adding interaction to plots.
library(DT) #R data objects (data frames) can be displayed as tables in app. 
library(bslib) # provides tools for customising Bootstrap themes directly from R.
library(thematic) # Transfers CSS themes into R plots
library(treemapify) #for creating treemap plots.
library(feasts) # Time series plots.
library(feasts) # Time series plots.
library(infer) # for bootstrapping.
library(tsibbledata) #datasets for working with time series data.
library(tsibble) # provides a tidy data structure for time series. 
library(slider) # allows you to add slider windows. 
library(sf) # geospatioal 
library(rgeos) #geospatial
library(rnaturalearth) #geospatial
library(leaflet) #geospatial e.g. markers etc.
library(rnaturalearthdata) #geospatial
library(zoo) #Time series conversion.
library(tsibble) # Time series conversion. 

#}

###############################################.
## Data - Including Cleaning & Wrangling ----
###############################################.

# Admissions Data
# This is data required for admissions insight.







# Occupancy Data
# This is data required for occupancy insight.

bed_data <- read_csv(here("raw_data/nhs_data_joined4.csv"))




# Discharge Data
#This is data required for discharge insight.



source(here("helper_scripts/ae_waiting_helper.R"))

# Non-Categorised Data
# This is data that does not fall into the above categories and may be
# common across datasets.



###############################################.
## Functions ----
###############################################.

#These are functions that have been developed to avoid repeated code within 
#the UI, Server or other R.Scripts.







###############################################.
## Palettes and plot parameters ----
###############################################.
#These are plot parameters that have been developed to avoid repeated code in 
# plot parameters.






###############################################.
## Objects, names, lists ----
###############################################.











## END OF SCRIPT