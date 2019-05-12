# You have to set the workspace on the repo root path

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
if (!"zoo" %in% rownames(installed.packages())){
  install.packages("zoo")
}


library(tm)
require(tm)

library(wordcloud)
require(wordcloud)

library(RColorBrewer)
require(RColorBrewer)

library(zoo)
require(zoo)




getwd()
setwd("C:/Users/laufu/Documents/Cuarto/Segundo cuatri/MIN/Proyecto/ElectionsPredictor-Complex_Networks")
words <- read.csv("datawarehouse/word_list/wordList_v2.csv", sep = ";", fileEncoding = "windows-1252", header=TRUE)
length_list <- nrow(words)
dir <- getwd()
path_count <- "datawarehouse/raw/count_list/"
dir <- paste(dir, path_count, sep="/")
setwd(dir)
getwd()
directories <- dir()
directories <- directories[1:10]


for (directory in directories){
  files <- list.files(path=directory, pattern="*.csv", full.names=TRUE, recursive=FALSE)
  df <- data.frame(matrix(ncol = 2, nrow = length_list))
  colnames(df) <- c("Word", "Frec")
  df$Word = words$Palabra
  df$Frec = 0
  for (file in files){
    frec_words <- read.csv(file, sep = ";", fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)
    frec_words$Frec <- na.fill(frec_words$Frec, fill=0)
    df$Frec = df$Frec + frec_words$Frec

  }

  df <- na.omit(df)
  wc_file <- paste("Wordcloud", directory, sep="_")
  wc_file <- paste(wc_file, "png", sep=".")
  setwd(directory)
  png(wc_file, width=12, height=8, units="in", res=300)
  wordcloud(words = df$Word, freq = df$Frec, max.words = 80, random.order = FALSE, colors=brewer.pal(8, "Dark2"))
  dev.off()
  bar_file <- paste("Bar", directory, sep="_")
  bar_file <- paste(bar_file, "png", sep=".")
  png(bar_file, width=12, height=8, units="in", res=300)
  df_bar <- df[df$Frec > 100,]
  barplot(df_bar$Frec, las = 2, names.arg = df_bar$Word,col ="lightblue", main ="Most frequent words",ylab = "Word frequencies")
  dev.off()
  setwd(dir)
  
}
