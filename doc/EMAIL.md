## How to start reply by email to comment feature

With the merge of [#2669](https://github.com/publiclab/plots2/pull/2669) Public lab now supports Reply-by-email to comment features to the various nodes. For implementing this feature we have used `mailman` gem which is a microframework for processing incoming email. More details about this can be found at [mailman](https://github.com/mailman/mailman).

[This](https://github.com/publiclab/plots2/blob/master/script/mailman_server) file contains the script for starting the mailman server. It is using POP3 (Post Office Protocol version 3) to receive emails from a remote server to a local email client. All the configrations regarding this is to be done in [mailman script](https://github.com/publiclab/plots2/blob/master/script/mailman_server). 

After configurations are done we are good to start the `mailman` server. For starting the server run the `mailman_server` script file present inside script folder.

> ruby script/mailman_server

Above command will start the server and then the mailman server will do polling in every 60 seconds(which is by default) to check for the incoming mail. However polling time can be changed by setting value to `Mailman.config.poll_interval`(more details can be found at its official [mailman user guide](https://github.com/mailman/mailman/blob/master/USER_GUIDE.md)). Logs for mailman can be seen oin Mailman log file which is present in `log` folder.