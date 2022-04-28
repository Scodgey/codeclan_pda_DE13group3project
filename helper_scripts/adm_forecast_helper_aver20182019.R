# This script is to help plot forecasting models to see the number of admissions across Scotland for the
# next 2 years based on the data collected from Jan 2020 to Jan 2022

nhs_data_joined_2_ts <- nhs_data_joined2 %>%
  select(week_ending, hb, age_group, admission_type, number_admissions, average20182019)%>%
  filter(!age_group == "All ages")%>%
  filter(!admission_type == "All")%>%
  filter(hb == "S92000003")%>%
  as_tsibble(key = c(hb, age_group, admission_type), index = week_ending)

nhs_data_joined_forecast_aver20182019 <- nhs_data_joined_2_ts %>%
  select(week_ending, average20182019)%>%
  summarise(count = sum(average20182019))

# use autoplot() to check the series
autoplot(nhs_data_joined_forecast_aver20182019)+
  ylim(c(8000, 16500))

# create a fit dataset which has the results from our three different models

fit_aver <- nhs_data_joined_forecast_aver20182019 %>%
  model(
    snaive = SNAIVE(count ~ lag("year")),
    mean_model = MEAN(count),
    arima = ARIMA(count)
  )

# with the models specified, we can now produce the forecasts.
# choose the number of future observations to forecast,
# this is called the forecast horizon h = 

forecast_2years_aver <- fit_aver %>%
  fabletools::forecast(h = "2 years")

# once we’ve calculated our forecast, we can visualise it using
# the autoplot() function that will produce a plot of all forecasts.

forecast_2years_aver %>%
  autoplot(nhs_data_joined_forecast_aver20182019) +
  ylim(c(8000, 16500))+
  ggtitle("Forecasts for Hospital Admissions") +
  guides(colour = guide_legend(title = "Forecast"))+
  labs(x = "", y = "average No of admissions in 2018/2019")

