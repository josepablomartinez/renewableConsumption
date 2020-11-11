
library(shiny)
library(caret)
library(dplyr)
library(tidyr)



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
        localEmissions <- worldData2[worldData2$Country==input$countries,]
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



