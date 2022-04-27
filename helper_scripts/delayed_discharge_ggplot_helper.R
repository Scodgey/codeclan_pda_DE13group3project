#loading CLEANED data specifically for fable
delayed_discharge_df<- read_csv(here("clean_data/delayed_discharge_fable.csv")) 

#getting mean of mean for number of delayed bed days to normalize data for meaningful graph
delayed_discharge <- delayed_discharge_df%>% 
  group_by(datetime) %>%
  summarise(datetime, ave_num = mean(number_of_delayed_bed_days)) %>%  
  ggplot() + 
  geom_line(aes(x = datetime, y = ave_num, colour = "#603BF2"))+
  labs(title = "Average number of delayed bed days", y = "Delayed bed", x = "month over year") +
  theme(legend.position="none", plot.title = element_text(hjust = 0.5)) 

ggplotly(delayed_discharge)