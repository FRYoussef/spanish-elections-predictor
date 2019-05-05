rm(list=ls())


if (!is.installed("tm")){
  install.packages("tm")
}
library(tm)
require(tm)
getwd()
setwd("C:/Users/laufu/Documents/Cuarto/Segundo cuatri/MIN/Proyecto/ElectionsPredictor-Complex_Networks")

for (day in 19:28){
  name1 <- paste(day, "csv", sep=".")
  name <- paste("datawarehouse/tweets_2019-04", name1, sep="-")
  tweets <- read.csv(name, sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
  nTweets<-length(tweets$Tweets)
  for(i in 1:nTweets){tweets[i,]$Woeid <- strtoi(tweets[i,]$Woeid, base = 0L)}
  tweets <- tweets[!is.na(tweets$Woeid),]
  nTweets<-length(tweets$Tweets)
  myCorpus<-Corpus(VectorSource(tweets$Tweets))
  #remove puntuation
  #myCorpus1<-tm_map(myCorpus,removePunctuation,ucp=TRUE)
  
  #remove capitals
  #for(i in 1:nTweets){myCorpus[[i]]$content<-tolower(myCorpus[[i]]$content)}
  myCorpus <- tm_map(myCorpus, tolower)
  #function that remove accents
  removeAccents <- content_transformer(function(x) chartr("αινσϊ", "aeiou", x))
  myCorpus <- tm_map(myCorpus, removeAccents)
  #function that remove URLs
  removeURL<-function(x)gsub("http(s)?://[[:alnum:]]*(.[[:alnum:]]*)*(/[[:alnum:]]*)*","",x) 
  myCorpus<-tm_map(myCorpus,removeURL)        
  myCorpus<-tm_map(myCorpus,removePunctuation,ucp=TRUE)
  #remove words without a lexical load
  myStopwords<-stopwords('spanish')
  myCorpus<-tm_map(myCorpus,removeWords,myStopwords)
  #eliminar caracteres raros
  removeCRT<-function(x)gsub("(<[[:alnum:]]*([[:punct:]][[:alnum:]]*)?>)*","",x)
  myCorpus<-tm_map(myCorpus,removeCRT) 
  removeRt<-function(x)gsub("rt","",x)
  myCorpus<-tm_map(myCorpus,removeRt) 
  myCorpus <-tm_map(myCorpus,removeNumbers)
  myCorpus <- tm_map(myCorpus, stripWhitespace)
  
  m=data.frame(text = sapply(myCorpus, as.character), stringsAsFactors = FALSE)
  tweets <- tweets[,"Woeid"]
  tweets<-cbind(tweets, m)
  name <- paste("datawarehouse/clean_tweets_2019-04", name1, sep="-")
  write.table(tweets, row.names = FALSE, file = name, sep = ";", fileEncoding = "UTF-8", append = FALSE)
}
