PublicLab.org
======

[![Build Status](https://travis-ci.org/publiclab/plots2.svg)](https://travis-ci.org/publiclab/plots2)
[![badge](http://img.shields.io/badge/first--timers--only-friendly-blue.svg?style=flat-square)](https://github.com/publiclab/plots2/projects/2)

The content management system for the Public Lab research community, the plots2 web application is a combination of a group research blog of what we call "research notes" and a wiki. 

It features a Bootstrap-based UI and a variety of community and attribution features that help the Public Lab community collaborate on environmental technology design and documentation, as well as community organizing. Originally a Drupal site, it was rewritten in 2012 in Ruby on Rails, and has since extended but not entirely replaced the legacy Drupal data model and database design. 

Some key features include:

* a Markdown-based research note and wiki editor
* [wiki editing](https://publiclab.org/wiki) and revision tracking
* tagging and tag-based content organization
* email notification subscriptions for tags and comments
* a barebones search interface
* a user dashboard [presenting recent activity](https://publiclab.org/research)
* a [Question and Answer system](https://publiclab.org/questions)

## Contributing

We welcome contributions, and are especially interested in welcoming [first time contributors](#first-time). Read more about [how to contribute](#developers) below! We especially welcome contributions from people from groups underrepresented in free and open source software!

### Code of Conduct

Please read and abide by our [Code of Conduct](https://publiclab.org/conduct); our community aspires to be a respectful place both during online and in-­person interactions.

====

## Simple installation with Cloud9

This is a quick installation for use with the cloud environment https://c9.io - for more standard, full instructions, see below. 

1. Cloud9 now requires an invite unless you enter a credit card, but there's a workaround -- email plots-dev@googlegroups.com to ask for a free invite to get an account! 
2. On GitHub, fork this repository to your own GitHub account, creating a `yourname/plots2` project.
3. Name your project, then, on https://c9.io, enter `https://github.com/<your-github-username>/plots2.git` in the "Clone from Git or Mercurial URL" field, and press **Create Workspace** 
4. In the command line prompt at the bottom of the page, type `. ./install_cloudnine.sh` and press enter.
5. Enter your username when prompted, and let it set things up.
6. Run `rails s -b $IP -p $PORT` when it's done, or `rake test` to run your tests!

====

## Prerequisites

### Database

Our production application runs on mysql, but for development, sqlite3 is sufficient.

* Mac OS X: Macs ship with sqlite3 already installed.
* Ubuntu/Debian: `sudo apt-get install sqlite3`
* Fedora/Red Hat/CentOS: `sudo yum install sqlite` -- you may need `sqlite-devel` as well.


### Solr search engine (optional)

[Solr](https://lucene.apache.org/solr/) is a standalone search server. You put documents in it (called "indexing") via JSON, XML, CSV or binary over HTTP. You query it via HTTP GET and receive JSON, XML, CSV or binary results. Solr enables powerful matching capabilities including phrases, wildcards, joins, grouping and much more across any data type.
We use the Solr search engine via the [sunspot gem](https://github.com/sunspot/sunspot) and using an adapter called [sunspot_rails](https://github.com/outoftime/sunspot_rails) to communicate to solr search server through our rails app.
Solr requires Java, which is therefore a requirement for running the `rake test:solr` test suite (see [Testing](#testing), below), which runs tests of the search functionality using the files in `/test/solr/`; on a Debian/Ubuntu system, you can install the necessary libraries with:

`sudo apt-get install openjdk-7-jre openjdk-7-jdk`

And start up solr with:

`rake sunspot:solr:start` followed by `rake sunspot:reindex`

However, to ease installation, we've [made Java optional](https://github.com/publiclab/plots2/issues/832) for basic testing using `rake test`. So if you are just starting out you can skip this step.


### Image libraries (optional)

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

`npm install -g bower`

**NOTE:** If you're having permission issues, please see https://docs.npmjs.com/getting-started/fixing-npm-permissions

**WARNING:** Please refrain from using `sudo npm` as it's not only a bad practice, but may also put your security at a risk. For more on this, read https://pawelgrzybek.com/fix-priviliges-and-never-again-use-sudo-with-npm/

### phantomjs for javascript tests (optional)

We are using `jasmine-rails` gem for the optional javascript tests (run with `rake spec:javascript`) which require `phantomjs` for headless testing (i.e. on the commandline, not with a browser). Generally the **phantomjs gem** gets installed along with the `jasmine-rails` gem. If the package installation for the gem fails you can use [this script](https://github.com/codeship/scripts/blob/master/packages/phantomjs.sh) to install it.

But some architectures (Linux!) aren't supported by the phantomjs gem. For those you have to run phantomjs via a native binary, you can find the installation instructions in its official [build documentation](http://phantomjs.org/build.html). For Ubuntu/debian based system you can follow [these instructions](https://gist.github.com/julionc/7476620) or use the script mentioned there. On successful installation you can see the version number of phantomjs with the `phantomjs -v` command. For the binary to work properly with `jasmine-rails` change the line 52 on _spec/javascripts/support/jasmine.yml_ to `use_phantom_gem: false`.

Please report any error regarding phantomjs installation in the github issue tracker. We will try to help you out as soon as we can!


## Installation

Installation steps:

1. In the console, download a copy of the source with `git clone https://github.com/publiclab/plots2.git`.
2. Enter the new **plots2** directory with `cd plots2`.
3. Install gems with `bundle install --without production mysql` from the rails root folder, to install the gems you'll need, excluding those needed only in production. You may need to first run `bundle update` if you have older gems in your environment from previous Rails work. 
4. Make a copy of `db/schema.rb.example` and place it at `db/schema.rb`.
5. Make a copy of `config/database.yml.sqlite.example` and place it at `config/database.yml`
6. Run `rake db:setup` to set up the database
7. Install static assets (like external javascript libraries, fonts) with `bower install`
8. (optional) Install solr engine `rails generate sunspot_rails:install`
9. (optional) Start the solr server in foreground by using `bundle exec rake sunspot:solr:start`
10. (optional) Index your search database in solr server using  `bundle exec rake sunspot:reindex`
11. Start rails with `passenger start` from the Rails root and open http://localhost:3000 in a web browser.
12. Wheeeee! You're up and running! Log in with test usernames "user", "moderator", or "admin", and password "password".
13. Run `rake test` to confirm that your install is working properly. For some setups, you may see warnings even if test pass; [see this issue](https://github.com/publiclab/plots2/issues/440) we're working to resolve.

### Bundle exec

For some, it will be necessary to prepend your gem-related commands with `bundle exec`, for example `bundle exec passenger start`; adding `bundle exec` ensures you're using the version of passenger you just installed with Bundler. `bundle exec rake db:setup`, `bundle exec rake db:seed` are other examples of where this might be necessary.

****


## Testing

Run all basic rails tests with `rake test`. This is required for submitting pull requests, and to confirm you have a working local environment.

`rake test:all` runs **all** tests. This includes Jasmine client-side tests and Solr-dependent tests.

**Client-side tests** (for JavaScript functions) are run using [Jasmine](https://jasmine.github.io/) in [jasmine-rails](https://github.com/searls/jasmine-rails). You can run tests by navigating to `/specs/` in the browser. Headless, or command-line test running may be possible with `rake spec:javascript` [if you have phantomjs installed](#phantomjs-for-javascript-tests) (see above). 

**Solr (search) tests** require [installing the Solr search engine](#solr-search-engine) (see above). Once you've done that, you still need to turn it off in development mode before running tests, with `rake sunspot:solr:stop`. Read more about [this issue here](https://github.com/publiclab/plots2/issues/832#issuecomment-249695309). 

If you get stuck on testing at any point, you can _open a pull request with your changes_ -- please add the prefix `[testing]` to the title -- which will then be automatically tested by our TravisCI service -- which runs **all tests** with `rake test:all`. If your additions are pretty basic, and you write tests against them, this may be sufficient without actually running the whole environment yourself! 

We are extremely interested in building our out test suite, so please consider helping us write tests! 


****

## Bugs and support

To report bugs and request features, please use the GitHub issue tracker provided at https://github.com/publiclab/plots2/issues 

For additional support, join the Public Lab website and mailing list at http://publiclab.org/lists or for urgent requests, email web@publiclab.org

****

### Internationalization

Publiclab.org now supports Internationalization and localization, though we are in the initial stages. This has been accomplished with [rails-I8n](https://github.com/svenfuchs/rails-i18n). 

To see it in action, click on the 'Language' dropdown located in the header/footer section of the page. All the guidelines and best practices for I18n can be found [here](http://guides.rubyonrails.org/i18n.html).

Translations are arranged in the yaml files [here](https://github.com/publiclab/plots2/tree/master/config/locales), which are organized in the similar way to [views](https://github.com/publiclab/plots2/tree/master/app/views) files. An example for adding translations can be found [here](http://guides.rubyonrails.org/i18n.html#adding-translations).

To add new languages or for additional support, please write to plots-dev@googlegroups.com

****

## API

Swagger-generated API documentation can be found at:

https://publiclab.org/api/swagger_doc.json

Per-model API endpoints are:

* Profiles: https://publiclab.org/api/srch/profiles?srchString=foo
* Questions: https://publiclab.org/api/srch/questions?srchString=foo
* Tags: https://publiclab.org/api/srch/tags?srchString=foo
* Notes: https://publiclab.org/api/srch/notes?srchString=foo

****

## Developers

Help improve Public Lab software!

* Join the 'plots-dev@googlegroups.com' discussion list to get involved
* Look for open issues at https://github.com/publiclab/plots2/issues
* We're specifically asking for help with issues labelled with [help-wanted](https://github.com/publiclab/plots2/labels/help-wanted) tag
* Find lots of info on contributing at http://publiclab.org/wiki/developers
* Review specific contributor guidelines at http://publiclab.org/wiki/contributing-to-public-lab-software
* Some devs hang out in http://publiclab.org/chat (irc webchat)

****

## First time?

New to open source/free software?, Here are a selection of issues we've made especially for first-timers. We're here to help, so just ask if one looks interesting : https://github.com/publiclab/plots2/projects/2


We also have a slightly larger list of easy-ish but small and self contained issues: https://github.com/publiclab/plots2/labels/help-wanted
