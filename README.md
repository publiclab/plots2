PublicLab.org
======

The content management system for the Public Lab research community, the plots2 web application is a combination of a group research blog of what we call "research notes," and a wiki. 

It features a Bootstrap-based UI and a variety of community and attribution features that help the Public Lab community collaborate on environmental technology design and documentation, as well as community organizing. Originally a Drupal site, it was rewritten in 2012 in Ruby on Rails, and has since extended but not entirely replaced the legacy Drupal data model and database design. 

Some key features include:

* a Markdown-based research note and wiki editor
* wiki editing and revision tracking
* tagging and tag-based content organization
* email notification subscriptions for tags and comments
* a barebones search interface
* a user dashboard presenting recent activity


====

##Simple installation with Cloud9

This is a quick installation for use with the cloud environment https://c9.io - for more standard, full instructions, see below. 

1. If you have a GitHub account, visit https://c9.io and log in with the GitHub button.
2. Fork this repository to your own GitHub account, creating a `yourname/plots2` project.
3. Name your project, then enter `yourname/plots2` in the "Clone from Git or Mercurial URL" field, and press **Create Workspace** 
4. In the command line prompt at the bottom of the page, type `. ./install_cloudnine.sh` and press enter.
5. Enter your username when prompted, and run `rails s -b $IP -p $PORT` when it's done.
6. You're done! Go to the URL shown!


====

## Prerequisites

### Database

Our production application runs on mysql, but for development, sqlite3 is sufficient.

* Mac OS X: Macs ship with sqlite3 already installed.
* Ubuntu/Debian: `sudo apt-get install sqlite3`
* Fedora/Red Hat/CentOS: `sudo yum install sqlite` -- you may need `sqlite-devel` as well.


### Image libraries

If you are just developing and don't plan to do work with image uploading, you may not need the following, but otherwise:

`sudo apt-get install imagemagick ruby-rmagick`


### Ruby

Install rvm for Ruby management (http://rvm.io)

`curl -L https://get.rvm.io | bash -s stable`

**Note:** At this point during the process, you may want to log out and log back in, or open a new terminal window; RVM will then properly load in your environment.

**Ubuntu users:** You may need to enable `Run command as a login shell` in Ubuntu's Terminal, under _Edit > Profile Preferences > Title and Command_. Then close the terminal and reopen it. You may also want to run `source ~/.rvm/scripts/rvm` to load RVM.

Then, use RVM to install version 2.1.2 of Ruby. (v1.9.3+ should also work):

`rvm install 2.1.2`


### Gems with Bundler

Ruby dependencies, or Gems, are managed with Bundler. 

`gem install bundler` - if it's not already installed, but it should be in a basic RVM ruby. 


### Assets with Bower

You'll also need **bower** which is available through `npm`, part of `node.js`.

[This wiki page from the nodejs repository](https://github.com/nodejs/node/wiki) has comprehensive and up to date installation guides for many systems. 
 
Once NPM is installed, you should be able to run:

`sudo npm install -g bower`

### phantomjs for javascript tests

We are using `jasmine-rails` gem for javascript tests which require phantomjs for headless testing. Generally the **phantomjs gem** gets installed along with the `jasmine-rails` gem. If the package installation for the gem fails you can use [this script](https://github.com/codeship/scripts/blob/master/packages/phantomjs.sh) to install it.

But some architectures don't support the phantomjs gem. For those you have to run phantomjs via its binary.You can find the installation instructions in its official [build documentation](http://phantomjs.org/build.html). For Ubuntu/debian based system you can follow [these instructions](https://gist.github.com/julionc/7476620) or use the script mentioned there. On successful installation you can see the version number of phantomjs with the `phantomjs -v` command. For the binary to work properly with `jasmine-rails` change the line 52 on _spec/javascripts/support/jasmine.yml_ to `use_phantom_gem: false`.

Please report any error regarding phantomjs installation in the github issue tracker. We will try to solve it as fast as possible.


### Solr search engine

Solr is a standalone search server. You put documents in it (called "indexing") via JSON, XML, CSV or binary over HTTP. You query it via HTTP GET and receive JSON, XML, CSV or binary results. Solr enables powerful matching capabilities including phrases, wildcards, joins, grouping and much more across any data type.
We are using an adapter called `sunspot` to communicate to solr search server through our rails app.


##Installation

Installation steps:

1. In the console, download a copy of the source with `git clone https://github.com/publiclab/plots2.git`.
2. Enter the new **plots2** directory with `cd plots2`.
3. Install gems with `bundle install --without production` from the rails root folder, to install the gems you'll need, excluding those needed only in production. You may need to first run `bundle update` if you have older gems in your environment from previous Rails work. 
4. Make a copy of `db/schema.rb.example` and place it at `db/schema.rb`.
5. Make a copy of `config/database.yml.sqlite.example` and place it at `config/database.yml`
6. Run `rake db:setup` to set up the database
7. Install static assets (like external javascript libraries, fonts) with `bower install`
8. Install solr engine `rails generate sunspot_rails:install`
9. Index your local relational database in solr server using  `bundle exec rake sunspot:reindex`
10. Start the solr server in foreground by using `bundle exec rake sunspot:solr:start`
11. Start rails with `passenger start` from the Rails root and open http://localhost:3000 in a web browser.
12. Wheeeee! You're up and running! Log in with test usernames "user", "moderator", or "admin", and password "password".
13. Run `rake test:all` to confirm that your install is working properly. For some setups, you may see warnings even if test pass; [see this issue](https://github.com/publiclab/plots2/issues/440) we're working to resolve.

### Bundle exec

For some, it will be necessary to prepend your gem-related commands with `bundle exec`, for example `bundle exec passenger start`; adding `bundle exec` ensures you're using the version of passenger you just installed with Bundler. `bundle exec rake db:setup`, `bundle exec rake db:seed` are other examples of where this might be necessary.

****


##Testing

Run tests with `rake test:all` for running all tests. We are extremely interested in building our out test suite, so please consider helping us write tests! 

Run only rails tests with `rake test`.

Client-side code is tested using [Jasmine](https://jasmine.github.io/) in [jasmine-rails](https://github.com/searls/jasmine-rails). You can run tests by navigating to `/specs/` in the browser. Headless, or command-line test running may be possible with `rake spec:javascript` if you have phantomjs installed. 


****

##Bugs and support

To report bugs and request features, please use the GitHub issue tracker provided at https://github.com/publiclab/plots2/issues 

For additional support, join the Public Lab website and mailing list at http://publiclab.org/lists or for urgent requests, email web@publiclab.org

****

###Internationalization

Publiclab.org now supports Internationalization and localization, though we are in the initial stages. This has been accomplished with [rails-I8n](https://github.com/svenfuchs/rails-i18n). 

To see it in action, click on the 'Language' dropdown located in the header/footer section of the page. All the guidelines and best practices for I18n can be found [here](http://guides.rubyonrails.org/i18n.html).

Translations are arranged in the yaml files [here](https://github.com/publiclab/plots2/tree/master/config/locales), which are organized in the similar way to [views](https://github.com/publiclab/plots2/tree/master/app/views) files. An example for adding translations can be found [here](http://guides.rubyonrails.org/i18n.html#adding-translations).

To add new languages or for additional support, please write to plots-dev@googlegroups.com

****

##Developers

Help improve Public Lab software!

* Join the 'plots-dev@googlegroups.com' discussion list to get involved
* Look for open issues at https://github.com/publiclab/plots2/issues
* We're specifically asking for help with issues labelled with [help-wanted](https://github.com/publiclab/plots2/labels/help-wanted) tag
* Find lots of info on contributing at http://publiclab.org/wiki/developers
* Review specific contributor guidelines at http://publiclab.org/wiki/contributing-to-public-lab-software
* Some devs hang out in http://publiclab.org/chat (irc webchat)

****

##First time?

New to open source/free software? We've listed some "good for first timers" bugs to fix here: https://github.com/publiclab/plots2/labels/first-timers-only

We also have a slightly larger list of easy-ish but small and self contained issues: https://github.com/publiclab/plots2/labels/help-wanted
