# You have to set the workspace on the root repo path

rm(list=ls())

is.installed <- function(mypkg) {
  is.element(mypkg, installed.packages()[,1]) 
}

if (!is.installed("twitteR")){
  install.packages("twitteR")
}
library(twitteR)


consumerKey <- "9wqUbq3u3ZgBq0ImLvTTuRbzr"

consumerSecret <- "tbGNaYl7JiCHd2O0nGbu4dXZQGkcGgjnx0XSgT4QHShXejpjSD"

accessToken <- "1095974486179004416-PFsOuHQ5XfVrw7ve3JSSqtDG3tUYoy"

accessSecret <- "hAg6VlYOzdibhtx3rLqdLYGk2SU7cJ4riuMRTdNE2wINX"

setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessSecret)