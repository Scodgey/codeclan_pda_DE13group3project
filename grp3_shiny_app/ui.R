# Read in libraries
library(shiny)
library(shinydashboard)
# Different way to create a dashboard - more fun
library(fontawesome)
# Icon list found here: https://www.angularjswiki.com/fontawesome/


# This is just the summary component of the dashboard
summary_page <- 
  dashboardPage(
  
  ### Input the agreed title of the DASHBOARD ###
  
  dashboardHeader(title = "NHS Winter Crisis"),
  
  ### Here we can format what goes in the side bar
  
  dashboardSidebar(),
  dashboardBody(
    #
    fluidRow(
      
      # Split this row up into three equal parts (so column is 4)
      column(4, 
        
        # Creating an Info box of current admission number for the quarter
        # Default will be whole population (if can work this out)
        infoBox(
          "Current Admission numbers", # info box title
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
      ),
      
      column(
        4,
        
        # 
        infoBox(
          "Current Occupancy Percentage", # info box title
          "input$occupancy_rate",  # occupancy rate but have total as deafault 
          icon = icon("bed"), # bed icon for info box
          color = "light-blue",
          fill = TRUE
          ), 
        # Dynamic infoBoxes
        infoBoxOutput("progressBox"),
        infoBoxOutput("approvalBox")
      ),
      
      column(
        4,
        
        fluidRow(
        infoBox(
          title = "Current Delayed Discharge Rate", # info box title
          "input$discharge_rate", # discharge rate but have total as default
          icon = icon("running"), # person icon for info box
          color = "light-blue",
          fill = TRUE
          ),
        # Dynamic infoBoxes
        infoBoxOutput("progressBox"),
        infoBoxOutput("approvalBox")
      ))
      
    ),
    
    fluidRow(
      column(6,
             box(plotOutput(
               "map of scotland"
             )),
             
      ),
      
      column(6,
      box(
       "Box content here", br(), "More box content",
       sliderInput("slider", "Slider input:", 1, 100, 50),
       textInput("text", "Text input:")
       )
      )
    )
  )
)
