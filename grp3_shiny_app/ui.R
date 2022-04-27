# Read in libraries
library(shiny)
library(shinydashboard)
# Different way to create a dashboard - more fun
library(fontawesome)
# Icon list found here: https://www.angularjswiki.com/fontawesome/
library(plotly)


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
                           "A&E Targets by Hospital",
                           plotOutput("box 1 plot"),
                           width = NULL,
                           height = "100%"
                         ),
                         
                         tabPanel(
                           "Bed Occupancy by Hospital",
                           plotOutput("top_occupancy_hospitals"),
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
                
                #Creating the first row with the following columns
                # 1. graph of trend of admissions with predictive modelling
                # 2. row for the percentage of elect v planned & top 5 most populated health boards
                
                column(8,
                       box(
                         color = "blue",
                         solidHeader = TRUE,
                         title = "Admissions predictive model",
                         #this should be static but highlighted portion shows year selected
                          plotOutput("predicted graph of admissions"),
                          width = NULL
                       )
                ),
                
                column(4,
                       box(
                         title = "Percentage of Emergency v Planned",
                         plotOutput("Admission Emergency v Planned"),
                         width = NULL,
                         height = 100
                       ),
                       box(
                         title = "Health Boards with Most Admissions",
                         plotOutput("input$healthboard"),
                         width = NULL,
                         height = 300
                       )
                )
              ),
              
              #Creating the second row with the following columns
              # 1. age graph - that changes on year and health baord selected
              # 2. box plot of gender
              # 3. graph of smid score
              
              fluidRow(
                
                box(
                  title = "Age",
                  plotOutput("age_ranges_admissions"),
                  width = 4,
                  height = 300
                ),
                box(
                  title = "Gender",
                  plotOutput("gender_diff_admissions"),
                  width = 4,
                  height = 300
                ),
                
                box(
                  title = "Deprivation",
                  plotOutput("smid_score_admissions"),
                  width = 4,
                  height = 300
                )
              )
      ),
      
      #############################################
      ###  Dashboard layout for OCCUPANCY page  ###
      #############################################
      
      tabItem(tabName = "Occupancy",
              fluidRow(
                
                #Creating the first row with the following columns
                # 1. graph of trend of admissions with predictive modelling
                # 2. row for the percentage of elect v planned & top 5 most populated health boards
                
                column(8,
                       box(
                         title = "Occupancy predictive model",
                         #this should be static but highlighted portion shows year selected
                         plotOutput("predicted graph of occupancy"),
                         width = NULL
                       )
                ),
                
                column(4,
                       box(
                         title = "Percentage of Emergency v Planned",
                         plotOutput("Occupancy Emergency v Planned"),
                         width = NULL,
                         height = 100
                       ),
                       box(
                         title = "Health Boards with Most Occupancy",
                         plotOutput("healthboard"),
                         width = NULL,
                         height = 300
                       )
                )
              ),
              
              #Creating the second row with the following columns
              # 1. age graph - that changes on year and health baord selected
              # 2. box plot of gender
              # 3. graph of smid score
              
              fluidRow(
                
                box(
                  title = "Age",
                  plotOutput("age_ranges_occupancy"),
                  width = 4,
                  height = 300
                ),
                box(
                  title = "Gender",
                  plotOutput("gender_diff_occupancy"),
                  width = 4,
                  height = 300
                ),
                
                box(
                  title = "Deprivation",
                  plotOutput("smid_score_occupancy"),
                  width = 4,
                  height = 300
                )
              )
      ),
      
      #############################################
      ###  Dashboard layout for Discharge page  ###
      #############################################
      
      tabItem(tabName = "Discharge",
              fluidRow(
                
                #Creating the first row with the following columns
                # 1. graph of trend of admissions with predictive modelling
                # 2. row for the percentage of elect v planned & top 5 most populated health boards
                
                column(8,
                       box(
                         title = "Discharge predictive model",
                         #this should be static but highlighted portion shows year selected
                         plotOutput("predicted graph of dsicharge"),
                         width = NULL
                       )
                ),
                
                column(4,
                       box(
                         title = "Percentage of Emergency v Planned",
                         plotOutput("discharge Emergency v Planned"),
                         width = NULL,
                         height = 100
                       ),
                       box(
                         title = "Health Boards with Most Discharge",
                         plotOutput("healthboard_discharge"),
                         width = NULL,
                         height = 300
                       )
                )
              ),
              
              #Creating the second row with the following columns
              # 1. age graph - that changes on year and health baord selected
              # 2. box plot of gender
              # 3. graph of smid score
              
              fluidRow(
                
                box(
                  title = "Age",
                  plotOutput("age_ranges_discharge"),
                  width = 4,
                  height = 300
                ),
                box(
                  title = "Gender Box Plot",
                  plotOutput("gender_diff_discharge"),
                  width = 4,
                  height = 300
                ),
                
                box(
                  title = "Deprivation",
                  plotOutput("smid_score_discharge"),
                  width = 4,
                  height = 300
                )
              )
      )
      
    )
  )



sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Summary", tabName = "Summary", icon = icon("th")),
    menuItem("Admissions", icon = icon("hospital-user"), tabName = "Admissions"),
    menuItem("Occupancy", icon = icon("bed"), tabName = "Occupancy"),
    menuItem("Discharge", icon = icon("running"), tabName = "Discharge")
  ),
  
  
  ### Health Board Select Input
  ### Not needed anymore
  
  # selectInput("selected_healthboard",
  #              "Health Board:",
  #             selected = "Please Select:",
  #              choices = c("Please Select:" = TRUE,
  #                         "Ayreshire and Arran" = "S08000015",
  #                         "Borders" = "S08000016",
  #                         "Dumfries and Galloway"  ="S08000017",
  #                         "Fife" = "S08000029",
  #                         "Forth Valley" = "S08000019",
  #                         "Grampian" = "S08000020",
  #                         "Greater Glasgow & Clyde" = "S08000031",
  #                         "Highland" = "S08000022",
  #                         "Lanarkshire" = "S08000032",
  #                         "Lothian" = "S08000024",
  #                         "Orkney" = "S08000025",
  #                         "Shetland" = "S08000026",
  #                         "Tayside" = "S08000030",
  #                         "Western Isles" = "S08000028"
  #                          )
  # ),
  
  
  ### Year Select Input
  ## when using will have to use as.date or something to work
  
  
  dateRangeInput("date_range",
    label = "Date range input:",
    start = "2018/04/01",
    end = Sys.Date(),
    format = "dd/mm/yyyy"
  )
  
)


# Put them together into a dashboardPage
ui <- dashboardPage(
  dashboardHeader(title = "NHS Winter Crisis"),
  sidebar,
  body
)