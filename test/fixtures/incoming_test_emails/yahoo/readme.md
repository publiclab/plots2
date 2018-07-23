This documents the various steps done to parse the mails.

1.	`incoming_yahoo_email.eml` is a sample incoming mail form yahoo.
2.	`incoming_yahoo_email.html` file containss `incoming_yahoo_email.eml` converted to html
3.   Finally `final_parsed_comment.txt` contains the final parsed comment.

To parse the mails coming form yahoo and to seperate the main body content and trimmed content which contains conversation thread information we have used a class `yahoo_quoted` which seperates the main body content and trimmed content. 

In `incoming_yahoo_email.html` there is a class named `yahoo_quoted`, html element containing this class is the trimmed content. So to remove this we have used Nokogiri to parse html using which we have seperated the main body content and trimmed content based on class selector.
