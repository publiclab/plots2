## How to start reply by email to comment feature

With the merge of [#2669](https://github.com/publiclab/plots2/pull/2669) Public Lab now supports Reply-by-email to comment features to the various nodes. For implementing this feature we have used `mailman` gem which is a microframework for processing incoming email. More details about this can be found at [mailman](https://github.com/mailman/mailman).

[This](https://github.com/publiclab/plots2/blob/main/script/mailman_server) file contains the script for starting the mailman server. It is using POP3 (Post Office Protocol version 3) to receive emails from a remote server to a local email client. All the configurations regarding this are to be done in [mailman script](https://github.com/publiclab/plots2/blob/main/script/mailman_server). 

After configurations are done we are good to start the `mailman` server. For starting the server run the `mailman_server` script file present inside the script folder.

> ruby script/mailman_server

Above command will start the server and then the mailman server will do polling every 60 seconds(which is by default) to check for the incoming mail. However polling time can be changed by setting the value to `Mailman.config.poll_interval`(more details can be found at its' official [mailman user guide](https://github.com/mailman/mailman/blob/main/USER_GUIDE.md)). Logs for mailman can be seen in Mailman log file which is present in the `log` folder.

## Email Settings

Users can modify **Email Settings** by visiting [https://publiclab.org/settings](https://publiclab.org/settings). Settings for each user are saved by using UserTags on their profiles. 
For each setting, there is an associated tag with it. Below is the table showing associated tags with setting. 

We consider the absence of a tag as true and the presence of a tag as false for setting, so whenever a user turns **off** a setting, a corresponding user-tag is generated and turning setting **on** again will delete the tag.  
So, while notifying a user **UserTag** is checked in different files and the user is notified depending on the presence or absence of the tag.

| Email Settings | Default | User tag to override default (for turning OFF) | File where tag is used |
| ------------- | ------------- | ----------- | ----------- |
| Notification by email for comments on your posts | ON | notify-comment-direct:false | [app/models/comment.rb](https://github.com/publiclab/plots2/blob/main/app/models/comment.rb#L135) |
| Notification by email for likes on your posts | ON |notify-likes-direct:false | [app/models/node.rb](https://github.com/publiclab/plots2/blob/main/app/models/node.rb#L906) |
| Notification by email for comments on all posts you've commented on | ON | notify-comment-indirect:false | [app/models/concerns/comments_shared.rb](https://github.com/publiclab/plots2/blob/main/app/models/concerns/comments_shared.rb#L24) |


### Digest Settings

Digest settings are a part of **Email Settings** only, but they work a little differently. Digest settings also depend on UserTags. 
In case of digest settings, presence of tag marks true and absence of tag as false. There are 2 digest settings currently:  
   
| Digest Settings | User Tag |
| ------------- | ------------- |
| Do you want to receive customized digest weekly | digest:weekly |
| Do you want to receive customized digest daily | digest:daily |

A user can choose only one of the above setting i.e., weekly or daily.

**Relevant Pull Requests:** 

[https://github.com/publiclab/plots2/pull/2985](https://github.com/publiclab/plots2/pull/2985)    
[https://github.com/publiclab/plots2/pull/3119](https://github.com/publiclab/plots2/pull/3119)
