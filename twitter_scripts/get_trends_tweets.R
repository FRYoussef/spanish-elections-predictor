# Author: Youssef El Faqir El Rhazoui
# Date: 19/04/2019
# You have to set the workspace on the root repo path

rm(list=ls())

library(twitteR)

source ("twitter_scripts/twitter_conexion.R")

# Get cities dataframe
cities <- read.csv("datawarehouse/cities.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE)

# Let's get cities trends
city_trend <- data.frame()
trends <- data.frame()

for(i in 1:nrow(cities)){
  city_trend <- getTrends(woeid = cities[i, ]$Woeid)
  city_trend[, c("City")] <- cities[i, ]$Name
  trends <- rbind(trends, city_trend)
}

# Time to search tweets
tweets <- data.frame()

for(i in 1:nrow(trends)){
  city <- cities[which(cities$Woeid == trends[i, ]$woeid), ]
  str_geo <- paste(city$Latitude, city$Longitude, city$Radius, sep=",")
  trend_tweets <- searchTwitter(trends[i, ]$name, n=500, geocode=str_geo)
  
  if (length(trend_tweets) > 0){
    # clean response
    aux <- vector(mode="character")
    for(tweet in trend_tweets){
      aux <- c(aux, tweet$text)
    }
    
    aux <- data.frame(Tweets = aux, stringsAsFactors = FALSE)
    aux[, c("Trending")] <- trends[i, ]$name
    aux[, c("City")] <- city$name
    aux[, c("Woeid")] <- city$Woeid
    
    tweets <- rbind(tweets, aux)
  }
  sprintf("Trend %d of %d", i, nrow(trends))
}


# Save tweets and trends in a file
date <- Sys.Date()
str <- paste("datawarehouse/trends_", date, ".csv", sep="")
write.table(trends, row.names = FALSE, file = str, sep = ";", fileEncoding = "UTF-8", append = TRUE)
str <- paste("datawarehouse/tweets_", date, ".csv", sep="")
write.table(tweets, row.names = FALSE, file = str, sep = ";", fileEncoding = "UTF-8", append = TRUE)

rm(list=ls())