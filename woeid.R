rm(list=ls())


library(httr)
library(XML)

api_key <- "72df654b6a425b8cbb647c2095d5c209"
latitud <- "40.418888888889"
longitud <- "-3.6919444444444"
accuracy <- "11"


baseURL <- paste("https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=", api_key, sep ="")
baseURL <- paste(baseURL, "&lat=", sep="")
baseURL <- paste(baseURL, latitud, sep = "")
baseURL <- paste(baseURL, "&lon=", sep = "")
baseURL <- paste(baseURL, longitud, sep = "")
baseURL <- paste(baseURL, "&accuracy=", sep = "")
baseURL <- paste(baseURL, accuracy, sep = "")
print(baseURL)
page <-GET(baseURL)
print(page)

