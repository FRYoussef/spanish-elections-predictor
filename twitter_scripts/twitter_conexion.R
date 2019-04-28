# You have to set the workspace on the root repo path

rm(list=ls())

is.installed <- function(mypkg) {
  is.element(mypkg, installed.packages()[,1]) 
}

if (!is.installed("twitteR")){
  install.packages("twitteR")
}
library(twitteR)


consumerKey <- "vFZ7CB6wTOpZb8HmKacX5rgrE"

consumerSecret <- "cJapZyZfEu4C2uUhhZnWYO1RyAYpsqDuqknz9DjQbabV0f73Pm"

accessToken <- "1097204050679001090-Pm2XtSrI6tpCLQrJvkAYKfdyvJfRgn"

accessSecret <- "FrHQq4nbc4Rk9Y9Axjl6PhlIdHPxvNX5Gr0gF9dhBYTrU"

setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessSecret)