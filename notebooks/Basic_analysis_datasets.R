#most libraries derived from global.R

library(readxl)

#Basic analysis of datasets
nhs_joined_1 <- read_csv(here("raw_data/nhs_data_joined1.csv"))
nhs_joined_2 <- read_csv(here("raw_data/nhs_data_joined2.csv"))
nhs_joined_3 <- read_csv(here("raw_data/nhs_data_joined3.csv"))

#checking consistency of rowbound csvs (do the columns match?)

compare_df_cols_same(nhs_joined_1, nhs_joined_2, nhs_joined_3)

#answer: Yes

#checking columns to spit into Workflow_Project

glimpse(here("raw_data/activity_by_board_age_sex.csv"))

glimpse()
head()
tail()


