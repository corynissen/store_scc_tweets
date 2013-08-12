
library(RJSONIO)
source("search.R")

table_name <- "cory_tweets"
search_term <- "cook_county"

#tweet.list <- tweets$statuses[[3]]
uploadTweet <- function(tweet.list, table.name, search_term){
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
                           search_term, "\' "), intern=T)

} # uploadTweet(tweet.list, "cory_twitter", search_term)

getLastTweet <- function(table.name, search_term){
  # read the most recent message for a given search_term
  ret.val <- system(paste0("python read_last_tweet_from_dynamo.py \'",
                           table.name, "\' \'", search_term, "\'"), intern=T)
  return(ret.val)
} # getLastTweet(table.name="cory_tweets", search_term="cook_county")


################################################################################
# Run here...

# what this is supposed to do...
# 1. query dynamodb for the most recent tweetid with the hash_key of search_term
# 2. query twitter with a sinceid that was returned from the last step
# 3. upload the new tweets to dynamo

# step #1
tweetid.query <- getLastTweet(table_name, search_term)
if(grepl("u'Count': 1", tweetid.query)){
  # get last.tweetid, use grep instead of fromJSON so we don't have to worry
  # about malformed JSON
  last.tweetid <- substring(tweetid.query,
                            regexpr("'RangeKeyElement':", tweetid.query))
  last.tweetid <- substring(last.tweetid, regexpr(":", last.tweetid)+2,
                            regexpr(",", last.tweetid)-1)
}else{
  last.tweetid <- ""
}

# step #2
tweets.json <- twitter_search(term="cook county", count=100, 
                              geocode="41.8607,-87.6408,30mi",
                              since_id=last.tweetid)
tweets <- fromJSON(tweets.json, asText=TRUE)
# step #3
lapply(tweets$statuses, function(x)uploadTweet(x, "cory_tweets", search_term))
