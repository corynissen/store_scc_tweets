import boto, sys

tablename = sys.argv[1]
message_body = sys.argv[2]
tweetid = sys.argv[3]
text = sys.argv[4]
author = sys.argv[5]
timestamp_pretty = sys.argv[6]
search_term = sys.argv[7]

# aws keys in /etc/boto.cfg, no need to put them here...
conn = boto.connect_dynamodb()
table = conn.get_table(tablename)
item_data = {
        'message_body': message_body,
	'text': text,
        'author': author,
        'timestamp_pretty': timestamp_pretty,
    }
item = table.new_item(hash_key=search_term, range_key=int(tweetid), 
                      attrs=item_data)
item.put()

# python write_output_to_dynamo.py 'cory_tweets' '{sample tweet here :)}' 'tweetid1' 'sample tweet here' 'cory' '12/9/2011 11:36:03 PM' 'food poisoning chicago'
