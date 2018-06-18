PublicLab.org
======

[![Build Status](https://travis-ci.org/publiclab/plots2.svg)](https://travis-ci.org/publiclab/plots2)
[![badge](http://img.shields.io/badge/first--timers--only-friendly-blue.svg?style=flat-square)](https://github.com/publiclab/plots2/projects/2)
[![Join the chat at https://gitter.im/publiclab/publiclab](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/publiclab/publiclab)
[![Code Climate](https://codeclimate.com/github/publiclab/plots2/badges/gpa.svg)](https://codeclimate.com/github/publiclab/plots2)
[![Coverage Status](https://coveralls.io/repos/github/publiclab/plots2/badge.svg?branch=HEAD)](https://coveralls.io/github/publiclab/plots2?branch=HEAD)

The content management system for the Public Lab research community, the plots2 web application is a combination of a group research blog of what we call "research notes" and a wiki. Read more about [the data model here](https://github.com/publiclab/plots2/blob/master/doc/DATA_MODEL.md).

It features a Bootstrap-based UI and a variety of community and attribution features that help the Public Lab community collaborate on environmental technology design and documentation, as well as community organizing. Originally a Drupal site, it was rewritten in 2012 in Ruby on Rails and has since extended but not entirely replaced the legacy Drupal data model and database design.

Some key features include:

* a [Question and Answer system](https://publiclab.org/questions) for peer-based problem solving
* a rich text and Markdown research note and wiki [editor](https://github.com/publiclab/PublicLab.Editor)
* [wiki editing](https://publiclab.org/wiki) and revision tracking
* tagging and [tag-based content organization](http://publiclab.org/tags)
* email notification subscriptions for tags and comments
* a search interface built out of [our growing API](https://github.com/publiclab/plots2/blob/master/doc/API.md)
* a user dashboard [presenting recent activity](https://publiclab.org/dashboard)
* a privacy-sensitive, Leaflet-based [location tagging system](https://github.com/publiclab/leaflet-blurred-location/) and [community map](http://publiclab.org/people)

![Diagram](https://publiclab.org/system/images/photos/000/021/061/original/diagram.png)

_(Above: draft of our [Data model](https://github.com/publiclab/plots2/blob/master/doc/DATA_MODEL.md))_

## Contributing

We welcome contributions, and are especially interested in welcoming [first time contributors](#first-time). Read more about [how to contribute](#developers) below! We especially welcome contributions from people from groups under-represented in free and open source software!

### Code of Conduct

Please read and abide by our [Code of Conduct](https://publiclab.org/conduct); our community aspires to be a respectful place both during online and in-­person interactions.


## Table of Contents

1. [Simple Installation with Cloud9](https://github.com/publiclab/plots2/wiki/Simple-Installation-for-Cloud9)
2. [Prerequisites](https://github.com/publiclab/plots2/blob/master/doc/PREREQUISITES.md)
3. [Testing](https://github.com/publiclab/plots2/blob/master/doc/TESTING.md)
4. [API](https://github.com/publiclab/plots2/blob/master/doc/API.md)
5. [Bugs and Support](#bugs-and-support)
6. [Data model](https://github.com/publiclab/plots2/blob/master/doc/DATA_MODEL.md)
7. [Recaptcha](https://github.com/publiclab/plots2/blob/master/doc/RECAPTCHA.md)

****

## Installation

1. Fork our repo from https://github.com/publiclab/plots2.
2. In the console, download a copy of your forked repo with `git clone https://github.com/your_username/plots2.git` where `your_username` is your GitHub username.
3. Enter the new **plots2** directory with `cd plots2`.
4. Install gems with `bundle install --without production mysql` from the rails root folder, to install the gems you'll need, excluding those needed only in production. You may need to first run `bundle update` if you have older gems in your environment from previous Rails work.
5. Make a copy of `db/schema.rb.example` and place it at `db/schema.rb`.
6. Make a copy of `config/database.yml.sqlite.example` and place it at `config/database.yml`
7. Run `rake db:setup` to set up the database
8. Install static assets (like external javascript libraries, fonts) with `bower install`
9. By default, start rails with `passenger start` from the Rails root and open http://localhost:3000 in a web browser.
(for local SSL work, see [SSL](#ssl+in+development) below)
10. Wheeeee! You're up and running! Log in with test usernames "user", "moderator", or "admin", and password "password".
11. Run `rake test` to confirm that your install is working properly.

## SSL in Development
We at public labs use [openssl](https://github.com/ruby/openssl) gem to provide SSL for the secure connection in the development mode. You can run the https connection on the localhost by following following steps:
1. Use 'passenger start --ssl --ssl-certificate config/localhost.crt --ssl-certificate-key config/localhost.key --ssl-port 3001'.
2. Open up https://localhost:3001.
3. Add security exceptions from the advance settings of the browser.
You can also use http (unsecure connection) on the port number 3000 by going to 'http://localhost:3000'. We use port number 3001 for 'https' and port number 3000 for 'http' connection.
Secure connection is needed for OAuth authentication etc.

## How to start and modify cron jobs

1. We are using whenever gem to schedule cron jobs [Whenever](https://github.com/javan/whenever)
2. All the cron jobs are written in easy ruby syntax using this gem and can be found in config/schedule.rb.
2. Go to the config/schedule.rb file to create and modify the cron jobs.
3. [Click here](https://github.com/javan/whenever) to know about how to write cron jobs.
4. After updating config/schedule.rb file run the command `whenever --update-crontab` to update the cron jobs.
5. To see the installed list of cron jobs use command `crontab -l`
6. For more details about this gem, visit the official repository of whenever gem.

***

### Bundle exec

For some, it will be necessary to prepend your gem-related commands with `bundle exec`, for example, `bundle exec passenger start`; adding `bundle exec` ensures you're using the version of passenger you just installed with Bundler. `bundle exec rake db: setup`, `bundle exec rake db: seed` are other examples of where this might be necessary.

***

### Reply-by-email

Public Lab now supports reply by email to comment feature. For more details regarding it go to the [email documentation](https://github.com/publiclab/plots2/blob/master/doc/EMAIL.md)

***

## Bugs and support

To report bugs and request features, please use the GitHub issue tracker provided at https://github.com/publiclab/plots2/issues

For additional support, join the Public Lab website and mailing list at http://publiclab.org/lists or for urgent requests, email web@publiclab.org

***

## Internationalization

Publiclab.org now supports Internationalization and localization, though we are in the initial stages. This has been accomplished with [rails-I8n](https://github.com/svenfuchs/rails-i18n).

To see it in action, click on the 'Language' drop-down located in the footer section of the page. All the guidelines and best practices for I18n can be found [here](http://guides.rubyonrails.org/i18n.html).

Translations are arranged in the YAML files [here](https://github.com/publiclab/plots2/tree/master/config/locales), which are
set in a similar way to [views](https://github.com/publiclab/plots2/tree/master/app/views) files. An example for adding translations can be found [here](http://guides.rubyonrails.org/i18n.html#adding-translations).

To add new languages or for additional support, please write to plots-dev@googlegroups.com

## Security

To report security vulnerabilities or for questions about security, please contact web@publiclab.org. Our Web Working Group will assess and respond promptly.

## Developers

Help improve Public Lab software!

* Join the 'plots-dev@googlegroups.com' discussion list to get involved
* Look for open issues at https://github.com/publiclab/plots2/issues
* We're specifically asking for help with issues labelled with [help-wanted](https://github.com/publiclab/plots2/labels/help-wanted) tag
* Find lots of info on contributing at http://publiclab.org/wiki/developers
* Review specific contributor guidelines at http://publiclab.org/wiki/contributing-to-public-lab-software
* Some devs hang out in http://publiclab.org/chat (irc webchat)
* Join our gitter chat at https://gitter.im/publiclab/publiclab

## First Time?

New to open source/free software? Here is a selection of issues we've made **especially for first-timers**. We're here to help, so just ask if one looks interesting : https://publiclab.github.io/community-toolbox/#r=all


We also have a slightly larger list of easy-ish but small and self-contained issues: https://github.com/publiclab/plots2/labels/help-wanted
