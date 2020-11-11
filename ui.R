#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("World Sustainable Emissions"),

    tabsetPanel(
        tabPanel("See country data", 
                 sidebarLayout(
                     sidebarPanel(selectInput("countries", "Select a country", as.list(unique(worldData$Country))),
                                  actionButton("action", "Show")),
                         mainPanel(
                             "This are the main sources of renewable energy consumption (measurements in Co2)",
                             plotlyOutput(outputId="sources"),
                             "Here we can see the distribution of renewable energy and total energy compsumption from 1990 to 2016",
                             plotlyOutput(outputId="distribution"),
                             
                         )
                     )
                 ),
        tabPanel("Predict data",
            sidebarLayout(
                sidebarPanel(
                    "Make sure you have selected a country in the previous tab",
                    numericInput("Energy", 
                                 p("Input energy Consumption value"), 
                                 value = 1),             
                    numericInput("Transportation", 
                                 p("Input transportation Consumption value"), 
                                 value = 1),                     
                    numericInput("Waste", 
                                 p("Input waste Consumption value"), 
                                 value = 1),                
                    numericInput("Industrial.Process", 
                                 p("Input industrial processs consumption value"), 
                                 value = 1),
                    actionButton("predict", "Predict")
   
                ),
                # Show a plot of the generated distribution
                mainPanel(
                    "With the entered values this is the prediction of the distribution of the energy consumption for the selected country, using th total for the final year in the data",
                    plotlyOutput(outputId="predicted_dist"),
                    tableOutput("tableCountry")
                )
            )
        )
    )
))
