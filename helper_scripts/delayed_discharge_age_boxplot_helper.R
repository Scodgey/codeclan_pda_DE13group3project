delayed_discharge_df <- read_csv(here("raw_data/delayed-discharge-beddays-health-board.csv")) %>% clean_names()

delayed_discharge_df %>% 
  group_by(reason_for_delay) %>% 
  summarise(total_number_of_delayed_bed_days = sum(number_of_delayed_bed_days)) %>% 
  ggplot() +
  geom_boxplot(aes(x = total_number_of_delayed_bed_days, y = reason_for_delay))
geom_col()

delayed_discharge_df %>% 
  group_by(age_group) %>% 
  ggplot()+
  aes(x = age_group, y = number_of_delayed_bed_days) +
  geom_boxplot()