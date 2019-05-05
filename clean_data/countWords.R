rm(list=ls())

if (!is.installed("tm")){
  install.packages("tm")
}

library(tm)
require(tm)
getwd()
setwd("C:/Users/laufu/Documents/Cuarto/Segundo cuatri/MIN/Proyecto/ElectionsPredictor-Complex_Networks")


cities <- read.csv("datawarehouse/cities.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
#load the words list
words <- read.csv("datawarehouse/wordsList_v2.csv", sep = ";", fileEncoding = "windows-1252", header=TRUE)
def <- data.frame(matrix(ncol = 6, nrow = 0))
colnames(def) <- c("City", "Support_PP", "Support_PSOE", "Support_Cs", "Support_Podemos", "Support_VOX")
for (day in 19:28){
  name1 <- paste(day, "csv", sep=".")
  name <- paste("datawarehouse/clean_tweets_2019-04", name1, sep="-")
  clean_tweets <- read.csv(name, sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
  df <- data.frame(matrix(ncol = 6, nrow = 0))
  colnames(df) <- c("City", "Support_PP", "Support_PSOE", "Support_Cs", "Support_Podemos", "Support_VOX")
  #count words for each city.
  for(i in 1:10){
    woeid <- cities[i,]$Woeid
    citie <- cities[i,]$Name
    #get the data of the same woeid
    tweets_citie <- subset(clean_tweets, tweets==woeid)
    #form a corpus with the previous data(the same woeid).
    myCorpus<-Corpus(VectorSource(tweets_citie$text))
    #get the terms and their frequency
    terms <- TermDocumentMatrix(myCorpus)
    matrix_terms = as.matrix(terms)
    matrix_sort <- sort(rowSums(matrix_terms),decreasing=TRUE)
    frec_terms <- data.frame(word = names(matrix_sort), freq=matrix_sort)
    dff <- data.frame(
      City = citie,
      Support_PP = 0,
      Support_PSOE = 0,
      Support_Cs = 0,
      Support_Podemos = 0,
      Support_VOX = 0
    )
    #initialize definitive data frame
    if(day == 19){
      def <- rbind(def, dff)
    }
    #search for each word in the "wordList" in the dataframe of frec terms
    for (j in 1:nrow(words)){
      r <- match(words[j,1], frec_terms$word)
      frec <- frec_terms[r,2]
      if (is.na(frec)){
        for(k in 2:6){
          dff[,k] = (0 * words[j,k])+dff[,k]
        }
      
      }
      else{
        for(k in 2:6){
          dff[,k] = words[j,k]+dff[,k]
        }
      }
    }

    df <- rbind(df, dff)
  }
  #update the definitive dataframe with the data for each day
  for(k in 2:6){
    def[,k] = def[,k]+df[,k]
  }

}
write.table(def, row.names = FALSE, append = FALSE, file = "datawarehouse/count_list.csv", sep = ";",
            fileEncoding="UTF-8")

