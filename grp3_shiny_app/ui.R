# Read in libraries
library(shiny)
library(shinydashboard)
# Different way to create a dashboard - more fun
library(fontawesome)
# Icon list found here: https://www.angularjswiki.com/fontawesome/



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
                  "input$admission_rate", # value in info box
                  icon = icon("hospital-user"), # hospital user icon
                  color = "light-blue",
                  # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, 
                  # orange, fuchsia, purple, maroon, black
                  fill = TRUE
                ),
                # Dynamic infoBoxes
                infoBox(
                  "Current Occupancy Percentage", # info box title
                  "input$occupancy_rate",  # occupancy rate but have total as deafault 
                  icon = icon("bed"), # bed icon for info box
                  color = "light-blue",
                  fill = TRUE
                ),
                infoBox(
                  title = "Current Delayed Discharge Rate", # info box title
                  "input$discharge_rate", # discharge rate but have total as default
                  icon = icon("running"), # person icon for info box
                  color = "light-blue",
                  fill = TRUE
                )
              ),
              
              
              fluidRow(
                column(8,
                       box(
                         status = "primary", # allows header to be coloured
                         title = "Health Boards across Scotland",
                         solidHeader = TRUE,
                         plotlyOutput(
                           scottish_health_boards
                         ),
                         width = NULL,
                         height = 600
                       )
                ),
                
                column(4,
                       box(
                         title = "Health Boards with Highest Admission Rates",
                         plotOutput("box 1 plot"),
                         width = NULL,
                         height = 200
                       ),
                       box(
                         title = "Hospitals with Highest Occupancy Rates",
                         plotOutput("output$top_occupancy_hospitals"),
                         width = NULL,
                         height = 200
                       ),
                       box(
                         title = "Hospitals with Highest Discharge Rates",
                         plotOutput("Box content 3"),
                         width = NULL,
                         height = 200
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
  )
)


# Put them together into a dashboardPage
ui <- dashboardPage(
  dashboardHeader(title = "NHS Winter Crisis"),
  sidebar,
  body
)