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
    fullData <- merge(worldEmissionSources,WorldTotalEmissions, by=c("Country", "Year"))
    #only use full records
    fullData <- fullData[complete.cases(fullData),]
    fullData
}


worldData2 <- loadCleanUpData()