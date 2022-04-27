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
library(fable) # time series forecasting
library(urca) #this installs tests and helper functions for time series models
#}

###############################################.
## Data - Including Cleaning & Wrangling ----
###############################################.

# Temporal Data
# This is data required for capacity insight.



delayed_bed_discharge_timeseries <- delayed_discharge %>%
  select(datetime, number_of_delayed_bed_days) %>% 
  group_by(datetime) %>% 
  summarise(datetime, average_delayed_beds = mean(number_of_delayed_bed_days)) %>% 
  ggplot()+
  aes(x=datetime, y = average_delayed_beds)+
  geom_line()+
  geom_point()

delayed_bed_discharge_by_reason <- delayed_discharge %>% 
  select(reason_for_delay, number_of_delayed_bed_days) %>% 
  filter(reason_for_delay != "All Delay Reasons") %>% 
  summarise(reason_for_delay, ave_delayed_beds_days = mean(number_of_delayed_bed_days))


# Demographic Data
# This is data required for demographic insight.





#Geographic Data
#This is data required for georgraphical insight.





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