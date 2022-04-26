### THIS ALL NEEDS TO BE IN GLOBAL 

# Loading in location and removing id and qualifier columns
location_look_up <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>% 
  clean_names() %>% 
  select(-"id",
    -contains("_qf"))

# joining location data with nhs data 3 and manipulating the data
joined_bed_data <- nhs_data_joined3 %>% 
  rename("available_staffed_beds" = "all_staffed_beds") %>% 
  mutate(
    average_available_staffed_beds = round(average_available_staffed_beds),
    average_occupied_beds = round(average_occupied_beds), 
    percentage_occupancy = round(percentage_occupancy),
    ) %>% 
  filter(!is.na(quarter_year))%>% 
  filter(!location_qf %in% "d") %>% 
  select(-contains("_qf")) %>% 
  left_join(location_look_up, by = "location") 


library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  
  
  
  
  
  # joined_bed_data %>%
  #   select(location_name, percentage_occupancy) %>% 
  #   #You can add a filter column her by location name linked to ui, allow multiple selections.
  #   group_by(location_name) %>% 
  #   summarise(location_total = n(), 
  #             average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/ 
  #                                             location_total)) %>% 
  #   mutate(quartiles = cut_number(x = average_bed_occupancy,n = 4, 
  #                                 labels = c("AveOcc in Lowest 25%",
  #                                            "AveOcc in Lowest 50%",
  #                                            "AveOcc in Highest 50%", 
  #                                            "AveOcc in Highest 75%"))
  #   ) %>% 
  #   ggplot()+
  #   aes(x = location_name, y = average_bed_occupancy, fill = quartiles)+
  #   geom_col()+
  #   theme_bw() +
  #   coord_flip()+
  #   labs(x = "Location Name", y = "Average Bed Occupancy (%)")+
  #   scale_fill_discrete(name = "Quartile")
  # 
  # ggplotly(plot1)
  
  
  
  

})
