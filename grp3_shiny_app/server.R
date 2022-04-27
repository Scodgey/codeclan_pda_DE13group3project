### THIS ALL NEEDS TO BE IN GLOBAL

library(zoo)

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
  mutate(quarter = as.Date(as.yearqtr(quarter, format = "%YQ%q"))) %>%
  filter(!location_qf %in% "d") %>%
  select(-contains("qf")) %>%
  left_join(location_look_up, by = "location") %>%
  filter(!is.na(location))

scot_health_board_shapes <-
  st_read(dsn = here("geospatial_data/scottish_local_authority_data_2021"),
          layer = "SG_NHS_HealthBoards_2019") %>%
  clean_names() %>%
  st_simplify(dTolerance = 2000) %>%
  rename(hb = hb_code) %>%
  st_transform('+proj=longlat +datum=WGS84')

delayed_discharge <- read_csv(here("clean_data/delayed_discharge_fable.csv"))

admissions <- read_csv(here("raw_data/nhs_data_joined2.csv")) %>%
  select(-contains("qf"))

location_data <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>%
  select(location, location_name) %>%
  rename(treatment_location = location)

source(here("helper_scripts/num_admissions_helper.R"))


  

delayed_discharge %>%
  group_by(age_group) %>%
  ggplot()+
  aes(x = age_group, y = number_of_delayed_bed_days)+
  geom_boxplot()





### dataset for creating the top 3 info boxes in Summary page and giving a rating
### for how well each Health Board is doing


