
# This file builds a dataframe with Spain cities and its attrs.
# Finally, this dataframe is saved as a csv file.
#
# Author: Youssef El Faqir El Rhazoui
# Date: 22/03/2019
# Distributed under the terms of the GPLv3 license.

rm(list=ls())

webSource <- "https://es.wikipedia.org/wiki/Anexo:Municipios_de_España_por_población"

if (!require("devtools")) install.packages("devtools")
require(devtools)
if (!require("RHTMLForms")) install_github("omegahat/RHTMLForms")
require("RHTMLForms")
if (!require("RCurl")) install.packages("RCurl")
require(RCurl)
if (!require(XML)) install.packages("xml")
require(XML)


if(url.exists(webSource)){
  
  # Let's get the cities tables
  webPage <- getURL(webSource, ssl.verifypeer = FALSE)
  doc <- htmlParse(webPage)
  cityTables <- getNodeSet(doc, "//table")
  free(doc)
  
  # Now, time to parse the tables. The first table is the second one
  # and the last one is the 5th
  tableIndex <- 2:5
  headerNames <- c("#", "Name", "Population", "Province", "AutonomousCommunity")
  
  # Let's create an empty dataframe where store all the tables we want
  df <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(df) <- c(headerNames[2], headerNames[3], headerNames[4], headerNames[5], "Urls")
  
  tryAsInteger = function(node) {
    val = xmlValue(node)
    ans = as.integer(gsub("\\s", "", val))
    if(is.na(ans))
      val
    else
      ans
  }
  
  getUrl = function(node){
    node = node[[1]]
    size = length(node[[1]])
    href = xmlGetAttr(node, "href")
    while(size == 1){
      href = xmlGetAttr(node, "href")
      node = node[[1]]
      size = length(node[[1]])
     
    }
   href
  }
  
  for (i in tableIndex){
    table <- readHTMLTable(cityTables[[i]], header = headerNames, skip.rows = 1,
                           elFun = tryAsInteger)
    tableUrls <- readHTMLTable(cityTables[[i]], header = headerNames, skip.rows = 1,
                            elFun = getUrl)
    dff <- data.frame(
      Name = as.vector(table$Name),
      Population = as.vector(table$Population),
      Province = as.vector(table$Province),
      # TODO there's a bug which duplicates this record
      AutonomousCommunity = as.vector(table$AutonomousCommunity),
      Urls = as.vector(tableUrls$Name)
    )
    
    df <- rbind(df, dff)
  }
  
  ############## Laura's code ######################
  # TODO Append as cols the geo location in the df
  #
  ##################################################
  cityUrl = as.vector(df[, "Urls"])
  
  dfCoordinates <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(dfCoordinates) <- c("Latitude", "Longitude")
  

  
  for (i in 1:length(cityUrl)){
    webPageCity <-  paste("https://es.wikipedia.org", cityUrl[i], sep = "/")
    if(url.exists(webPageCity)) 
    {
      theWebPage <- getURL(webPageCity, ssl.verifypeer = FALSE)
      theParsedWebPage <- htmlParse(theWebPage)
      coordinates <- getNodeSet(theParsedWebPage, "//span[@id='coordinates']/span/a/span[@class='geo-nondefault']/span/span/span")
      free(theParsedWebPage)
      latitude = xmlValue(coordinates[[1]])
      longitude = xmlValue(coordinates[[2]])
      latitude = gsub(", $", "", latitude)
      coordinates <- data.frame(
        Latitude = as.vector(latitude),
        Longitude = as.vector(longitude)
      )
      dfCoordinates <- rbind(dfCoordinates, coordinates)
    }
  }
  df <- cbind(df, dfCoordinates)
  
  
  # Store the df as csv
  write.table(df, row.names = FALSE, append = TRUE, file = "datawarehouse/cities.csv", sep = ";",
              fileEncoding="UTF-8")
  
} else {
  sprintf("The url: %s is not avaliable", webSource)
}
