library(plotly)
library(shiny)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("World Sustainable Emissions"),

    tabsetPanel(
        tabPanel("See country data", 
                 sidebarLayout(
                     sidebarPanel(selectInput("countries", "Select a country", as.list(unique(worldData2$Country))),
                                  actionButton("action", "Show")),
                         mainPanel(
                             h3("In this tap you can historical information (from 1990 to 2016) about the use of renewable energy in each country"),
                             h3("Select a country in the control on the left to see its information"),
                             p(""),
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
                    h2("Make sure you have selected a country in the previous tab"),
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
