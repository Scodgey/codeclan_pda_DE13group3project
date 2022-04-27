#delayed discharge data prep: precursor to fable
#libraries loaded from global.R
delayed_discharge_df <- read_csv(here("raw_data/delayed-discharge-beddays-health-board.csv")) %>%
  clean_names()

#POSIX compliant datetime as discrete field from original month_of_delay
delayed_discharge_df <- delayed_discharge_df %>% 
  mutate(datetime = ym(month_of_delay), .after = month_of_delay) %>% 
  filter(datetime >= "2018-04-01")
  filter(!age_group == "18plus") #removing 18plus value from age column-- nothing to

  
#Writing output to a -new- csv
  write_csv(delayed_discharge_df, here("clean_data/delayed_discharge_fable.csv"))
  
  
  
  

