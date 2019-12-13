This documents the various steps done to parse mail from Outlook.

1.	`incoming_outlook_email.eml` is a sample incoming mail from Outlook.
2.	`incoming_yahoo_email.html` file contains `incoming_outlook_email.eml` converted to html
3.   Finally `final_parsed_comment.txt` contains the final parsed comment.

To parse the mails coming from Outlook and to separate the main body content and trimmed content which contains conversation thread information we have used a `div` element with id `appendonsend` (`<div id="appendonsend"></div>`).

As seen in `incoming_outlook_email.html`, this `div` html element separates the email body from the quoted content. So we have used Regex to retrieve these section before, which becomes the comment content, and the section after, which becomes the trimmed content.