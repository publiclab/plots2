This documents the various steps done to parse the mails.

1.	`incoming_gmail_email.eml` is a sample incoming mail form gmail.
2.	`incoming_gmail_email.html` file containss `incoming_gmail_email.eml` converted to html
3.   Finally `final_parsed_comment.txt` contains the final parsed comment.

To parse the mails coming form gmail and to seperate the main body content and trimmed content which contains conversation thread information we have used a class `gmail_quote` which seperates the main body content and trimmed content. 

In `incoming_gmail_email.html` there is a class named `gmail_quote`, html element containing this class is the trimmed content. So to remove this we have used Nokogiri to parse html using which we have seperated the main body content and trimmed content based on class selector.
