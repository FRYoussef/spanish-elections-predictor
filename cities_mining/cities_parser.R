# Author: Youssef El Faqir El Rhazoui
# Date: 01/04/2019
# You have to set the workspace on the repo root path

rm(list=ls())

library(twitteR)

source ("twitter_scripts/twitter_conexion.R")

# Get csv data to join
citiesRaw <- read.table(file = "cities_mining/MUNICIPIOS.csv", header = TRUE, sep = ";", fileEncoding = "UTF-8")
provinceRaw <- read.table(file = "cities_mining/PROVINCIAS.csv", header = TRUE, sep = ";", fileEncoding = "UTF-8")

# Let's clean the dataframes
cities <- data.frame(
  Cod_Province = citiesRaw$COD_PROV,
  Province = citiesRaw$PROVINCIA,
  Name = citiesRaw$NOMBRE_ACTUAL,
  Population = citiesRaw$POBLACION_MUNI,
  Longitude = citiesRaw$LONGITUD_ETRS89,
  Latitude = citiesRaw$LATITUD_ETRS89
)
rm(citiesRaw)

# Let's filter cities up to 340,000 of population
# Only big cities will give us trends
cities <- cities[cities$Population >= 340000, ]


# let's add the community name
cities[, c("Autonomous_Community")] <- NA

for (i in 1:nrow(cities)){
  row <- cities[i, ]
  row <- provinceRaw[which(row$Cod_Province == provinceRaw$COD_PROV), ]
  cities[i, ]$Autonomous_Community <- row[4]
}
cities$Autonomous_Community <- vapply(cities$Autonomous_Community, paste, collapse = ", ", character(1L))
cities$Cod_Province <- NULL


# Now, we are going to send requests to Twitter to find the woeid
cities[, c("Woeid")] <- NA
for (i in 1:nrow(cities)){
  cities[i, ]$Woeid <- closestTrendLocations(lat = cities[i, ]$Latitude, long = cities[i, ]$Longitude)$woeid
} 

#Radius for top 10 (population) cities
cities <- cities[with(cities, order(Population)), ]
cities[, c("Radius")] <- c("60km", "130km", "150km", "40km", "40km", "100km", "45km", "60km", "140km", "40km")


# Save the dataframe in a file
dir.create("datawarehouse")
write.table(cities, row.names = FALSE, file = "datawarehouse/top10_population_cities.csv", sep = ";", 
            fileEncoding = "UTF-8")