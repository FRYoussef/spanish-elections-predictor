# Author: Youssef El Faqir El Rhazoui
# Date: 19/04/2019
# You have to set the workspace on the root repo path

rm(list=ls())

library(twitteR)

source ("twitter_scripts/twitter_conexion.R")

# Get cities dataframe
cities <- read.csv("datawarehouse/cities.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE)

# Check if already have trends
date <- Sys.Date()
str <- paste("datawarehouse/trends_", date, ".csv", sep="")
previous_trends <- data.frame()
if (file.exists(str)) {
  previous_trends <- read.csv(str, sep = ";", fileEncoding = "UTF-8", header=TRUE)
  print(sprintf("'%s' already exist, appending new trends...", str))
}

# Let's get cities trends
city_trend <- data.frame()
trends <- data.frame()

for(i in 1:nrow(cities)){
  city_trend <- getTrends(woeid = cities[i, ]$Woeid)
  city_trend[, c("City")] <- cities[i, ]$Name
  
  # if there are previous trends, we'll fliter news
  if(nrow(previous_trends) > 0) {
    filter_ <- data.frame()
    for(j in 1:nrow(city_trend)) {
      prev_cities <- previous_trends[previous_trends$woeid == city_trend$woeid, ]
      if(! city_trend[j, ]$name %in% prev_cities$name ) {
          filter_ <- rbind(filter_, city_trend[j, ])
      }
    }
    city_trend <- filter_
  }
  
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
    aux[, c("City")] <- city$Name
    aux[, c("Woeid")] <- city$Woeid

    tweets <- rbind(tweets, aux)
  }
  print(sprintf("Collected %d tweets from %d/%d trends", nrow(trend_tweets), i, nrow(trends)))
}


# Save tweets and trends in a file
write.table(trends, row.names = FALSE, file = str, sep = ";", fileEncoding = "UTF-8", append = TRUE)
str <- paste("datawarehouse/tweets_", date, ".csv", sep="")
write.table(tweets, row.names = FALSE, file = str, sep = ";", fileEncoding = "UTF-8", append = TRUE)