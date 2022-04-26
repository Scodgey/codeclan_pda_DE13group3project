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
                       box(plotOutput(
                         "map of scotland"
                       ),
                       width = NULL,
                       height = 600
                       )
                ),
                
                column(4,
                       box(
                         plotOutput("Box content here"),
                         width = NULL,
                         height = 200
                       ),
                       box(
                         plotOutput("Box content 2"),
                         width = NULL,
                         height = 200
                       ),
                       box(
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
                
                # Split this row up into three equal parts (so column is 4)
                column(4, 
                       
                       # Creating an Info box of current admission number for the quarter
                       # Default will be whole population (if can work this out)
                       infoBox(
                         "Admission numbers", # info box title
                         10 * 2, # value in info box
                         icon = icon("hospital-user"), # hospital user icon
                         color = "light-blue",
                         # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, 
                         # orange, fuchsia, purple, maroon, black
                         fill = TRUE
                       ),
                       # Dynamic infoBoxes
                       infoBoxOutput("progressBox"),
                       infoBoxOutput("approvalBox")
                )
              )
      ),
      
      #############################################
      ###  Dashboard layout for OCCUPANCY page  ###
      #############################################
      
      tabItem(tabName = "Occupancy",
              fluidRow(
                
                # Split this row up into three equal parts (so column is 4)
                column(4, 
                       
                       # Creating an Info box of current admission number for the quarter
                       # Default will be whole population (if can work this out)
                       infoBox(
                         "Admission numbers", # info box title
                         10 * 2, # value in info box
                         icon = icon("hospital-user"), # hospital user icon
                         color = "light-blue",
                         # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, 
                         # orange, fuchsia, purple, maroon, black
                         fill = TRUE
                       ),
                       # Dynamic infoBoxes
                       infoBoxOutput("progressBox"),
                       infoBoxOutput("approvalBox")
                )
              )
      ),
      
      tabItem(tabName = "Discharge",
              fluidRow(
                
                # Split this row up into three equal parts (so column is 4)
                column(4, 
                       
                       # Creating an Info box of current admission number for the quarter
                       # Default will be whole population (if can work this out)
                       infoBox(
                         "Admission numbers", # info box title
                         10 * 2, # value in info box
                         icon = icon("hospital-user"), # hospital user icon
                         color = "light-blue",
                         # red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, 
                         # orange, fuchsia, purple, maroon, black
                         fill = TRUE
                       ),
                       # Dynamic infoBoxes
                       infoBoxOutput("progressBox"),
                       infoBoxOutput("approvalBox")
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
dashboardPage(
  dashboardHeader(title = "NHS Winter Crisis"),
  sidebar,
  body
)