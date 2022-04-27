# This script is to help plot forecasting models to see the number of delayed beds across Scotland

# read the dataset in

delayed_discharge_df <- read_csv(here("raw_data/delayed-discharge-beddays-health-board.csv")) %>%
  clean_names()

# create a datetime column 

delayed_discharge <- delayed_discharge_df %>% 
  mutate(datetime = ym(month_of_delay), .after = month_of_delay) %>% 
  filter(datetime >= "2018-04-01")

# create a plot to see how the number of delayed beds changes over time

delayed_discharge_plot <- delayed_discharge %>%
  select(datetime, number_of_delayed_bed_days) %>% 
  group_by(datetime) %>% 
  summarise(datetime, average_delayed_beds = mean(number_of_delayed_bed_days)) %>% 
  ggplot()+
  aes(x=datetime, y = average_delayed_beds)+
  geom_line()+
  geom_point()

ggplotly(delayed_discharge_plot)


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
# this is called the forecast horizon h = 

forecast_3year_delayed <- fit_delayed %>%
  fabletools::forecast(h = "3 years")

# once we’ve calculated our forecast, we can visualise it using
# the autoplot() function that will produce a plot of all forecasts.

forecast_3year_delayed %>%
  autoplot(delayed_dis_ts_sum)+
  guides(colour = guide_legend(title = "3-Year Forecast"))+
  labs(x = "", y = "number of delayed beds")

# by default, argument level = c(80,95) is passed to autoplot(), and so 80% and 95% prediction intervals
# are shown.
