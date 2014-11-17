PublicLab.org
======

A complete rewrite of the Public Lab website on a new platform, with a whole new look. Rails, Bootstrap; intended to:

* boast more usable, friendly, but also more powerful interfaces
* simplify and refine common tasks like posting research notes and filtering spam
* enable faster development (based on Ruby on Rails and Twitter's Bootstrap frameworks)
* completely revise and streamline "following" other contributors or specific keywords, with email alerts
work on tablets, smartphones, and in recent versions of Internet Explorer

###Key new features:

* new simpler/faster note posting form
* vastly improved advanced search
* fast and easy auto-complete search
* faster, nicer wiki revision interface
* revamped integrated subscriptions interface
* events and mailing list info for place wiki pages
* recent notes, wiki pages, and active contributors per topic in page sidebar
* easy tag-based pages
* "follow" and "star" for each page
* new simplified/improved wiki editing form
* sorting and prioritization of notes and pages by popularity metric

##Installation

You'll need: 

* ruby (2.1.2 recommended; try using http://rvm.io)
* mysql (not adverse to others, but this is what we run)

Installation steps:

* in the console, `git clone https://github.com/publiclab/plot2.git` or `git clone git@github.com:publiclab/plots2.git`
* `cd` into the new 'plots2' directory
* `bundle install`
* create a database (usually in mysql) and grant permissions to youruser
* copy config/database.yml.example to config/database.yml and add database login info for development and/or production (a separate database for testing is helpful too)
* `rake db:migrate` to set up the database
* `rake db:setup` to populate it with initial data
* `passenger start` to start up the app
* in a browser, navigate to http://localhost:3000
* wheeeee!

##Become a contributor

* Join the 'plots-dev@googlegroups.com' discussion list to get involved
* some devs hang out in http://publiclab.org/chat (irc webchat)
* look for open issues at https://github.com/publiclab/plots2/issues and https://github.com/jywarren/plots2/issues (we are retiring the latter, so only create new issues at the publiclab repo, please!

##Troubleshooting

File issues at https://github.com/publiclab/plots2/issues

