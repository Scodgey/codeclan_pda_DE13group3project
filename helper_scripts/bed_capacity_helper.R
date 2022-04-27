
#This bed capacity helper script has been developed for the purposes
#of providing the code necessary to generate the bed capacity elements of 
#the Group 3 R Shiny Dashboard. 

#This code will be used to identify UI and Server Elements.


###############################################.
## Read in Data Sets ---- 
###############################################.

#Bed capacity data located within NHS Data joined 4.

bed_data <- read_csv(here("raw_data/nhs_data_joined4.csv"))  
 
###############################################.
## Analysis & Plots (Visualisations) ----
###############################################.

#Plot 1 - Hospital Average Occupancy (%) Compared to other Scottish Hospitals
  
plot1 <- bed_data %>%
  select(location_name, percentage_occupancy) %>% 
  ## UI - You can add a filter column her by location name linked to ui, allow multiple selections.
  group_by(location_name) %>% 
  summarise(location_total = n(), 
            average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/ 
                                            location_total)) %>% 
  mutate(quartiles = cut_number(x = average_bed_occupancy,n = 4, 
                                labels = c("AveOcc in Lowest 25%",
                                           "AveOcc in Lowest 50%",
                                           "AveOcc in Highest 50%", 
                                           "AveOcc in Highest 75%"))
  ) %>% 
  ggplot()+
  aes(x = location_name, y = average_bed_occupancy, fill = quartiles)+
  geom_col()+
  theme_bw() +
  coord_flip()+
  labs(x = "Location Name", y = "Average Bed Occupancy (%)")+
  scale_fill_discrete(name = "Quartile")

ggplotly(plot1)

#Checked NA's prior to removal, 8 in total across Dr Grays Hospital & Borders. 
# Should a verification be added here in terms of NA's exceed percentage of 
#location total entries.


#Plot 2 - Average Bed Occupancy by Season 
  
plot2 <- bed_data %>%
  select(location_name, percentage_occupancy, season) %>%  
  ##UI - Add a filter column here by location name linked to ui, allow multiple selections.
  group_by(location_name, season) %>% 
  summarise(location_total = n(), 
            average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/ 
                                            location_total)) %>% 
  ggplot()+
  aes(x = location_name, y = average_bed_occupancy, shape = season, colour = season)+
  geom_point()+
  theme_bw()+
  coord_flip()+
  labs(title = "Average Bed Occupancy (%) by Season", 
       x = "Location Name", y = "Average Bed Occupancy (%)")

#Plot 3 - Hospital Average Occupancy (%) by Specialty (All) Hospitals
  
plot3 <- bed_data %>%
  select(specialty_name, percentage_occupancy) %>% 
  filter(!specialty_name %in% c("All Specialties", "All Acute")) %>% 
  ##UI - Add a filter column here by specialty name linked to ui, allow multiple selections.
  filter(specialty_name == "Physiotherapy" | specialty_name == "Infectious Diseases") %>% 
  group_by(specialty_name) %>% 
  summarise(specialty_total = n(), 
            average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/ 
                                            specialty_total)) %>% 
  arrange(desc(average_bed_occupancy)) %>% 
  ggplot()+
  aes(x = reorder(specialty_name, desc(average_bed_occupancy)), 
      y = average_bed_occupancy, fill = specialty_name)+
  geom_col()+
  theme_bw() +
  labs(title = "Average Bed Occupancy (%) by Specialty" , 
       x = "Specialty Name", y = "Average Bed Occupancy (%)")+
  theme(legend.position = "none", axis.text.x=element_blank())
  

ggplotly(plot3)


#Plot 4 - Average Bed Occupancy - All Hospital by Quarter**
  

plot4 <- bed_data %>%
  #Create date variable.
  mutate(year_quarter = yearquarter(quarter), .after = quarter) %>% 
  filter(!is.na(year_quarter)) %>% 
  filter(location_name == "Aberdeen Royal Infirmary" |
           location_name == "St John's Hospital") %>% 
  #UI - You can add a filter column here by location name linked to ui, allow multiple selections.
  group_by(year_quarter, location_name) %>% 
  summarise(location_total = n(), 
            average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/ 
                                            location_total)) %>% 
  ggplot()+
  aes(x = year_quarter, y = average_bed_occupancy, colour = location_name)+
  geom_line()+
  geom_point()+
  scale_alpha_continuous()+
