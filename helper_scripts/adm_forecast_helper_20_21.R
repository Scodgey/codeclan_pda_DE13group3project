# This script is to help plot forecasting models to see the number of admissions across Scotland for the
# next 2 years based on the data collected from Jan 2020 to Jan 2022

nhs_data_joined_2_ts <- nhs_data_joined2 %>%
  select(week_ending, hb, age_group, admission_type, number_admissions, average20182019)%>%
  filter(!age_group == "All ages")%>%
  filter(!admission_type == "All")%>%
  filter(hb == "S92000003")%>%
  as_tsibble(key = c(hb, age_group, admission_type), index = week_ending)

nhs_data_joined_forecast <- nhs_data_joined_2_ts %>%
  select(week_ending, number_admissions)%>%
  summarise(count = sum(number_admissions))

# use autoplot() to check the series
autoplot(nhs_data_joined_forecast)

# create a fit dataset which has the results from our three different models

fit <- nhs_data_joined_forecast %>%
  model(
    snaive = SNAIVE(count ~ lag("year")),
    mean_model = MEAN(count),
    arima = ARIMA(count)
  )

# with the models specified, we can now produce the forecasts.
# choose the number of future observations to forecast,
# this is called the forecast horizon h = 

forecast_2years <- fit %>%
  fabletools::forecast(h = "2 years")

# once we’ve calculated our forecast, we can visualise it using
# the autoplot() function that will produce a plot of all forecasts.

forecast_2years %>%
  autoplot(nhs_data_joined_forecast) +
  ggtitle("Forecasts for Hospital Admissions") +
  guides(colour = guide_legend(title = "Forecast"))+
  labs(x = "", y = "number of hospital admissions")

