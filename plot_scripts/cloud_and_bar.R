rm(list=ls())


if (!"tm" %in% rownames(installed.packages())){
  install.packages("tm")
}
if (!"wordcloud" %in% rownames(installed.packages())){
  install.packages("wordcloud")
}
if (!"RColorBrewer" %in% rownames(installed.packages())){
  install.packages("wordcloud")
}


library(tm)
require(tm)

library(wordcloud)
require(wordcloud)

library(RColorBrewer)
require(RColorBrewer)




getwd()
setwd("C:/Users/laufu/Documents/Cuarto/Segundo cuatri/MIN/Proyecto/ElectionsPredictor-Complex_Networks")
dir <- getwd()
path_count <- "datawarehouse/raw/count_list/"
dir <- paste(dir, path_count, sep="/")
setwd(dir)
getwd()
directories <- dir()
directories <- directories[1:10]

for (directory in directories){
  files <- list.files(path=directory, pattern="*.csv", full.names=TRUE, recursive=FALSE)
  for (file in files){
    frec_words <- read.csv(file, sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
    
    frec_words <- na.omit(frec_words)
    city_result <- strsplit(file, directory)
    city_result <- strsplit(city_result[[1]][2], "/frec_terms_")
    city_result <- strsplit(city_result[[1]][2], ".csv")
    wc_file <- paste("Wordcloud", city_result[[1]], sep="_")
    wc_file <- paste(wc_file, "png", sep=".")
    #dir <- paste(path_count, directory, sep="")
    #dir <- paste(dir, wc_file, sep="/")
    setwd(directory)
    png(wc_file, width=12, height=8, units="in", res=300)
    wordcloud(words = frec_words$Word, freq = frec_words$Frec, max.words = 80, random.order = FALSE, colors=brewer.pal(8, "Dark2"))
    dev.off()
    bar_file <- paste("Bar", city_result[[1]], sep="_")
    bar_file <- paste(bar_file, "png", sep=".")
    png(bar_file, width=12, height=8, units="in", res=300)
    barplot(frec_words$Frec, las = 2, names.arg = frec_words$Word,col ="lightblue", main ="Most frequent words",ylab = "Word frequencies")
    dev.off()
    setwd(dir)
    
  }
  
}
