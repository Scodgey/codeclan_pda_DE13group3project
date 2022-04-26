#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  joined_bed_data %>%
    select(location_name, percentage_occupancy) %>% 
    #You can add a filter column her by location name linked to ui, allow multiple selections.
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
  
  
  
  

})
