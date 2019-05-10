# You have to set the workspace on the repo root path

rm(list=ls())

if (!"tm" %in% rownames(installed.packages())){
  install.packages("tm")
}

library(tm)
require(tm)


cities <- read.csv("datawarehouse/top10_population_cities.csv", sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
files <- list.files(path="datawarehouse/tweets_cleaned", pattern="*.csv", full.names=TRUE, recursive=FALSE)

#load the words list
words <- read.csv("datawarehouse/word_list/wordList_v2.csv", sep = ";", fileEncoding = "windows-1252", header=TRUE)

out_path <- "datawarehouse/raw/count_list"

for (file in files){
  
  clean_tweets <- read.csv(file, sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
  
  df <- data.frame(matrix(ncol = 6, nrow = 0))
  colnames(df) <- c("City", "Support_PP", "Support_PSOE", "Support_Cs", "Support_Podemos", "Support_VOX")
  
  #count words for each city.
  for(i in 1:nrow(cities)) {
    
    woeid <- cities[i, ]$Woeid
    city_name <- cities[i, ]$Name
    
    #get the data of the same woeid
    tweets_city <- subset(clean_tweets, tweets==woeid)
    
    #form a corpus with the previous data(the same woeid).
    myCorpus <- Corpus(VectorSource(tweets_city$text))
    
    #get the terms and their frequency
    terms <- TermDocumentMatrix(myCorpus)
    matrix_terms = as.matrix(terms)
    matrix_sort <- sort(rowSums(matrix_terms),decreasing=TRUE)
    frec_terms <- data.frame(word = names(matrix_sort), freq=matrix_sort)
    
    dff <- data.frame(
      City = city_name,
      Support_PP = 0,
      Support_PSOE = 0,
      Support_Cs = 0,
      Support_Podemos = 0,
      Support_VOX = 0
    )
    
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
  
  # Let's save the day "X" results
  day_results <- strsplit(file, "clean_tweets_")
  day_results <- paste("count_list", day_results[[1]][2], sep="_")
  day_results <- paste(out_path, day_results, sep="/")
  print(sprintf("Writing in: %s", day_results))
  write.table(df, row.names = FALSE, file = day_results, sep = ";", fileEncoding="UTF-8") 
}

print("Script ended")