# Author: Youssef El Faqir El Rhazoui
# Date: 01/04/2019
# You have to set the workspace on the root repo path

rm(list=ls())

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

# Let's filter cities up to 50,000 of population
cities <- cities[cities$Population >= 50000, ]


cities[, c("Autonomous_Community")] <- NA

for (i in 1:nrow(cities)){
  row <- cities[i, ]
  row <- provinceRaw[which(row$Cod_Province == provinceRaw$COD_PROV), ]
  cities[i, ]$Autonomous_Community <- row[4]
}
cities$Autonomous_Community <- vapply(cities$Autonomous_Community, paste, collapse = ", ", character(1L))
cities$Cod_Province <- NULL

# Save the dataframe in a file
dir.create("datawarehouse")
write.table(cities, row.names = FALSE, file = "datawarehouse/cities.csv", sep = ";", 
            fileEncoding = "UTF-8")