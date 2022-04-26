### THIS ALL NEEDS TO BE IN GLOBAL 

# Loading in location and removing id and qualifier columns
location_look_up <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>% 
  clean_names() %>% 
  select(-"id",
    -contains("qf"))

# joining location data with nhs data 3 and manipulating the data
joined_bed_data_3 <- read_csv(here("raw_data/nhs_data_joined3.csv")) %>% 
  rename("available_staffed_beds" = "all_staffed_beds") %>% 
  mutate(
    average_available_staffed_beds = round(average_available_staffed_beds),
    average_occupied_beds = round(average_occupied_beds), 
    percentage_occupancy = round(percentage_occupancy),
    ) %>% 
  filter(!is.na(quarter_year))%>% 
  filter(!location_qf %in% "d") %>% 
  select(-contains("qf")) %>% 
  left_join(location_look_up, by = "location") 

scot_health_board_shapes <- 
  st_read(dsn = here("geospatial_data/scottish_local_authority_data_2021"), 
          layer = "SG_NHS_HealthBoards_2019") %>% 
  clean_names() %>% 
  st_simplify(dTolerance = 2000) %>% 
  rename(hb = hb_code) %>% 
  st_transform('+proj=longlat +datum=WGS84')

ave_bed_occ <- joined_bed_data_3 %>%
  select(location_name, percentage_occupancy, hb.x) %>%
  #You can add a filter column her by location name linked to ui, allow multiple selections.
  summarise(location_total = n(),
            average_bed_occupancy = mean(sum(percentage_occupancy, na.rm =TRUE)/
                                           location_total)) %>% 
  pull(average_bed_occupancy) %>% 
  round()



library(shiny)
library(sf)

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
  
  output$scottish_health_boards <- renderLeaflet({
    leaflet(scot_health_board_shapes) %>%
      addTiles() %>%
      addPolygons(popup = ~paste0(
        "NHS: ", hb_name, "<br>",
        "Health Board Code: ", hb, "<br>",
        "Admissions: ", "%", "<br>",
        "Bed Occupancy: ", "%", "<br>",
        "Discharge Delay: ", "%"
        ),
        layerId = scot_health_board_shapes$hb)
  })
  
  ######################################
  ### Code for filtering by Polygons ###
  ######################################
  rv <- reactiveVal()
  observeEvent(input$scottish_health_boards_shape_click,{
    rv(input$scottish_health_boards_shape_click$id)
  })


  
#########################################################
### Plotting the hospitals with the highest occupancy ###
#########################################################

  output$top_occupancy_hospitals <- renderPlot({
    if (is.null(rv())){
      joined_bed_data_3 %>%
        select(location_name, percentage_occupancy, hb.x) %>%
        #You can add a filter column her by location name linked to ui, allow multiple selections.
        group_by(location_name) %>%
        summarise(location_total = n(),
                  average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/
                                                  location_total)) %>%
        arrange(desc(average_bed_occupancy)) %>% 
        ggplot()+
        aes(x = reorder(location_name, average_bed_occupancy), y = average_bed_occupancy)+
        geom_col()+
        theme_bw() +
        coord_flip()+
        labs(x = "Location Name", y = "Average Bed Occupancy (%)")
    
    } else {
    joined_bed_data_3 %>%
      
      ### This is the difference between this and above - so there will always
      ### be a plot 
      
      filter(hb.x == rv()) %>%
      
      ### The data gets filtered by which polygon is clicked
      
      select(location_name, percentage_occupancy, hb.x) %>%
      #You can add a filter column her by location name linked to ui, allow multiple selections.
      group_by(location_name) %>%
      summarise(location_total = n(),
                average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/
                                                location_total)) %>%
        arrange(desc(average_bed_occupancy)) %>% 
      ggplot()+
      aes(x = reorder(location_name, average_bed_occupancy), y = average_bed_occupancy)+
      geom_col()+
      theme_bw() +
      coord_flip()+
      labs(x = "Location Name", y = "Average Bed Occupancy (%)")}
  })
  





  
  
  
})
