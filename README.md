PublicLab.org
======

[![Code of Conduct](https://img.shields.io/badge/code-of%20conduct-green.svg)](https://publiclab.org/conduct)
[![Build Status](https://travis-ci.org/publiclab/plots2.svg)](https://travis-ci.org/publiclab/plots2)
[![first-timers-only-friendly](http://img.shields.io/badge/first--timers--only-friendly-blue.svg?style=flat-square)](https://code.publiclab.org#r=all)
[![Join the chat at https://publiclab.org/chat](https://img.shields.io/badge/chat-in%20different%20ways-blue.svg)](https://publiclab.org/chat)
[![Code Climate](https://codeclimate.com/github/publiclab/plots2/badges/gpa.svg)](https://codeclimate.com/github/publiclab/plots2)
[![Coverage Status](https://coveralls.io/repos/github/publiclab/plots2/badge.svg?branch=HEAD)](https://coveralls.io/github/publiclab/plots2?branch=HEAD)
[![View performance data on Skylight](https://badges.skylight.io/typical/GZDPChmcfm1Q.svg)](https://oss.skylight.io/app/applications/GZDPChmcfm1Q)
[![Newcomers welcome](https://img.shields.io/badge/newcomers-welcome-pink.svg)](https://code.publiclab.org)

The content management system for the Public Lab research community, the plots2 web application is a combination of a group research blog of what we call "research notes" and a wiki. Read more about the [data model here](https://github.com/publiclab/plots2/blob/master/doc/DATA_MODEL.md).

It showcases a variety of features that help the Public Lab community collaborate on environmental technology design and documentation, as well as community organizing. Originally a Drupal site, it was rewritten in 2012 in Ruby on Rails and has since extended but not entirely replaced the legacy Drupal data model and database design. We ❤️ Open Source and actively participate in various OSS programs such as [Google Summer of Code(GSoC)](https://publiclab.org/wiki/gsoc), Rails Girls Summer of Code (RGSoC), Outreachy and Google Code-In (GCI).
Some key features include:

* A [Question and Answer system](https://publiclab.org/questions) for peer-based problem solving
* A rich text and Markdown research note and wiki [editor](https://github.com/publiclab/PublicLab.Editor)
* [Wiki editing](https://publiclab.org/wiki) and revision tracking
* Tagging and [tag-based content organization](http://publiclab.org/tags)
* Email notification subscriptions for tags and comments
* A search interface built out of [our growing API](https://github.com/publiclab/plots2/blob/master/doc/API.md)
* A user dashboard [presenting recent activity](https://publiclab.org/dashboard)
* A privacy-sensitive, Leaflet-based [location tagging system](https://github.com/publiclab/leaflet-blurred-location/) and [community map](http://publiclab.org/people)

## Roadmap

We are developing a draft Roadmap for `plots2` and our broader Public Lab code projects; [read more and comment here](https://publiclab.org/notes/warren/05-22-2019/draft-of-a-public-lab-software-roadmap-comments-welcome).

## Table of Contents
1. [What Makes This Project Different](#what-makes-this-project-different)
2. [Data model](#data-model)
3. [Contributing](#contributing)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
    - [Simple Installation with Cloud9](https://github.com/publiclab/plots2/wiki/Simple-Installation-for-Cloud9)
    - [Standard Installation](#standard-installation)
6. [SSL in Development](#ssl-in-development)
7. [Login](#login)
8. [Testing](#testing)
9. [API](https://github.com/publiclab/plots2/blob/master/doc/API.md)
10. [Bundle Exec](#bundle-exec)
11. [Reply-by-email](#reply-by-email)
12. [Bugs and Support](#bugs-and-support)
13. [Recaptcha](#recaptcha)
14. [Internationalization](#internationalization)
15. [Security](#security)
16. [Developers](#developers)
17. [First Time?](#first-time)


****

## What makes this project different

The people who create our platform make very different design and technology decisions from other projects, and this stems from our deep belief that, to see a change in the world, we must build and maintain systems that **reflect our values and principles.**

From design to system architecture to basic vocabulary and communication patterns, our systems have grown organically since 2010 to support a powerful, diverse, and cooperative network of people capable of taking on environmental problems that affect communities around the world. The platform we have built together speaks to this shared history in many ways, big and small. It reflects input from people facing serious health issues, on-the-ground organizers, policy specialists, hardware hackers, educators, and civil servants.

This broad community, and the Public Lab team have facilitated a space where we can discuss, break down, construct, prototype, and critique real-world projects. Together we have shaped a platform that incorporates familiar pieces, but ultimately looks and feels quite different from anywhere else on the internet. Our platform continues to grow and be refined, but it also reflects a commitment to listening to one another, to mutual respect and support, to an awareness of the barriers and challenges presented by gaps in expertise and knowledge, and a sensitivity to the inequalities and power imbalances perpetuated by many mainstream modes of knowledge production and technological and scientific development.

Our mutual aims of democratizing inexpensive and accessible do-it-yourself techniques has allowed us to create a collaborative network of practitioners who actively re-imagine the human relationship with the environment. Our goals are supported and facilitated by a system which questions and even challenges how collaborative work can happen.

## Data Model

![Diagram](https://user-images.githubusercontent.com/24359/50705765-d84ae000-1029-11e9-9e4c-f166a0c0d5d1.png)

_(Above: draft of our [Data model](https://github.com/publiclab/plots2/blob/master/doc/DATA_MODEL.md))_

## Contributing

We welcome contributions, and are especially interested in welcoming [first time contributors](#first-time). Read more about [how to contribute](#developers) below! We especially welcome contributions from people belonging to groups under-represented in free and open source software!

### Code of Conduct

Please read and abide by our [Code of Conduct](https://publiclab.org/conduct); our community aspires to be a respectful place both during online and in-­person interactions.

## Prerequisites

For installation, prerequisites include sqlite3 and rvm. [Click here for a complete list and instructions](https://github.com/publiclab/plots2/blob/master/doc/PREREQUISITES.md).

## Installation

### Installation for Cloud9

For information on how to install for use with the cloud environment, please see [here](https://github.com/publiclab/plots2/wiki/Simple-Installation-for-Cloud9).

### Standard Installation

1. Fork our repo from https://github.com/publiclab/plots2.
2. In the console, download a copy of your forked repo with `git clone https://github.com/your_username/plots2.git` where `your_username` is your GitHub username.
3. Enter the new **plots2** directory with `cd plots2`.
4. Steps to install gems:
    * You may need to first run `bundle install` if you have older gems in your environment from previous Rails work. If you get an error message like `Your Ruby version is 2.x.x, but your Gemfile specified 2.4.4` then you need to install the ruby version 2.4.4 using `rvm` or `rbenv`.
	    * Using **rvm**: `rvm install 2.4.4` followed by `rvm use 2.4.4`
	    * Using **rbenv**:  `rbenv install 2.4.4` followed by `rbenv local 2.4.4`
    * Install gems with `bundle install --without production mysql` from the rails root folder, to install the gems you'll need, excluding those needed only in production.
5. Make a copy of `db/schema.rb.example` and place it at `db/schema.rb`.
6. Make a copy of `config/database.yml.sqlite.example` and place it at `config/database.yml`
7. Run `rake db:setup` to set up the database
8. Install static assets (like external javascript libraries, fonts) with `yarn install`
9. By default, start rails with `passenger start` from the Rails root and open http://localhost:3000 in a web browser.
(for local SSL work, see [SSL](#ssl+in+development) below)
10. Wheeeee! You're up and running! Log in with test usernames "user", "moderator", or "admin", and password "password".
11. Run `rails test` to confirm that your install is working properly. Or `rails test:system` for system tests.

## SSL in Development

We, at Public Lab use [openssl](https://github.com/ruby/openssl) gem to provide SSL for the secure connection in the development mode. You can run the https connection on the localhost by following following steps:
1. Use `passenger start --ssl --ssl-certificate config/localhost.crt --ssl-certificate-key config/localhost.key --ssl-port 3001`.
2. Open up https://localhost:3001.
3. Add security exceptions from the advance settings of the browser.
You can also use http (unsecure connection) on the port number 3000 by going to 'http://localhost:3000'. We use port number 3001 for 'https' and port number 3000 for 'http' connection.
Secure connection is needed for OAuth authentication etc.

## Login

Once you complete the installation, use any of these credentials to login in to the PL website in your local development / testing environment to gain additional permissions for only logged in users. Each one comes with its own set of permissions, but besides that the experience across them is pretty much the same.

**username**: `admin`, `moderator`, or `user` 

**password**: `password`

For more on the login systems, see [this page](https://github.com/publiclab/plots2/blob/b1c57446d016f8cd0ec149a75298711270e1643e/doc/LOGIN_SYSTEMS.md#how-to-setup-login-modal-on-various-locations)

## Testing

Click [here](https://github.com/publiclab/plots2/blob/master/doc/TESTING.md) for a comprehensive description of testing.

## How to start and modify cron jobs

1. We are using [Whenever](https://github.com/javan/whenever) gem to schedule cron jobs.
2. All the cron jobs are written in easy ruby syntax using this gem and can be found in config/schedule.rb.
2. Go to the config/schedule.rb file to create and modify the cron jobs.
3. [Click here](https://github.com/javan/whenever) to know about how to write cron jobs.
4. After updating config/schedule.rb file run the command `whenever --update-crontab` to update the cron jobs.
5. To see the installed list of cron jobs use command `crontab -l`
6. For more details about this gem, visit the official repository of whenever gem.


## Bundle exec

For some, it will be necessary to prepend your gem-related commands with `bundle exec`.
For example, `bundle exec passenger start`.
Adding `bundle exec` ensures you're using the version of passenger you just installed with Bundler.
`bundle exec rake db:setup`, `bundle exec rake db:seed` are other examples of where this might be necessary.


## Reply-by-email

Public Lab now supports reply by email to comment feature. For more details regarding it go to the [email documentation](https://github.com/publiclab/plots2/blob/master/doc/EMAIL.md)


## Bugs and support

To report bugs and request features, please use the GitHub issue tracker provided at https://github.com/publiclab/plots2/issues

For additional support, join the Public Lab website and mailing list at http://publiclab.org/lists or for urgent requests, email web@publiclab.org

## Recaptcha

This application uses RECAPTCHA via the recaptcha gem in production only. For more information, click [here](https://github.com/publiclab/plots2/blob/master/doc/RECAPTCHA.md).

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

* Join the plots-dev@googlegroups.com discussion list to get involved
* Look for open issues at https://github.com/publiclab/plots2/labels/help-wanted
* We're specifically asking for help with issues labelled with [help-wanted](https://github.com/publiclab/plots2/labels/help-wanted) tag
* Find lots of info on contributing at http://publiclab.org/wiki/developers
* Review specific contributor guidelines at http://publiclab.org/wiki/contributing-to-public-lab-software
* Some devs hang out in http://publiclab.org/chat (irc webchat)
* Join our gitter chat at https://gitter.im/publiclab/publiclab
* Try out some supportive tasks https://github.com/publiclab/plots2/wiki/Supportive-Tasks
* Get involved with our weekly community check-ins. For guidelines: [https://github.com/publiclab/plots2/tree/master/doc/CHECKINS.md
](https://github.com/publiclab/plots2/tree/master/doc/CHECKINS.md)

## First Time?

New to open source/free software? Here is a selection of issues we've made **especially for first-timers**. We're here to help, so just ask if one looks interesting : https://code.publiclab.org

[Here](https://publiclab.org/notes/warren/11-22-2017/use-git-and-github-to-contribute-and-improve-public-lab-software) is a link to our Git workflow.

## Let the code be with you. 
### Happy opensourcing. :smile:

<hr>

<center>

#### [Platforms that :heart: OSS](./doc/SUPPORTERS.md)

</center>
