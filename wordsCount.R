rm(list=ls())


if (!is.installed("tm")){
  install.packages("tm")
}
library(tm)
require(tm)


tweets <- read.csv("datawarehouse/tweets_2019-04-19.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
nTweets<-length(tweets$Tweets)
for(i in 1:nTweets){tweets[i,]$Woeid <- strtoi(tweets[i,]$Woeid, base = 0L)}
tweets <- tweets[!is.na(tweets$Woeid),]
nTweets<-length(tweets$Tweets)
myCorpus<-Corpus(VectorSource(tweets$Tweets))
#remove puntuation
#myCorpus1<-tm_map(myCorpus,removePunctuation,ucp=TRUE)

#remove capitals
for(i in 1:nTweets){myCorpus[[i]]$content<-tolower(myCorpus[[i]]$content)}
#function that remove accents
removeAccents <- content_transformer(function(x) chartr("áéíóú", "aeiou", x))
myCorpus <- tm_map(myCorpus, removeAccents)
#function that remove URLs
removeURL<-function(x)gsub("http(s)?://[[:alnum:]]*(.[[:alnum:]]*)*(/[[:alnum:]]*)*","",x) 
myCorpus<-tm_map(myCorpus,removeURL)        
myCorpus<-tm_map(myCorpus,removePunctuation,ucp=TRUE)
#remove words without a lexical load
myStopwords<-stopwords('spanish')
myCorpus<-tm_map(myCorpus,removeWords,myStopwords)

m=data.frame(text = sapply(myCorpus, as.character), stringsAsFactors = FALSE)
tweets<-cbind(tweets, m)
#load the words list
words <- read.csv("datawarehouse/wordsList_v2.csv", sep = ";", fileEncoding = "windows-1252", header=TRUE)
print(tweets[2,])
#filter into dataframe
r <- grep("espana", words$Palabra, ignore.case=TRUE)
print(r)
words1 <- words[r,]
