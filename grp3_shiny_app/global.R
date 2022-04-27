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

bed_data <- read_csv(here("raw_data/nhs_data_joined4.csv"))  

act_ae_waiting <-read_csv(here("raw_data/monthly_ae_activity_waitingtimes.csv")) %>% 
  clean_names()

location_data <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>% 
  select(location, location_name) %>% 
  rename(treatment_location = location)


# Temporal Data
# This is data required for capacity insight.



# Create a plot to see how the number of delayed beds changes over time
delayed_discharge_plot <- delayed_discharge %>%
  select(datetime, number_of_delayed_bed_days) %>% 
  group_by(datetime) %>% 
  summarise(datetime, average_delayed_beds = mean(number_of_delayed_bed_days)) %>% 
  ggplot()+
  aes(x=datetime, y = average_delayed_beds)+
  geom_line()+
  geom_point()

library(treemapify)





# Demographic Data
# This is data required for demographic insight.





#Geographic Data
#This is data required for georgraphical insight.





# Non-Categorised Data
# This is data that does not fall into the above categories and may be
# common across datasets.



# Prediction Models
# This is data that predicts the trends of admission numbers and delayed discharge
# of beds for the next 3 years 



##
## Delayed Discharge Prediction Model
##
# read the dataset in

delayed_discharge_df <- read_csv(here("raw_data/delayed-discharge-beddays-health-board.csv")) %>%
  clean_names()

# create a datetime column 

delayed_discharge <- delayed_discharge_df %>% 
  mutate(datetime = ym(month_of_delay), .after = month_of_delay) %>% 
  filter(datetime >= "2018-04-01")






# to create a forecasting model using the fable package, we need to change our dataframe into a tsibble 
# where the key is a combination of the chosen columns indexed by the datetime column.

delayed_dis_ts <- delayed_discharge %>%
  filter(!age_group == "18plus")%>%
  filter(!reason_for_delay == "All Delay Reasons") %>%
  filter(hbt == "S92000003")%>%
  as_tsibble(key = c(hbt, age_group, reason_for_delay, number_of_delayed_bed_days), index = datetime)


# for some reason one of the forecasting models seems to be working better with the format yearmonth, 
# so we'll change our datetime column
# then we select the variables we need and sumamrise the number of delayed beds

delayed_dis_ts_sum <- delayed_dis_ts%>%
  mutate(datetime = yearmonth(datetime))%>%
  as_tsibble(index = datetime) %>%
  select(datetime, number_of_delayed_bed_days)%>%
  summarise(count = sum(number_of_delayed_bed_days))

# use autoplot() to check the series
autoplot(delayed_dis_ts_sum)

# need to install the urca package (this installs tests and helper functions for time series models

library(urca)
library(fable)

# create a fit dataset which has the results from our three different models

fit_delayed <- delayed_dis_ts_sum %>%
  model(
    snaive = SNAIVE(count),
    mean_model = MEAN(count),
    arima = ARIMA(count)
  )

# with the models specified, we can now produce the forecasts.
# choose the number of future observations to forecast,
# this is called the forecast horizon
# once we’ve calculated our forecast, we can visualise it using
# the autoplot() function that will produce a plot of all forecasts.

delayed_dischrge_prediction_model <- fit_delayed %>%
  fabletools::forecast(h = "3 years") %>%
  autoplot(delayed_dis_ts_sum)+
  guides(colour = guide_legend(title = "3-Year Forecast"))+
  labs(x = "", y = "number of delayed beds")
# by default, argument level = c(80,95) is passed to autoplot(), and so 80% and 95% prediction intervals
# are shown.




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