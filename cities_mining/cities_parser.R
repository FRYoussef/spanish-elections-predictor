# Author: Youssef El Faqir El Rhazoui
# Date: 01/04/2019
# Distributed under the terms of the GPLv3 license.

rm(list=ls())

# Get csv data to join
citiesRaw <- read.table(file = "MUNICIPIOS.csv", header = TRUE, sep = ";", fileEncoding = "UTF-8")
provinceRaw <- read.table(file = "PROVINCIAS.csv", header = TRUE, sep = ";", fileEncoding = "UTF-8")

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

# Add region name to cities
region <- vector("character", nrow(cities))

for (i in 1:nrow(cities)){
  row <- provinceRaw[which(cities[i, ]$Cod_Province == provinceRaw$COD_PROV), ]
  region[i] <- row[4]
}

cities["Autonomous_Community"] <- region
cities$Cod_Province <- NULL

# Save the dataframe in a file
dir.create("../datawarehouse")
write.table(cities, row.names = FALSE, file = "../datawarehouse/cities.csv", sep = ";", 
            fileEncoding = "UTF-8")