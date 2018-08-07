## Reply By Tweet

-  We are using [twitter gem](https://github.com/sferik/twitter "twitter gem") which implements twitter apis and gives functions to easily implement twitter apis.

### Steps:

- Cron job for polling for getting new tweets to `publiclab` is defined in [config/schedule.rb](https://github.com/publiclab/plots2/blob/master/config/schedule.rb "config/schedule.rb") using whenever gem which will call `receive_tweet` function of [models/comment.rb](https://github.com/publiclab/plots2/blob/master/app/models/comment.rb "models/comment.rb") in the interval of one minute.

- `receive_tweet` method of [models/comment.rb](https://github.com/publiclab/plots2/blob/master/app/models/comment.rb "models/comment.rb") will look for if there is any comment already present that contains tweet_id if it does it will call `receive_tweet_using_since` otherwise it will call `receive_tweet_without_using_since `.

- `receive_tweet_using_since` will search for the tweets to the `publiclab` which are tweeted after that tweet with the `tweet_id` present in the database.

- After that check if that tweet is the reply of some other tweet. If it does then find the parent tweet otherwise ignore this tweet and check next tweets untill tweets end.

- After finding parent tweet, search for the links present in the tweets in the form of `https://publiclab.org/n/_____` and find the the node_id present in `https://publiclab.org/n/node_id` if there is any node present in the database with this node_id then search for the user's email who did the tweet using the username and email data present in the hash form in the `data` column otherwise ignore this tweet.

- If that twitter username is present in the `user_tags` column  then add the tweet otherwise ignore the current tweet.

- Same process is with when there are no comment present with tweet_id in the comment table where we search for all the replied tweets to the `publiclab`.

- Set environment varible `TWEET_SEARCH` to `to:PublicLab` and `WEBSITE_HOST_PATTERN` to `://publiclab.org/n/`



