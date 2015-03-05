PublicLab.org
======

A complete rewrite of the Public Lab website on a new platform, with a whole new look. Rails, Bootstrap; intended to:

* boast more usable, friendly, but also more powerful interfaces
* simplify and refine common tasks like posting research notes and filtering spam
* enable faster development (based on Ruby on Rails and Twitter's Bootstrap frameworks)
* completely revise and streamline "following" other contributors or specific keywords, with email alerts
* work on tablets, smartphones, and in recent versions of Internet Explorer

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

##Prerequisites

Recommended; for an Ubuntu/Debian system. Varies slightly for mac/fedora/etc

Install a database, if necessary. We use mysql -- we're not adverse to others, but this is what we've built it on.

`sudo apt-get install mysql-server`

Application-specific dependencies:

`sudo apt-get install bundler libmysqlclient-dev imagemagick ruby-rmagick libfreeimage3 libfreeimage-dev ruby-dev libmagickcore-dev libmagickwand-dev`

(optional) For exporting, you'll need GDAL >=1.7.x (gdal.org), as well as `curl` and `zip`-- but these are not needed for much of development, unless you're working on the exporting features. 

`sudo apt-get install gdal-bin python-gdal curl libcurl4-openssl-dev libssl-dev zip`

Install rvm for Ruby management (http://rvm.io)

`curl -L https://get.rvm.io | bash -s stable`

**Note:** At this point during the process, you may want to log out and log back in, or open a new terminal window; RVM will then properly load in your environment. 

**Ubuntu users:** You may need to enable `Run command as a login shell` in Ubuntu's Terminal, under Profile Preferences > Title and Command. Then close the terminal and reopen it.

Then, use RVM to install version 2.1.2 of Ruby. (v1.9.3+ should also work):

`rvm install 2.1.2`

You'll also need **bower** which is available through NPM. To install NPM, you can run:

`sudo apt-get install npm`

However, on Ubuntu, you may need to also install the `nodejs-legacy` package, as due to a naming collision, some versions of Ubuntu already have an unrelated package called `node`. To do this, run:

`sudo apt-get install nodejs-legacy`

Once NPM is installed, you should be able to run:

`sudo npm install -g bower`


##Installation

Installation steps:

1. In the console, download a copy of the source with `git clone https://github.com/publiclab/plot2.git` or `git clone git@github.com:publiclab/plots2.git`.
2. `cd plots2` to enter the new 'plots2' directory.
3. Install gems with `bundle install` from the rails root folder. You may need to run `bundle update` if you have older gems in your environment.
4. Copy and configure config/database.yml from config/database.yml.example, using a new empty databse you've created.
5. Grant database creation permissions to your username.
6. Initialize database with `bundle exec rake db:setup`
  * if there are any errors, try one of these two fixes:
    * run `rake db:migrate`
    * OR
    * in MySQL, `drop database XXX;` for each database in `config/database.yml` and then try `rake db:setup` again
7. `rake db:seed` to populate it with initial dummy data
8. Install static assets (like external javascript libraries, fonts) with `bower install` 
9. Start rails with `bundle exec passenger start` from the Rails root and open http://localhost:3000 in a web browser. (For some, just `passenger start` will work; adding `bundle exec` ensures you're using the version of passenger you just installed with Bundler.)
10. Wheeeee!

##Bugs and support

To report bugs and request features, please use the GitHub issue tracker provided at https://github.com/publiclab/plots2/issues 

For additional support, join the Public Lab website and mailing list at http://publiclab.org/lists or for urgent requests, email web@publiclab.org

##Developers

Help improve Public Lab software!

* Join the 'plots-dev@googlegroups.com' discussion list to get involved
* Look for open issues at https://github.com/publiclab/plots2/issues
* Review contributor guidelines at http://publiclab.org/wiki/contributing-to-public-lab-software
* Some devs hang out in http://publiclab.org/chat (irc webchat)
