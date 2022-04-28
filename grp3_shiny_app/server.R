# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {

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
    if (is.null(rv())){
    ggplotly(
    act_ae_waiting %>%
    left_join(location_data, by = "treatment_location") %>%
    mutate(month = ym(month))%>%
    filter(!month < "2018-03-31")%>%   
    ggplot()+
    geom_col(aes(x = month, y = number_meeting_target_aggregate), fill="lightblue", color = "black", width = 30, position = "dodge")+
    geom_col(aes(x = month, y = number_of_attendances_aggregate), fill="darkblue", width = 10)+
    scale_x_date(date_breaks = "months")+
    geom_vline(xintercept = as.numeric(as.Date("2020-04-01")), linetype = 2, colour = "red")+
    theme(axis.text.x = element_text(angle=70, hjust=1),
          axis.title.x=element_blank())+
    labs(y = "Number of A&E Attendences"))
      }else{
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
            labs(y = "Number of A&E Attendences"))}
  })


  ############################
  ## Occupancy Tab - Graphs ##
  ############################

  ### geom_line to compare different hospitals by quarter

  output$bed_occ_comparison_quarter <- renderPlotly({
    req(input$hospital_multi_selection)
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
    req(input$specialty_multi_selection)
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


output$admissions_age_grouped <- renderPlotly({
  
  admissions_age_groups <- admissions %>% 
    filter(age_group != "All ages",
           !is.na(age_group)) %>% 
    select(hb, week_ending, age_group, number_admissions, percent_variation) %>%
    filter(hb == input$healthboard_demographics) %>%  
    group_by(week_ending, age_group) %>% 
    summarise(age_group, ave = mean(number_admissions)) %>% 
    mutate(age_group = factor(age_group,
                              levels = c("Under 5",
                                         "5 - 14",
                                         "15 - 44",
                                         "45 - 64",
                                         "65 - 74",
                                         "75 - 84",
                                         "85 and over"))) %>%
    arrange(desc(age_group)) %>% 
    ggplot()+
    aes(x = age_group, y = ave)+
    geom_boxplot()+
    xlab("Age Groupings")+
    ylab("Number of Admissions")
  
  ggplotly(admissions_age_groups)
})


output$admissions_simd_quin_grouped <- renderPlotly({
  
  admissions_simd_quin <- admissions %>% 
    filter(!is.na(simd_quintile)) %>%
    select(hb, week_ending, simd_quintile, number_admissions, percent_variation) %>% 
    filter(hb == input$healthboard_demographics) %>% 
    mutate(simd_quintile = as.character(simd_quintile)) %>% 
    group_by(week_ending, simd_quintile) %>% 
    summarise(simd_quintile, ave = mean(number_admissions)) %>% 
    arrange(desc(simd_quintile)) %>% 
    ggplot()+
    aes(x = simd_quintile, y = ave, fill =simd_quintile)+
    geom_col()+
    xlab("Deprivation Scores")+
    ylab("Average Number of Admissions")+ 
    scale_fill_manual(values=c("1" = "#ACF0F2",
                                 "2" = "#0003C7",
                                 "3" = "#799AE0",
                                 "4" = "#002253",
                                 "5" = "#0092B2"))+
    theme(legend.position = "none")
  
  ggplotly(admissions_simd_quin)
})



output$admissions_gender <- renderPlotly({
  attendance_gender <- admissions %>%
    select(week_ending, sex, number_admissions, hb) %>% 
    filter(!sex == "All") %>%
    filter(hb == input$healthboard_demographics) %>% 
    group_by(sex) %>%
    summarise(number_of_admissions = mean(number_admissions, na.rm = TRUE)) %>%
    ggplot() +
    aes(y = number_of_admissions) +
    geom_col(aes(x = sex, fill = sex))+
    xlab("Genders")+
    ylab("Average Number of Admissions")
  ggplotly(attendance_gender)
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

  if(p_value2 <= 0.05){
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
  ggplotly(delayed_discharge_plot)
})

output$delayed_bed_discharge_by_reason <- renderPlot({
  delayed_discharge %>% 
  select(reason_for_delay, datetime, age_group, average_daily_number_of_delayed_beds) %>% 
  filter(reason_for_delay != "All Delay Reasons",
         age_group == "18plus",
         datetime > input$date_range[1],
         datetime < input$date_range[2]) %>% 
  group_by(reason_for_delay) %>% 
  summarise(ave_num_delay = sum(average_daily_number_of_delayed_beds)) %>% 
  ggplot()+
  aes(area = ave_num_delay, 
      label = paste(reason_for_delay, "\n", 
                    ave_num_delay), 
      fill = reason_for_delay)+
  geom_treemap()+
  geom_treemap_text(fontface = "italic", 
                    colour = "white", 
                    place = "centre",
                    size = 15,
                    grow = TRUE)+
  theme(legend.position = "none")
  })


output$delayed_dischrge_prediction_model <- renderPlot({
  delayed_dischrge_prediction_model
})

output$admission_prediction_model_2018_2019 <- renderPlot({
  admission_prediction_model_to_plot_1
})

output$admission_prediction_model_2020_to_2022 <- renderPlot({
  admission_prediction_model_to_plot_2
})

# output$delayed_discharge_prediction_model <- reactive({delayed_dis_ts <- delayed_discharge %>%
#   filter(!age_group == "18plus")%>%
#   filter(!reason_for_delay == "All Delay Reasons") %>%
#   filter(hbt == "S92000003")%>%
#   as_tsibble(key = c(hbt, age_group, reason_for_delay, number_of_delayed_bed_days), index = datetime)
# 
# # for some reason one of the forecasting models seems to be working better with 
# # the format yearmonth, so we'll change our datetime column
# # then we select the variables we need and sumamrise the number of delayed beds
# delayed_dis_ts_sum <- delayed_dis_ts%>%
#   mutate(datetime = yearmonth(datetime))%>%
#   as_tsibble(index = datetime) %>%
#   select(datetime, number_of_delayed_bed_days)%>%
#   summarise(count = sum(number_of_delayed_bed_days))
# 
# # create a fit dataset which has the results from our three different models
# fit_delayed <- delayed_dis_ts_sum %>%
#   model(
#     snaive = SNAIVE(count),
#     mean_model = MEAN(count),
#     arima = ARIMA(count)
#   )
# 
# # with the models specified, we can now produce the forecasts.
# # choose the number of future observations to forecast,
# # this is called the forecast horizon
# # once we’ve calculated our forecast, we can visualise it using
# # the autoplot() function that will produce a plot of all forecasts.
# delayed_dischrge_prediction_model <- fit_delayed %>%
#   fabletools::forecast(h = "3 years") %>%
#   autoplot(delayed_dis_ts_sum)+
#   guides(colour = guide_legend(title = "3-Year Forecast"))+
#   labs(x = "", y = "number of delayed beds")
# # by default, argument level = c(80,95) is passed to autoplot(), and so 80% and 95% prediction intervals
# # are shown.
# })




})
