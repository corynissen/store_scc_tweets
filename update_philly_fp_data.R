
source("dynamo_scripts.R")

table_name <- "cory_tweets"
table_search_term <- "philadelphia_fp"
search_term <- "food poisoning"
geocode <- "39.9929,-75.1018,12mi"

################################################################################
# Run here...

# what this is supposed to do...
# 1. query dynamodb for the most recent tweetid with the hash_key of search_term
# 2. query twitter with a sinceid that was returned from the last step
# 3. upload the new tweets to dynamo

# step #1
tweetid.query <- getLastTweet(table_name, table_search_term)
if(grepl("'Count': 1", tweetid.query)){
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
tweets.json <- twitter_search(term=search_term, count=100, geocode=geocode,
                              since_id=last.tweetid)
tweets <- fromJSON(tweets.json, asText=TRUE)
# step #3
lapply(tweets$statuses, function(x)uploadTweet(x, table_name, table_search_term))