labs(title = "Average Bed Occupancy (%) by, Location & Quarter (2018 Q1 Onwards)")


ggplotly(plot4) 


#Plot 5 - Average Bed Occupancy - Selected Specialty by Quarter
  

plot5 <- bed_data %>%
  #Create date variable.
  mutate(year_quarter = yearquarter(quarter), .after = quarter) %>% 
  filter(!is.na(year_quarter)) %>% 
  filter(specialty_name == "General Medicine" |
           specialty_name == "Accident & Emergency") %>% 
  #UI - You can add a filter column here by location name linked to ui, allow multiple selections.
  group_by(year_quarter, specialty_name) %>% 
  summarise(specialty_total = n(), 
            average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/ 
                                            specialty_total)) %>% 
  ggplot()+
  aes(x = year_quarter, y = average_bed_occupancy, colour = specialty_name)+
  geom_line()+
  geom_point()+
  scale_alpha_continuous()
labs(title = "Average Bed Occupancy (%) by, Specialty & Quarter (2018 Q1 Onwards)")


ggplotly(plot5) 


###############################################.
## Hypothesis Testing 1 & 2
###############################################.

### Hypothesis Test 1 - Difference in Average Bed Occupancy (Two Hospitals)

#Perform an appropriate statistical test to determine whether 
#there is a statistically significant difference average bed occupancy between 
#two selected hospitals. 

#H0: There is no difference in average occupancy between two selected hospitals.
#Ha: Ha: There is a difference in average occupancy between two selected hospitals.

average_bed_occupancy_twohospitals <- bed_data %>% 
  #UI - The below filter would be linked to the UI hospital selection. We can also
  # add a season filter.
  filter(location_name == "Western General Hospital" | 
           location_name == "Belford Hospital") %>%
  filter(season == "Autumn") %>% 
  group_by(location_name) 

observed_ave_occupancy_stat1 <- average_bed_occupancy_twohospitals %>% 
  specify(percentage_occupancy ~ location_name) %>%
  #Order should be dictated by UI location name selection)
  calculate(stat = "diff in means", 
            order = c("Western General Hospital", "Belford Hospital"))

# This code creates a null distribution to determine if 
#observed_ave_occupancy_stat1 is significant. 

null_dist1 <- average_bed_occupancy_twohospitals %>% 
  #testing relationship between hospital and average bed occupancy.
  specify(percentage_occupancy ~ location_name) %>% 
  #the null hypothesis is there is no relationship i.e. they are independent
  hypothesise(null = "independence") %>% 
  generate(reps = 10000, type = "permute") %>% 
  #Sample stat is mean of hospitals done in this order.
  calculate(stat = "diff in means", 
            order = c("Western General Hospital", "Belford Hospital"))

# This calculation generate probability of observing observed stat.
#Selection of one-tailed test.
p_value1 <- null_dist1 %>%
  get_p_value(obs_stat = observed_ave_occupancy_stat1, direction = "both")


# Extension - Can we add an if function here to return a phrase whether there is
#a significant difference based on probability value greater than significance value
#(alpha)set at 0.05. Other development options could include UI selection of alpha.


# Let's visualise the distribution with the observed stat. Direction set to 
#both because we are looking for difference. 

null_dist1 %>%
  visualise(bins = 30) +
  shade_p_value(obs_stat = observed_ave_occupancy_stat1, direction = "both") +
  labs(title = "Simulation Based Null Distribution (Diff in Means)", 
       x = "Null Distribution" , y = "Count", 
       caption = paste0("Observed Stat:", round(observed_ave_occupancy_stat1),
                        "\n",
                        "Prob Value: ", p_value1, "\n", "alpha = ", 0.05))

# This code generates the confidence intervals (upper and lower) for the
#generated null distribution.

bed_ci_95_twohospitals <- null_dist1 %>%
  get_confidence_interval(level = 0.95, type = "percentile")

