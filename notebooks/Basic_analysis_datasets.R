#most libraries derived from global.R

library(readxl)
library(skimr)

#Basic analysis of datasets
nhs_joined_1 <- read_csv(here("raw_data/nhs_data_joined1.csv"))
nhs_joined_2 <- read_csv(here("raw_data/nhs_data_joined2.csv"))
nhs_joined_3 <- read_csv(here("raw_data/nhs_data_joined3.csv"))

#checking consistency of rowbound csvs (do the columns match?)

compare_df_cols_same(nhs_joined_1, nhs_joined_2, nhs_joined_3)

#answer: Yes

#checking columns to spit into Workflow_Project

activity_by_board_age_sex <- read_csv(here("raw_data/activity_by_board_age_sex.csv"))
activity_by_board_and_specialty <- read_csv(here("raw_data/activity_by_board_and_specialty.csv"))
activity_by_board_deprivation <- read_csv(here("raw_data/activity_by_board_deprivation.csv"))
beds_by_nhs_board_of_treatment_and_specialty <- (here("raw_data/beds_by_nhs_board_of_treatment_and_specialty.csv"))
delayed_discharge_beddays_health_board <- (here("raw_data/delayed-discharge-beddays-health-board.csv"))

glimpse()
head()
tail()
summary(activity_by_board_age_sex)
#I suspect all of the "raw" data coming from PHS is already tidy.



