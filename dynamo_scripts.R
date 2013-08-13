
library(RJSONIO)
source("search.R")

#tweet.list <- tweets$statuses[[3]]
uploadTweet <- function(tweet.list, table.name, table_search_term){
  # input: single tweet in list form, will transform to json within function
  # input: table is the table name in dynamo
  time.pretty <- tweet.list$created_at
  tweet.id <- tweet.list$id_str
  author <- tweet.list$user$screen_name
  text <- gsub("'", "'\\\\''", tweet.list$text)
  text <- iconv(text, "", "ASCII", "")
  message.body <- toJSON(tweet.list)
  message.body <- gsub("'", "'\\\\''", message.body)
  message.body <- iconv(message.body, "", "ASCII", "")
  
  ret.val <- system(paste0("python upload_tweet_to_dynamo.py \'", table.name,
                           "\' \'", message.body, "\' \'", tweet.id, "\' \'",
                           text, "\' \'", author, "\' \'", time.pretty, "\' \'",
                           table_search_term, "\' "), intern=T)

} # uploadTweet(tweet.list, "cory_twitter", table_search_term)

getLastTweet <- function(table.name, search_term){
  # read the most recent message for a given search_term
  ret.val <- system(paste0("python read_last_tweet_from_dynamo.py \'",
                           table.name, "\' \'", search_term, "\'"), intern=T)
  return(ret.val)
} # getLastTweet(table.name="cory_tweets", search_term="cook_county")