library(shiny)
library(sf)

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {

  output$scottish_health_boards <- renderLeaflet({
    leaflet(scot_health_board_shapes) %>%
      addTiles() %>%
      addPolygons(popup = ~paste0(
        "NHS: ", hb_name, "<br>",
        "Health Board Code: ", hb
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

      filter(hb.x == rv(),
             quarter > input$date_range[1],
             quarter < input$date_range[2]) %>%

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

  output$ave_delayed_discharge_rate <- renderText({
    if (is.null(rv())){
      delayed_discharge %>%
        filter(age_group == "18plus",
               reason_for_delay == "All Delay Reasons")%>%
        summarise(ave = mean(number_of_delayed_bed_days)) %>%
        pull(ave)%>%
        round(digits = 2)
    }else{
     delayed_discharge %>%
      filter(age_group == "18plus",
             reason_for_delay == "All Delay Reasons",
             datetime > input$date_range[1],
             datetime < input$date_range[2],
             hbt == rv()) %>%
      summarise(ave = mean(number_of_delayed_bed_days)) %>%
      pull(ave)%>%
        round(digits = 2)}
  })

  output$ave_bed_occ <- renderText({
    if (is.null(rv())){
      joined_bed_data_3 %>%
        select(location_name, percentage_occupancy, hb.x)%>%
        #You can add a filter column her by location name linked to ui, allow multiple selections.
        summarise(location_total = n(),
                  average_bed_occupancy = mean(sum(percentage_occupancy, na.rm =TRUE)/
                                                 location_total)) %>%
        pull(average_bed_occupancy)%>%
        round(digits = 2)
    }else{
      joined_bed_data_3 %>%
      select(location_name, percentage_occupancy, hb.x, quarter) %>%
      filter(quarter > input$date_range[1],
             quarter < input$date_range[2],
             hb.x == rv()) %>%
    #You can add a filter column here by location name linked to ui, allow multiple selections.
      summarise(location_total = n(),
              average_bed_occupancy = mean(sum(percentage_occupancy, na.rm =TRUE)/
                                             location_total)) %>%
    pull(average_bed_occupancy) %>%
        round(digits = 2)}
  })

  output$ave_admissions <- renderText({
    if (is.null(rv())){
      admissions %>%
        select(hb, week_ending, number_admissions, age_group, sex)%>%
        filter(age_group == "All ages",
               sex == "All") %>%
        #You can add a filter column her by location name linked to ui, allow multiple selections.
        summarise(ave_adm = mean(number_admissions)) %>%
        pull(ave_adm)%>%
        round(digits = 2)
    }else{
      admissions %>%
        select(hb, week_ending, number_admissions, age_group, sex)%>%
        filter(week_ending > input$date_range[1],
              week_ending < input$date_range[2],
               hb == rv(),
               age_group == "All ages",
               sex == "All") %>%
        summarise(ave_adm = mean(number_admissions)) %>%
        pull(ave_adm)%>%
        round(digits = 2)}
  })

  output$ae_attendees_plot<- renderPlotly({
    ggplotly(
    act_ae_waiting %>%
    left_join(location_data, by = "treatment_location") %>%
    filter(location_name == input$hospital)%>%
    mutate(month = ym(month))%>%
    filter(!month < "2018-03-31")%>%
    filter(hbt == rv())%>%   #input required from ui
   #input required from ui
    ggplot()+
    geom_col(aes(x = month, y = number_meeting_target_aggregate), fill="lightblue", color = "black", width = 30, position = "dodge")+
    geom_col(aes(x = month, y = number_of_attendances_aggregate), fill="darkblue", width = 10)+
    scale_x_date(date_breaks = "months")+
    geom_vline(xintercept = as.numeric(as.Date("2020-04-01")), linetype = 2, colour = "red")+
    theme(axis.text.x = element_text(angle=70, hjust=1),
          axis.title.x=element_blank())+
    labs(y = "Number of A&E Attendences"))
  })


  ############################
  ## Occupancy Tab - Graphs ##
  ############################

  ### geom_line to compare different hospitals by quarter

  output$bed_occ_comparison_quarter <- renderPlotly({
    ggplotly(
      bed_data %>%
        #Create date variable.
        mutate(year_quarter = yearquarter(quarter), .after = quarter) %>%
        filter(!is.na(year_quarter)) %>%
        filter(location_name %in% c(input$hospital_multi_selection)) %>%
        #UI - You can add a filter column here by location name linked to ui, allow multiple selections.
        group_by(year_quarter, location_name) %>%
        summarise(location_total = n(),
                  average_bed_occupancy = round(sum(percentage_occupancy, na.rm =TRUE)/
                                                  location_total)) %>%
        ggplot()+
        aes(x = year_quarter, y = average_bed_occupancy, colour = location_name)+
        geom_line()+
        geom_point()+
        scale_alpha_continuous()
    )
  })



  output$bed_occ_specialty_comparison <- renderPlotly({
    ggplotly(

      bed_data %>%
        #Create date variable.
        mutate(year_quarter = yearquarter(quarter), .after = quarter) %>%
        filter(!is.na(year_quarter)) %>%
        filter(specialty_name %in% c(input$specialty_multi_selection)) %>%
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

    )
  })



  output$bed_occ_hyp_1 <- renderPlot({
    ### Hypothesis Test 1 - Difference in Average Bed Occupancy (Two Hospitals)

    #Perform an appropriate statistical test to determine whether
    #there is a statistically significant difference average bed occupancy between
    #two selected hospitals.

    #H0: There is no difference in average occupancy between two selected hospitals.
    #Ha: Ha: There is a difference in average occupancy between two selected hospitals.

    average_bed_occupancy_twohospitals <- bed_data %>%
      #UI - The below filter would be linked to the UI hospital selection. We can also
      # add a season filter.
      filter(location_name %in% c(input$hospital_boot_numero_uno, input$hospital_boot_numero_dos)) %>%
      filter(season == input$season) %>%
      group_by(location_name)

    observed_ave_occupancy_stat1 <- average_bed_occupancy_twohospitals %>%
      specify(percentage_occupancy ~ location_name) %>%
      #Order should be dictated by UI location name selection)
      calculate(stat = "diff in means",
                order = c(input$hospital_boot_numero_uno, input$hospital_boot_numero_dos))

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
                order = c(input$hospital_boot_numero_uno, input$hospital_boot_numero_dos))

    # This calculation generate probability of observing observed stat.
    #Selection of one-tailed test.
    p_value1 <- null_dist1 %>%
      get_p_value(obs_stat = observed_ave_occupancy_stat1, direction = "both")


    # Extension - Can we add an if function here to return a phrase whether there is
    #a significant difference based on probability value greater than significance value
    #(alpha)set at 0.05. Other development options could include UI selection of alpha.


    # Let's visualise the distribution with the observed stat. Direction set to
    #both because we are looking for difference.

    if(p_value1 <= 0.05){
      result = "Reject Null Hypothesis"
    } else {
      result = "Fail to Reject Null Hypothesis"
    }

    null_dist1 %>%
      visualise(bins = 30) +
      shade_p_value(obs_stat = observed_ave_occupancy_stat1, direction = "both") +
      labs(title = "Simulation Based Null Distribution (Diff in Means)",
           x = "Null Distribution" , y = "Count",
           caption = paste0("Observed Stat:", round(observed_ave_occupancy_stat1),
                            "\n",
                            "Prob Value: ", p_value1, "\n", "alpha = ", 0.05,
                            "\n",
                            result))
  })






output$bed_occ_hyp_2 <- renderPlot({

  #Perform an appropriate statistical test to determine whether
  #there is a statistically significant difference average bed occupancy between
  #one hospital and the average bed occupancy for Scotland .


  #H0: There is no difference in average occupancy between selected hospital and
  #Scotland.
  #Ha: There is a difference between the selected hospital is greater than average
  #for all of Scotland.

  #Calculate Average Occupancy for All of Scotland Hospitals

  ave_occupancy_scotland <- bed_data %>%
    filter(season == input$season) %>%
    summarise(total = n(), average_bed_occupancy = round(sum(percentage_occupancy,
                                                             na.rm =TRUE)/
                                                           total))

  #Bootstrap on calculated Average Bed Occupancy for all of Scotland (No filters).
  #Mean used in calculation is from previous code line.

  null_dist2 <- bed_data %>%
    filter(season == input$season) %>%
    specify(response = percentage_occupancy) %>%
    #We are hypothesing that our mean rating for all of Scotlands hospitals will be
    # = to our cacluated value (i.e. no difference)
    hypothesize(null = "point", mu = ave_occupancy_scotland$average_bed_occupancy) %>%
    generate(reps = 10000, type = "bootstrap") %>%
    calculate(stat = "mean")

  #Calculate Average Occupancy for selected hospital.

  average_bed_occupancy_onehospital_stat2 <- bed_data %>%
    filter(season == input$season) %>%
    #UI - The below filter would be linked to the UI hospital selection.
    filter(location_name == input$hospital_boot_numero_uno) %>%
    group_by(location_name) %>%
    summarise(total = n(),
              average_bed_occupancy_onehospital = sum(percentage_occupancy,
                                                      na.rm = TRUE)/total)

  # This calculation generate probability of observing observed stat.
  #Selection of one-tailed test.
  p_value2 <- null_dist2 %>%
    get_p_value(obs_stat = average_bed_occupancy_onehospital_stat2$average_bed_occupancy_onehospital,
                direction = "both")

  if(p_value1 <= 0.05){
    result = "Reject Null Hypothesis"
  } else {
    result = "Fail to Reject Null Hypothesis"
  }

  null_dist2 %>%
    visualise(bins = 30) +
    shade_p_value(obs_stat = average_bed_occupancy_onehospital_stat2$average_bed_occupancy_onehospital, direction = "both") +
    labs(title = "Simulation Based Null Distribution (Diff in Means)",
         x = "Null Distribution" , y = "Count",
         caption = paste0("Observed Stat:", round(average_bed_occupancy_onehospital_stat2$average_bed_occupancy_onehospital),
                          "\n",
                          "Prob Value: ", p_value2, "\n", "alpha = ", 0.05,
                          "\n",
                          result))
})


output$delayed_bed_discharge_timeseries <- renderPlotly({
  ggplotly(delayed_bed_discharge_timeseries)
})



})
