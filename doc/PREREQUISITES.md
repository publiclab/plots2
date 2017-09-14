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

**Ubuntu users:** You may need to enable `Run command as a login shell` in Ubuntu's Terminal, under `Edit > Profile Preferences > Title and Command`. Then close the terminal and reopen it. You may also want to run `source ~/.rvm/scripts/rvm` to load RVM.

Then, use RVM to install version 2.3 of Ruby. (v1.9.3+ should also work):

`rvm install 2.3`


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