#This code generate the visual of the confidence intervals.

null_dist1%>%
  visualise(bins = 30) +
  shade_confidence_interval(endpoints = bed_ci_95_twohospitals)+
  labs(title = "Distribution (95% Confidence Interval) ", 
       x = "Null Distribution (CI)" , 
       y = "Count", 
       caption = paste0("CI Lower: ", round(bed_ci_95_twohospitals$lower_ci, 
                                            digits = 3), "\n",
                        "CI Upper: ", round(bed_ci_95_twohospitals$upper_ci, 
                                            digits = 3)))


#Hypothesis Test 2 - Difference in Average Bed Occupancy (Hospitals Vs Scotland)

#Perform an appropriate statistical test to determine whether 
#there is a statistically significant difference average bed occupancy between 
#one hospital and the average bed occupancy for Scotland . 


#H0: There is no difference in average occupancy between selected hospital and 
#Scotland.
#Ha: There is a difference between the selected hospital is greater than average
#for all of Scotland.

#Calculate Average Occupancy for All of Scotland Hospitals

ave_occupancy_scotland <- bed_data %>%
  summarise(total = n(), average_bed_occupancy = round(sum(percentage_occupancy,
                                                           na.rm =TRUE)/ 
                                                         total))

#Bootstrap on calculated Average Bed Occupancy for all of Scotland (No filters).
#Mean used in calculation is from previous code line. 

null_dist2 <- bed_data %>% 
  specify(response = percentage_occupancy) %>% 
  #We are hypothesing that our mean rating for all of Scotlands hospitals will be
  # = to our cacluated value (i.e. no difference)
  hypothesize(null = "point", mu = ave_occupancy_scotland$average_bed_occupancy) %>% 
  generate(reps = 10000, type = "bootstrap") %>% 
  calculate(stat = "mean")

#Calculate Average Occupancy for selected hospital.

average_bed_occupancy_onehospital_stat2 <- bed_data %>% 
  #UI - The below filter would be linked to the UI hospital selection. 
  filter(location_name == "Western General Hospital") %>% 
  group_by(location_name) %>% 
  summarise(total = n(), 
            average_bed_occupancy_onehospital = sum(percentage_occupancy, 
                                                    na.rm = TRUE)/total)

# This calculation generate probability of observing observed stat.
#Selection of one-tailed test.
p_value2 <- null_dist2 %>%
  get_p_value(obs_stat = average_bed_occupancy_onehospital_stat2$average_bed_occupancy_onehospital, 
              direction = "both")

p_value2

# Extension - Can we add an if function here to return a phrase whether there is
#a significant difference based on probability value greater than significance value
#(alpha)set at 0.05. Other development options could include UI selection of alpha.

# Lets's visualise the distribution with the observed stat. Direction set to 
#both because we are looking for difference. 

null_dist2 %>%
  visualise(bins = 30) +
  shade_p_value(obs_stat = average_bed_occupancy_onehospital_stat2$average_bed_occupancy_onehospital, direction = "both") +
  labs(title = "Simulation Based Null Distribution (Diff in Means)", 
       x = "Null Distribution" , y = "Count", 
       caption = paste0("Observed Stat:", round(average_bed_occupancy_onehospital_stat2$average_bed_occupancy_onehospital),
                        "\n",
                        "Prob Value: ", p_value2, "\n", "alpha = ", 0.05))

# This code generates the confidence intervals (upper and lower) for the
#generated null distribution.

bed_ci_95_onehospital <- null_dist2 %>%
  get_confidence_interval(level = 0.95, type = "percentile")

null_dist2%>%
  visualise(bins = 30) +
  shade_confidence_interval(endpoints = bed_ci_95_onehospital)+
  labs(title = "Distribution (95% Confidence Interval) ", 
       x = "Null Distribution (CI)" , y = "Count", 
       caption = paste0("CI Lower: ", round(bed_ci_95_onehospital$lower_ci, digits = 3), "\n",
                        "CI Upper: ", round(bed_ci_95_onehospital$upper_ci, digits = 3)))