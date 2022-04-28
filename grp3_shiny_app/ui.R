body <-
  dashboardBody(
    
    ###########################################
    ###  Dashboard layout for SUMMARY page  ###
    ###########################################
    
    tabItems(
      tabItem(tabName = "Summary",
              fluidRow(
                
                
                # Creating an Info box of current admission number for the quarter
                # Default will be whole population (if can work this out)
                infoBox(
                  "Current Admission numbers", # info box title
                  textOutput("ave_admissions"), # value in info box
                  icon = icon("hospital-user"), # hospital user icon
                  color = "light-blue",
                  # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime,
                  # orange, fuchsia, purple, maroon, black
                  fill = TRUE
                ),
                
                infoBox(
                  "Current Occupancy Percentage", # info box title
                  textOutput("ave_bed_occ"),  # occupancy rate but have total as default
                  icon = icon("bed"), # bed icon for info box
                  color = "light-blue",
                  fill = TRUE
                ),
                
                infoBox(
                  title = "Current Delayed Discharge Rate", # info box title
                  textOutput("ave_delayed_discharge_rate"), # discharge rate but have total as default
                  icon = icon("running"), # person icon for info box
                  color = "light-blue",
                  fill = TRUE
                )
              ),
              
              
              ########################
              ### Health Board Map ###
              ########################
              
              fluidRow(
                column(6,
                       box(
                         status = "primary", # allows header to be coloured
                         title = "Health Boards across Scotland",
                         solidHeader = TRUE,
                         leafletOutput(
                           outputId = "scottish_health_boards"
                         ),
                         width = NULL,
                         height = 500
                       )
                ),
                
                column(6,
                       tabBox(
                         #title = "Hospitals across Scottish Health Boards",
                         height = 500,
                         width = NULL,
                         
                         tabPanel(
                           "Bed Occupancy by Hospital",
                           plotOutput("top_occupancy_hospitals"),
                           width = NULL,
                           height = "100%"
                         ),
                         
                         tabPanel(
                           "A&E Targets by Hospital",
                           plotlyOutput("ae_attendees_plot"),
                           width = NULL,
                           height = "100%"
                         )
                       )
                )
              )
      ),
      
      
      ##############################################
      ###  Dashboard layout for ADMISSIONS page  ###
      ##############################################
      
      tabItem(tabName = "Admissions",
              
              
              fluidRow(
                selectInput(
                  "healthboard_demographics",
                  "Choose a NHS Health Board",
                  choices = c(unique(admissions$hb))
                )
              ),
              
              #Creating the second row with the following columns
              # 1. age graph - that changes on year and health baord selected
              # 2. box plot of gender
              # 3. graph of smid score
              
              fluidRow(
                column(6,
                       box(
                         solidHeader = TRUE,
                         status = "primary",
                         title = "Age",
                         plotlyOutput("admissions_age_grouped"),
                         width = "100%",
                         height = "100%"
                       )),
                column(6, box(
                  solidHeader = TRUE,
                  status = "primary",
                  title = "Gender",
                  plotlyOutput("admissions_gender"),
                  width = "100%",
                  height = "100%"
                ))
              ),
              
              fluidRow(
                column(6, 
                       offset = 3,
                       box(
                         solidHeader = TRUE,
                         status = "primary",
                         title = "Deprivation",
                         plotlyOutput("admissions_simd_quin_grouped"),
                         width = "100%",
                         height = "100%"
                       ))
              )
      ),
      
      #############################################
      ###  Dashboard layout for OCCUPANCY page  ###
      #############################################
      
      tabItem(tabName = "Occupancy",
              
              fluidRow(
                
                column(6,
                       #Selection for hospitals excluding bootstrap graphs
                       selectInput(
                         "hospital_multi_selection",
                         "Select Hospitals to Compare Bed Occupancy",
                         choices = c(unique(bed_data$location_name)),
                         multiple = 5
                       )
                ),
                
                #Selection for speciality for graph
                column(6,
                       selectInput(
                         "specialty_multi_selection",
                         "Select Specialty to Compare Bed Occupancy",
                         choices = c(unique(bed_data$specialty_name)),
                         multiple = 5
                       ))
              ),
              
              fluidRow(
                
                #Creating the first row with the following columns
                # 1. graph of trend of admissions with predictive modelling
                # 2. row for the percentage of elect v planned & top 5 most populated health boards
                
                column(6,
                       box(
                         status = "primary",
                         title = "Comparing Average Bed Occupancy Between Hospitals per Quarter",
                         #this should be static but highlighted portion shows year selected
                         plotlyOutput("bed_occ_comparison_quarter"),
                         width = "100%",
                         height = "100%",
                         solidHeader = TRUE
                       )
                ),
                
                column(6,
                       box(
                         title = "Average Bed Occupancy (%) by Specialty",
                         #this should be static but highlighted portion shows year selected
                         plotlyOutput("bed_occ_specialty_comparison"),
                         width = "100%",
                         height = "100%",
                         status = "primary",
                         solidHeader = TRUE
                       )
                )
              ),
              
              fluidRow(
                
                #Selection numero uno for bootstrapping
                column(3, selectInput(
                  "hospital_boot_numero_uno",
                  "Select Hospital for testing significant difference of bed occupancy mean #1",
                  choices = c(unique(bed_data$location_name)),
                  multiple = FALSE
                )),
                
                #Selection numero dos for bootstrapping
                column(3, 
                       selectInput(
                         "hospital_boot_numero_dos",
                         "Select Hospital for testing significant difference of bed occupancy mean #2",
                         choices = c(unique(bed_data$location_name)),
                         multiple = FALSE
                       )),
                
                column(3,
                       selectInput(
                  "season",
                  label = "Season:",
                  choices = c(unique(bed_data$season)),
                  multiple = TRUE
                ))
              ),
              
              fluidRow(
                box(
                  title = "Null Distribution Explaination",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  height = "100%",
                  "In the study of probability theory, the central limit theorem states that the distribution of sample approximates a normal distribution (also known as a “bell curve”) as the sample size becomes larger.",
                  
                  "Inferential statistics allows us to draw conclusions from a sample and generalise them to a population.",
                  
                  "To conduct these test, select two hospitals from the drop down and also assign season(s) to produce a test of your hypothesis.",
                  
                  "If your test produces a probability value (p-value) below 0.05 - any difference observed is of significance."
                )
              ),
              
              # Creating the second row and plots null hypothesis test from inputs
              # of season and hospitals 
              
              fluidRow(
                
                box(
                  title = "Testing Mean Bed Occupancy Between Hospitals",
                  plotOutput("bed_occ_hyp_1"),
                  width = 6,
                  height = "100%",
                  status = "primary",
                  solidHeader = TRUE
                ),
                
                
                box(
                  title = "Testing Hospital #1 Against Total Hospital Mean Bed Occupancy",
                  plotOutput("bed_occ_hyp_2"),
                  width = 6,
                  height = "100%",
                  status = "primary",
                  solidHeader = TRUE
                ))
      ),
      
      #############################################
      ###  Dashboard layout for Discharge page  ###
      #############################################
      
      tabItem(tabName = "Discharge",
              fluidRow(
                
                #Creating the first row with the following columns
                # 1. graph of trend of admissions with predictive modelling
                # 2. row for the percentage of elect v planned & top 5 most populated health boards
                
                column(6,
                       box(
                         status = "primary",
                         solidHeader = TRUE,
                         title = "Discharge Rate From 2018 to 2022",
                         #this should be static but highlighted portion shows year selected
                         plotlyOutput("delayed_bed_discharge_timeseries"),
                         width = "100%",
                         height = "100%"
                       )
                ),
                
                column(6,
                       box(
                         status = "primary",
                         solidHeader = TRUE,
                         title = "Breakdown of Reasons for Delayed Discharges",
                         plotOutput("delayed_bed_discharge_by_reason"),
                         width = "100%",
                         height = "100%"
                       )
                )
              )
      ),
      
      ################################################
      ###  Dashboard layout for Prediction Models  ###
      ################################################
      
      tabItem(tabName = "Predictive_Models",
              fluidRow(
                
                column(6,
                       box(
                         status = "primary",
                         solidHeader = TRUE,
                         title = "Admission Numbers Prediction Model with 2018 - 2019 Data",
                         plotOutput("admission_prediction_model_2018_2019"),
                         width = "100%",
                         height = "100%"
                       )
                ),
                
                column(6,
                       box(
                         status = "primary",
                         solidHeader = TRUE,
                         title = "Admission Numbers Prediction Model with 2020 - 2022 Data",
                         plotOutput("admission_prediction_model_2020_to_2022"),
                         width = "100%",
                         height = "100%"
                       )
                )
                
              ),
              fluidRow(
                
                column(6,
                       offset=3,
                       box(
                         status = "primary",
                         solidHeader = TRUE,
                         title = "Admission Numbers across Scotland Prediction Model",
                         plotOutput("delayed_dischrge_prediction_model"),
                         width = "100%",
                         height = "100%"
                       )
                ))
      )
    )
  )



sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Summary", tabName = "Summary", icon = icon("th")),
    menuItem("Admissions", icon = icon("hospital-user"), tabName = "Admissions"),
    menuItem("Occupancy", icon = icon("bed"), tabName = "Occupancy"),
    menuItem("Discharge", icon = icon("running"), tabName = "Discharge"),
    menuItem("Predictive Models", icon = icon("chart-line"), tabName = "Predictive_Models")
  ),
  
  
  
  ### Year Select Input
  dateRangeInput("date_range",
                 label = "Date range input:",
                 start = "2018/04/01",
                 end = Sys.Date(),
                 format = "dd/mm/yyyy"
  ),
  
  selectInput(
    "hospital",
    label = "Hospital:",
    choices = c(unique(location_data$location_name)),
    multiple = FALSE
  )
  
)


# Put them together into a dashboardPage
ui <- dashboardPage(
  dashboardHeader(title = "NHS Winter Crisis"),
  sidebar,
  body
)
