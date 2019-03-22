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
  df <- data.frame(matrix(ncol = 4, nrow = 0))
  colnames(df) <- c(headerNames[2], headerNames[3], headerNames[4], headerNames[5])
  
  tryAsInteger = function(node) {
    val = xmlValue(node)
    ans = as.integer(gsub("\\s", "", val))
    if(is.na(ans))
      val
    else
      ans
  }

  for (i in tableIndex){
    table <- readHTMLTable(cityTables[[i]], header = headerNames, skip.rows = 1,
                           elFun = tryAsInteger)
    dff <- data.frame(
      Name = as.vector(table$Name),
      Population = as.vector(table$Population),
      Province = as.vector(table$Province),
      # TODO there's a bug which duplicates this record
      AutonomousCommunity = as.vector(table$AutonomousCommunity)
    )
    
    df <- rbind(df, dff)
  }
  
  ############## Laura's code ######################
  # TODO Append as cols the geo location in the df
  #
  ##################################################
  
  # Store the df as csv
  write.table(df, row.names = FALSE, file = "datawarehouse/cities.csv", sep = ";",
              fileEncoding="UTF-8")
  
} else {
  sprintf("The url: %s is not avaliable", webSource)
}