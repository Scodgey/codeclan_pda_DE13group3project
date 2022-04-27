# This script plots the total number of attendances against the number of attendances 
# that are admitted, transferred or discharged within four hours of arrival at an A&E service.
# An attendance represents the presence of a patient in an A&E service seeking medical attention.

# This code will be used to identify UI and Server Elements.

# Read in Data Sets

act_ae_waiting <-read_csv(here("raw_data/monthly_ae_activity_waitingtimes.csv")) %>% 
  clean_names()

# Plots

ae_wait_plot <- act_ae_waiting %>%
  mutate(month = ym(month))%>%
  filter(!month < "2018-03-31")%>%
  filter(hbt == "S08000015")%>%   #input required from ui 
  filter(treatment_location == "A110H")%>%   #input required from ui 
  ggplot()+
  geom_col(aes(x = month, y = number_meeting_target_aggregate), fill="lightblue", color = "black", width = 30, position = "dodge")+
  geom_col(aes(x = month, y = number_of_attendances_aggregate), fill="darkblue", width = 10)+
  scale_x_date(date_breaks = "months")+
  geom_vline(xintercept = as.numeric(as.Date("2020-04-01")), linetype = 2, colour = "red")+
  theme(axis.text.x = element_text(angle=70, hjust=1),
        axis.title.x=element_blank())+
  labs(y = "Number of A&E Attendences")


ggplotly(ae_wait_plot)