# You have to set the workspace on the repo root path

rm(list=ls())


if (!"tm" %in% rownames(installed.packages())){
  install.packages("tm")
}

library(tm)
require(tm)


#load the word list
path <- paste("datawarehouse", "word_list", "sentimental_wordlist.csv", sep = "/")
words <- read.csv(path, sep = ";", fileEncoding = "windows-1252", header=TRUE)
out_path <- "test"

# read training set
test <- read.csv(paste(out_path, "corpus_test.csv", sep = "/"), sep = ";", 
                        fileEncoding = "UTF-8", header=TRUE, check.names=TRUE)

#initialize data frame to save the word count per day
df <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(df) <- c("Support_PP", "Support_PSOE", "Support_Cs", "Support_Podemos", "Support_VOX")

# iterate each sentence
for(i in 1:nrow(test)){
  #form a corpus
  myCorpus <- Corpus(VectorSource(test[i, ]$text))
  myCorpus <- tm_map(myCorpus, removePunctuation)
  
  #get the terms and their frequency
  terms <- TermDocumentMatrix(myCorpus)
  matrix_terms = as.matrix(terms)
  matrix_sort <- sort(rowSums(matrix_terms),decreasing=TRUE)
  frec_terms <- data.frame(word = names(matrix_sort), freq=matrix_sort)
  length_terms <- nrow(terms)
  dff <- data.frame(
    Support_PP = 0,
    Support_PSOE = 0,
    Support_Cs = 0,
    Support_Podemos = 0,
    Support_VOX = 0
  )
  
  #initialize dataframe to save the words frecuencies
  df_frec_d <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(df_frec_d) <- c("Word", "Frec")
  
  #search for each word in the "wordList" in the dataframe of frec terms
  for (j in 1:nrow(words)){
    word <- as.String(words[j,1])
    #split the word by space 
    split_word = strsplit(word, split=" ")
    #create a dataframe with one row per simple word
    word_list = as.character(unlist(split_word))
    df_word = data.frame(word_list)
    #length of dataframe(number of simple words)
    length_word <- nrow(df_word)
    l = 1
    #row where the first word is
    row_fw <- match(df_word[1,], frec_terms$word)
    frec_old <- frec_terms[row_fw,2]
    while(length_word > 1 && l < length_word && !is.na(row_fw)){
      #find associations
      assoc <- findAssocs(terms, terms = as.String(df_word[l,]), corlimit = 0.01) 
      assoc <- data.frame(assoc)
      list_assoc <- dimnames(assoc)
      
      row_act <- match(df_word[l,], frec_terms$word)
      #get the frecuency of current word
      frec_act <- frec_terms[row_act, 2]
      #look for the next word in the list of associations and return the number of the row
      row_nw <- match(df_word[l+1,], list_assoc[[1]])
      #look for the next word in the list of frecuency and return the number of the row
      row_nw1 <- match(df_word[l+1,], frec_terms$word)
      #get the frecuency of next word
      frec_sig <- frec_terms[row_nw1, 2]
      #get the association frecuency
      frec_assoc <- assoc[row_nw,1]
      
      #calculate the frecuency of the compound word
      sqrt_x <- sqrt((length_terms * frec_act) - (frec_act)^2)
      sqrt_y <- sqrt((length_terms * frec_sig) - (frec_sig)^2)
      den <- sqrt_x * sqrt_y 
      assoc_den <- frec_assoc * den
      result <- assoc_den + (frec_act * frec_sig)
      result <- result / length_terms
      #load the result in the list of frecuency.
      frec_terms[row_fw,2] <- round(result, digits = 0)
      if(is.na(frec_assoc)){
        l <- length_word
      }
      else{
        l = l + 1
      }
      
    }
    frec <- frec_terms[row_fw,2]
    dff_frec <- data.frame(
      Word = words[j,1],
      Frec = frec
    )
    if (is.na(frec)){
      for(k in 1:ncol(dff)){
        dff[,k] = (0 * words[j,k+1]) + dff[,k]
      }
      
    }
    else{
      for(k in 1:ncol(dff)){
        dff[,k] = words[j,k+1] + dff[,k]
      }
      #reset the frequency
      frec_terms[row_fw,2]<-frec_old
    }
    #dataframe with the words and their frequency
    df_frec_d <- rbind(df_frec_d, dff_frec)
  }
  

  df <- rbind(df, dff)
}

write.table(df, row.names = FALSE, file = paste(out_path, "clasification_result.csv", sep = "/"), 
            sep = ";", fileEncoding="UTF-8") 