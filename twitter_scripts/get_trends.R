library(httr)
library(XML)
install.packages("httpuv")
library(httpuv)
install.packages("dplyr") # Instalar de manipulación de dataframes "dplyr"
library(dplyr)
library(twitteR)


source ("twitter_scripts/twitter_conexion.R")

#print(closestTrendLocations(lat = "41.65", long = "-0.87"))
#print(getTrends(woeid = 779063, exclude=NULL))
#print(searchTwitter('#DebateARV', n=500, geocode='41.65,-0.87,500km'))


available_trends <- availableTrendLocations()
available_trends <- filter(available_trends, country == "Spain")



date <- Sys.Date()


df <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(df) <- c("Name", "Url", "Query", "Woeid")

available_trends = as.vector(available_trends[, "woeid"])
for (i in 1: length(available_trends)){
  woeid <- available_trends[i]
  trends <- getTrends(woeid)
  dff <- data.frame(
    Name = as.vector(trends$name),
    Url = as.vector(trends$url),
    Query = as.vector(trends$query),
    # TODO there's a bug which duplicates this record
    Woeid = as.vector(trends$woeid)
  )
  
  df <- rbind(df, dff)


}

name <- paste("datawarehouse/",date)

write.table(df, row.names = FALSE, append = TRUE, file = name, sep = ";",
            fileEncoding="UTF-8")

twit <- searchTwitter("#ALasTresSonLasDos", geocode='43.533333333333,-5.7,10km')
twit <- searchTwitter("#JuegoDeTronosEnVodafone", geocode='39.466666666667,-0.375,10km')

print(twit)

