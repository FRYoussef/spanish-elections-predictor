# You have to set the workspace on the root repo path

rm(list=ls())

is.installed <- function(mypkg) {
  is.element(mypkg, installed.packages()[,1]) 
}

if (!is.installed("twitteR")){
  install.packages("twitteR")
}
library(twitteR)


consumerKey <- ""

consumerSecret <- ""

accessToken <- ""

accessSecret <- ""

setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessSecret)