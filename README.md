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

====

##Simple installation with Cloud9

1. If you have a GitHub account, visit https://c9.io and log in with the GitHub button.
2. Fork this repository to your own GitHub account, creating a `yourname/plots2` project.
3. Name your project, then (order important!) choose the **Ruby** template, THEN enter `yourname/plots2` in the "Clone from Git or Mercurial URL" field, and press **Create Workspace** 
4. In the command line prompt at the bottom of the page, type `./install_cloudnine.sh` and press enter.
5. Enter your username when prompted, and click "Run Project" when it's done.
6. You're done! Go to the URL shown!

====

##Prerequisites

Recommended; for an Ubuntu/Debian system. Varies slightly for mac/fedora/etc

Install a database, if necessary. We use mysql -- we're not adverse to others, but this is what we've built it on.

`sudo apt-get install mysql-server`

Application-specific dependencies:

`sudo apt-get install bundler libmysqlclient-dev imagemagick ruby-rmagick`

Install rvm for Ruby management (http://rvm.io)

`curl -L https://get.rvm.io | bash -s stable`

**Note:** At this point during the process, you may want to log out and log back in, or open a new terminal window; RVM will then properly load in your environment.

**Ubuntu users:** You may need to enable `Run command as a login shell` in Ubuntu's Terminal, under Profile Preferences > Title and Command. Then close the terminal and reopen it. You may also want to run `source ~/.rvm/scripts/rvm` to load RVM.

Then, use RVM to install version 2.1.2 of Ruby. (v1.9.3+ should also work):

`rvm install 2.1.2`

You'll also need **bower** which is available through NPM. To install NPM, you can run:

`sudo apt-get install npm`

However, on Ubuntu, you may need to also install the `nodejs-legacy` package, as due to a naming collision, some versions of Ubuntu already have an unrelated package called `node`. To do this, run:

`sudo apt-get install nodejs-legacy`

On Debian Wheezy, you may need instead to:

* Run `sudo apt-get -t wheezy-backports install nodejs` as the `npm` package may not be available. 
* Then run `sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100` to make it available under the name `node` -- similarly to what we do for Ubuntu, above. 
* Finally, run `curl -0 -L https://www.npmjs.org/install.sh | sudo sh` 

Once NPM is installed, you should be able to run:

`sudo npm install -g bower`


##Installation

Installation steps:

1. In the console, download a copy of the source with `git clone https://github.com/publiclab/plots2.git` or `git clone git@github.com:publiclab/plots2.git`.
2. `cd plots2` to enter the new 'plots2' directory.
3. Install gems with `bundle install` from the rails root folder. You may need to run `bundle update` if you have older gems in your environment.
4. Copy and configure `config/database.yml` from `config/database.yml.example`, using a new empty databse you've created. A quick command you could use is: `cp config/database.yml.example config/database.yml`. You can then use your favorite editor to edit the `config/database.yml` file.
5. Grant database creation permissions to your username.
6. Initialize database with `bundle exec rake db:setup`
  * if there are any errors, try one of these two fixes:
    * run `rake db:migrate`
    * OR
    * in MySQL, `drop database XXX;` for each database in `config/database.yml` and then try `rake db:setup` again
7. `rake db:seed` to populate it with initial dummy data
8. Install static assets (like external javascript libraries, fonts) with `bower install` 
9. Start rails with `bundle exec passenger start` from the Rails root and open http://localhost:3000 in a web browser. (For some, just `passenger start` will work; adding `bundle exec` ensures you're using the version of passenger you just installed with Bundler.) You may use `passenger start -a 0.0.0.0 -p 3000 -d -e production` to run production version and access it via publicly accessibly IP address.
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

##First time?

New to open source/free software? We've listed some "good for first timers" bugs to fix here: https://github.com/publiclab/plots2/labels/first-timers-only

We also have a slightly larger list of easy-ish but small and self contained issues: https://github.com/publiclab/plots2/labels/help-wanted

