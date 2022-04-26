# This script plots all admissions across Scotland per year. 

# This code will be used to identify UI and Server Elements.

# Read in Data Sets

nhs_data_joined2 <- read_csv(here("raw_data/nhs_data_joined2.csv"))


# Plots

adm_year_plot <- nhs_data_joined2 %>%
  filter(hb == "S92000003") %>%
  filter(age_group == "All ages") %>%
  filter(sex == "All") %>%
  filter(admission_type == "All") %>%
  #filter(season == "Summer") %>% #input required from ui 
  filter(quarter_year == 2021) %>% #input required from ui
  group_by(quarter_year, season) %>%
  ggplot(aes(x = week_ending, y = number_admissions))+
  geom_point()+
  geom_line(size = 1)+
  scale_x_date(date_breaks = "months")+
  geom_line(aes(x = week_ending, y = average20182019), colour = "red")+
  theme(axis.text.x = element_text(face="bold", angle=70, hjust=1),
        axis.title.x=element_blank())+
  labs(y = "Number of Admissions")


ggplotly(adm_year_plot)