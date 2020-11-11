#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(caret)
library(dplyr)
library(tidyr)


loadCleanUpData <- function() {
    worldEmissionSources <- read.csv("historical_emissionsWorld.csv", stringsAsFactors = FALSE)
    WorldTotalEmissions <- read.csv("SustainableEnergyWorld.csv", stringsAsFactors = FALSE)
    
    #data cleanup
    #delete innecesary columns
    worldEmissionSources <- worldEmissionSources[-c(2,4,5)]
    WorldTotalEmissions <- WorldTotalEmissions[-c(2,4)]
    #make year a sigle column
    worldEmissionSources <- worldEmissionSources %>%
        gather(Year, Value, X2016:X1990)
    #spread the sectors
    worldEmissionSources <- worldEmissionSources %>%
        spread(Sector, Value)
    #fix names
    names(worldEmissionSources) <- make.names(names(worldEmissionSources))
    names(WorldTotalEmissions) <- c("Country", "Year", "Total.Energy.Consumption", "Renewable.Energy.Consumption")
    #remove extra X on year
    worldEmissionSources$Year = gsub("X", "",worldEmissionSources$Year)
    
    #merge datasets
    worldData <- merge(worldEmissionSources,WorldTotalEmissions, by=c("Country", "Year"))
    #only use full records
    worldData <- worldData[complete.cases(worldData),]
}

worldData <- loadCleanUpData()



shinyServer(function(input, output) {
    
    generatePrediction <- eventReactive(input$predict, {
        model <- train(Renewable.Energy.Consumption~Energy + Transportation + Waste + Industrial.Processes,
                       data=localEmissions(),
                       method="lm")
        userData <- data.frame(Energy=c(input$Energy), Transportation=c(input$Transportation), 
                               Waste=c(input$Waste), Industrial.Processes=c(input$Industrial.Process))
        data.frame(Prediction =predict(model, userData),
          Total=localEmissions()$Total.Energy.Consumption[localEmissions()$Year== tail(localEmissions()$Year,1)])
        
    })
    
    
    localEmissions <- eventReactive(input$action, {
        localEmissions <- worldData[worldData$Country==input$countries,]
        #convert to numeric
        localEmissions[(3:18)] <- sapply(localEmissions[(3:18)], as.numeric)
        #remove all incomplete data years
        localEmissions[complete.cases(localEmissions),]
    
    })
    
    
    output$sources <- renderPlotly({
        
        
        plot_ly(localEmissions(), x=~Year,y=~Energy, type="scatter", mode="lines", name="Energy") %>%
            add_trace(y=~Transportation, name="Transportation", type="scatter", mode="line") %>%
            add_trace(y=~Waste, name="Waste", type="scatter", mode="line") %>%
            add_trace(y=~Industrial.Processes, name="Industrial Processes", type="scatter", mode="line")
        
    })
    
    output$distribution <- renderPlotly({
        plot_ly(localEmissions(), labels = ~c("Renewable Energy Consumption","Total Energy Consumption"), 
                values = ~c(sum(Renewable.Energy.Consumption), 
                            sum(Total.Energy.Consumption)-sum(Renewable.Energy.Consumption)), type = 'pie')
        
        
    })
    
    output$tableCountry <- renderTable(generatePrediction())

    output$predicted_dist <- renderPlotly({
        plot_ly(generatePrediction(), labels = ~c("Renewable Energy Consumption Prediction","Total Energy Consumption"), 
                values = ~c(Prediction, 
                            Total-Prediction), type = 'pie')
        
    })
    
})



