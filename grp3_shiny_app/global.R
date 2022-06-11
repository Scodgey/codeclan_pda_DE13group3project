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
library(shinydashboard) # for developing app UI and Server.
library(fontawesome) # Icon list found here: https://www.angularjswiki.com/fontawesome/
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
library(treemapify) # Creating tree maps
#}

###############################################.
## Data - Including Cleaning & Wrangling ----
###############################################.

### Load in data for diff tabs in shiny dashbaord

# The bed Occupancy Data
bed_data <- read_csv(here("raw_data/nhs_data_joined4.csv"))  


# Data for a&e waiting times - needed for summary tab
act_ae_waiting <-read_csv(here("raw_data/monthly_ae_activity_waitingtimes.csv")) %>% 
  clean_names()

# Location data is joined on to other data to get hopsitals/health_boards
location_data <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>% 
  select(location, location_name) %>% 
  rename(treatment_location = location)

# Admission data
admissions <- read_csv(here("raw_data/nhs_data_joined2.csv")) %>%
  select(-contains("qf"))
# Admission data
nhs_data_joined2 <- read_csv(here("raw_data/nhs_data_joined2.csv")) %>%
  select(-contains("qf"))

# Delayed discharge data
delayed_discharge <- read_csv(here("raw_data/delayed-discharge-beddays-health-board.csv")) %>%
  clean_names()%>% 
  # create a datetime column 
  mutate(datetime = ym(month_of_delay), .after = month_of_delay) %>% 
  filter(datetime >= "2018-04-01")


### Temporal Plots ### 
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


### Bed - Occupancy Data/Plots ####
# Loading in location and removing id and qualifier columns
location_look_up <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>%
  clean_names() %>%
  select(-"id",
         -contains("qf"))

# joining location data with nhs data 3 and manipulating the data
joined_bed_data_3 <- read_csv(here("raw_data/nhs_data_joined3.csv")) %>%
  rename("available_staffed_beds" = "all_staffed_beds") %>%
  mutate(
    average_available_staffed_beds = round(average_available_staffed_beds),
    average_occupied_beds = round(average_occupied_beds),
    percentage_occupancy = round(percentage_occupancy),
  ) %>%
  mutate(quarter = as.Date(as.yearqtr(quarter, format = "%YQ%q"))) %>%
  filter(!location_qf %in% "d") %>%
  select(-contains("qf")) %>%
  left_join(location_look_up, by = "location") %>%
  filter(!is.na(location))



### Geospatial Data ###
#This is data required for georgraphical insight.

scot_health_board_shapes <-
  st_read(dsn = here("geospatial_data/scottish_local_authority_data_2021"),
          layer = "SG_NHS_HealthBoards_2019") %>%
  clean_names() %>%
  st_simplify(dTolerance = 2000) %>%
  rename(hb = hb_code) %>%
  st_transform('+proj=longlat +datum=WGS84')



### Prediction Models ###
# This is data that predicts the trends of admission numbers and delayed discharge
# of beds for the next 3 years 



# Delayed Discharge Prediction Model

# to create a forecasting model using the fable package, we need to change our 
# dataframe into a tsibble where the key is a combination of the chosen columns 
# indexed by the datetime column.

delayed_dis_ts <- delayed_discharge %>%
  filter(!age_group == "18plus")%>%
  filter(!reason_for_delay == "All Delay Reasons") %>%
  filter(hbt == "S92000003")%>%
  as_tsibble(key = c(hbt, age_group, reason_for_delay, number_of_delayed_bed_days), index = datetime)

# for some reason one of the forecasting models seems to be working better with 
# the format yearmonth, so we'll change our datetime column
# then we select the variables we need and sumamrise the number of delayed beds
delayed_dis_ts_sum <- delayed_dis_ts%>%
  mutate(datetime = yearmonth(datetime))%>%
  as_tsibble(index = datetime) %>%
  select(datetime, number_of_delayed_bed_days)%>%
  summarise(count = sum(number_of_delayed_bed_days))

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


# admissions_age_groups <- admissions %>% 
#   filter(age_group != "All ages",
#          !is.na(age_group)) %>% 
#   select(week_ending, age_group, number_admissions, percent_variation) %>% 
#   group_by(week_ending, age_group) %>% 
#   summarise(age_group, ave = mean(number_admissions)) %>% 
#   arrange(desc(age_group)) %>% 
#   ggplot()+
#   aes(x = age_group, y = ave)+
#   geom_boxplot()
# 
# admissions_simd_quin <- admissions %>% 
#   filter(!is.na(simd_quintile)) %>% 
#   select(week_ending, simd_quintile, number_admissions, percent_variation) %>% 
#   group_by(week_ending, simd_quintile) %>% 
#   summarise(simd_quintile, ave = mean(number_admissions)) %>% 
#   arrange(desc(simd_quintile)) %>% 
#   ggplot()+
#   aes(x = simd_quintile, y = ave)+
#   geom_col()


