rm(list=ls())

if (!is.installed("tm")){
  install.packages("tm")
}

library(tm)
require(tm)
getwd()
setwd("C:/Users/laufu/Documents/Cuarto/Segundo cuatri/MIN/Proyecto/ElectionsPredictor-Complex_Networks")

clean_tweets <- read.csv("datawarehouse/clean_tweets_2019-04-19.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
cities <- read.csv("datawarehouse/cities.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
#load the words list
words <- read.csv("datawarehouse/wordsList_v2.csv", sep = ";", fileEncoding = "windows-1252", header=TRUE)
for(i in 1:1){
  woeid <- cities[i,]$Woeid
  citie <- cities[i,]$Name
  tweets_citie <- subset(clean_tweets, tweets==woeid)
  myCorpus<-Corpus(VectorSource(tweets_citie$text))
  terms <- TermDocumentMatrix(myCorpus)
  matrix_terms = as.matrix(terms)
  matrix_sort <- sort(rowSums(matrix_terms),decreasing=TRUE)
  frec_terms <- data.frame(word = names(matrix_sort), freq=matrix_sort)
}

