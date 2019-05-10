# You have to set the workspace on the repo root path

rm(list=ls())

if (!"tm" %in% rownames(installed.packages())){
  install.packages("tm")
}

library(tm)
require(tm)

files <- list.files(path="datawarehouse/raw/tweets", pattern="*.csv", full.names=TRUE, recursive=FALSE)

for (file in files){
  
  tweets <- read.csv(file, sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
  nTweets<-length(tweets$Tweets)
  
  for(i in 1:nTweets){
    tweets[i,]$Woeid <- strtoi(tweets[i,]$Woeid, base = 0L)
  }
  
  tweets <- tweets[!is.na(tweets$Woeid),]
  nTweets<-length(tweets$Tweets)
  myCorpus<-Corpus(VectorSource(tweets$Tweets))
  
  #remove puntuation
  #myCorpus1<-tm_map(myCorpus,removePunctuation,ucp=TRUE)
  
  #remove capitals
  #for(i in 1:nTweets){myCorpus[[i]]$content<-tolower(myCorpus[[i]]$content)}
  myCorpus <- tm_map(myCorpus, tolower)
  
  #function that remove accents, file encode changes the str
  removeAccents <- content_transformer(function(x) chartr("�����", "aeiou", x))
  myCorpus <- tm_map(myCorpus, removeAccents)
  
  #function that remove URLs
  removeURL<-function(x)gsub("http(s)?://[[:alnum:]]*(.[[:alnum:]]*)*(/[[:alnum:]]*)*","",x) 
  myCorpus<-tm_map(myCorpus,removeURL)        
  myCorpus<-tm_map(myCorpus,removePunctuation,ucp=TRUE)
  
  #remove words without a lexical load
  #myStopwords<-stopwords('spanish')
  #myCorpus<-tm_map(myCorpus,removeWords,myStopwords)
  
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
  
  clean_corpus <- strsplit(file, "tweets_")
  clean_corpus <- paste("clean_tweets", clean_corpus[[1]][2], sep="_")
  clean_corpus <- paste("datawarehouse/tweets_cleaned", clean_corpus, sep="/")
  
  print(sprintf("Writing in: %s", clean_corpus))
  write.table(tweets, row.names = FALSE, file = clean_corpus, sep = ";", fileEncoding = "UTF-8")
}

print("Script ended")