# nhs_data_joined_2_ts <- nhs_data_joined2 %>%
#   select(week_ending, hb, age_group, admission_type, number_admissions, average20182019)%>%
#   filter(!age_group == "All ages")%>%
#   filter(!admission_type == "All")%>%
#   filter(hb == "S92000003")%>%
#   as_tsibble(key = c(hb, age_group, admission_type), index = week_ending)
# 
# nhs_data_joined_forecast <- nhs_data_joined_2_ts %>%
#   select(week_ending, number_admissions)%>%
#   summarise(count = sum(number_admissions))
# 
# # use autoplot() to check the series
# autoplot(nhs_data_joined_forecast)
# 
# # create a fit dataset which has the results from our three different models
# 
# fit <- nhs_data_joined_forecast %>%
#   model(
#     snaive = SNAIVE(count ~ lag("year")),
#     mean_model = MEAN(count),
#     arima = ARIMA(count)
#   )
# 
# # with the models specified, we can now produce the forecasts.
# # choose the number of future observations to forecast,
# # this is called the forecast horizon h = 
# 
# admission_prediction_model_to_plot <- fit %>%
#   fabletools::forecast(h = "2 years")%>%
#   autoplot(nhs_data_joined_forecast) +
#   ggtitle("Forecasts for Hospital Admissions") +
#   guides(colour = guide_legend(title = "Forecast"))+
#   labs(x = "", y = "number of hospital admissions")


# once we’ve calculated our forecast, we can visualise it using
# the autoplot() function that will produce a plot of all forecasts.


###############################################.
## Objects, names, lists ----
###############################################.


#source(here("helper_scripts/num_admissions_helper.R"))


nhs_data_joined_2_ts_1 <- nhs_data_joined2 %>%
  select(week_ending, hb, age_group, admission_type, number_admissions, average20182019)%>%
  filter(!age_group == "All ages")%>%
  filter(!admission_type == "All")%>%
  filter(hb == "S92000003")%>%
  as_tsibble(key = c(hb, age_group, admission_type), index = week_ending)

nhs_data_joined_forecast_aver20182019_1 <- nhs_data_joined_2_ts_1 %>%
  select(week_ending, average20182019)%>%
  summarise(count = sum(average20182019))

# use autoplot() to check the series
autoplot(nhs_data_joined_forecast_aver20182019_1)+
  ylim(c(8000, 16500))

# create a fit dataset which has the results from our three different models

fit_aver_1 <- nhs_data_joined_forecast_aver20182019_1 %>%
  model(
    snaive = SNAIVE(count ~ lag("year")),
    mean_model = MEAN(count),
    arima = ARIMA(count)
  )

# with the models specified, we can now produce the forecasts.
# choose the number of future observations to forecast,
# this is called the forecast horizon h = 

admission_prediction_model_to_plot_1 <- fit_aver_1 %>%
  fabletools::forecast(h = "2 years") %>%
  autoplot(nhs_data_joined_forecast_aver20182019_1) +
  ylim(c(8000, 16500))+
  ggtitle("Forecasts for Hospital Admissions") +
  guides(colour = guide_legend(title = "Forecast"))+
  labs(x = "", y = "average No of admissions in 2018/2019")


# This script is to help plot forecasting models to see the number of admissions across Scotland for the
# next 2 years based on the data collected from Jan 2020 to Jan 2022

nhs_data_joined_2_ts_2 <- nhs_data_joined2 %>%
  select(week_ending, hb, age_group, admission_type, number_admissions, average20182019)%>%
  filter(!age_group == "All ages")%>%
  filter(!admission_type == "All")%>%
  filter(hb == "S92000003")%>%
  as_tsibble(key = c(hb, age_group, admission_type), index = week_ending)

nhs_data_joined_forecast_2 <- nhs_data_joined_2_ts_2 %>%
  select(week_ending, number_admissions)%>%
  summarise(count = sum(number_admissions))

# use autoplot() to check the series
autoplot(nhs_data_joined_forecast_2)

# create a fit dataset which has the results from our three different models

fit_2 <- nhs_data_joined_forecast_2 %>%
  model(
    snaive = SNAIVE(count ~ lag("year")),
    mean_model = MEAN(count),
    arima = ARIMA(count)
  )

# with the models specified, we can now produce the forecasts.
# choose the number of future observations to forecast,
# this is called the forecast horizon h = 

admission_prediction_model_to_plot_2 <- fit_2 %>%
  fabletools::forecast(h = "2 years") %>%
  autoplot(nhs_data_joined_forecast_2) +
  ggtitle("Forecasts for Hospital Admissions") +
  guides(colour = guide_legend(title = "Forecast"))+
  labs(x = "", y = "number of hospital admissions")


## END OF SCRIPT