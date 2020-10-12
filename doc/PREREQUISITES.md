### Database

Our production application runs on mysql, but for development, sqlite3 is sufficient.

* Mac OS X: Macs ship with sqlite3 already installed.
* Ubuntu/Debian: `sudo apt-get install sqlite3`
* Fedora/Red Hat/CentOS: `sudo yum install sqlite` -- you may need `sqlite-devel` as well.


### Image libraries (optional)

If you are just developing and don't plan to do work with image uploading, you may not need the following, but otherwise:

`sudo apt-get install imagemagick ruby-rmagick`


### Ruby

Install rvm for Ruby management (http://rvm.io)

`curl -L https://get.rvm.io | bash -s stable`

**Note:** At this point during the process, you may want to log out and log back in, or open a new terminal window; RVM will then properly load in your environment.

**Ubuntu users:** You may need to enable `Run command as a login shell` in Ubuntu's Terminal, under `Edit > Profile Preferences > Title and Command`. Then close the terminal and reopen it. You may also want to run `source ~/.rvm/scripts/rvm` to load RVM.

Then, use RVM to install version 2.6.6 of Ruby. (v1.9.3+ should also work):

`rvm install 2.6.6`


### Gems with Bundler

Ruby dependencies, or Gems, are managed with Bundler. 

`gem install bundler` - if it's not already installed, but it should be in a basic RVM ruby. 


### Assets with Yarn

You'll also need **yarn** to get your JavaScript dependencies.

[The official installation section](https://yarnpkg.com/lang/en/docs/install/#debian-stable) for yarn has installation details for many systems.

Use `yarn --version` to verify whether the installation is up and running!
	
**Note:** In case the options described above do not work for you, you can also install yarn using npm,though it is generally not recommended. As a prerequisite, you will have to [install Node.js](https://nodejs.org/en/download/) if not already installed.
To install yarn using npm, use `npm install --global yarn` and continue with path setup similar to the usual installation.	

### phantomjs for javascript tests (optional)

We are using `jasmine-rails` gem for the optional javascript tests (run with `rake spec:javascript`) which require `phantomjs` for headless testing (i.e. on the commandline, not with a browser). Generally the **phantomjs gem** gets installed along with the `jasmine-rails` gem. If the package installation for the gem fails you can use [this script](https://github.com/codeship/scripts/blob/master/packages/phantomjs.sh) to install it.

But some architectures (Linux!) aren't supported by the phantomjs gem. For those you have to run phantomjs via a native binary, you can find the installation instructions in its official [build documentation](http://phantomjs.org/build.html). For Ubuntu/debian based system you can follow [these instructions](https://gist.github.com/julionc/7476620) or use the script mentioned there. On successful installation you can see the version number of phantomjs with the `phantomjs -v` command. For the binary to work properly with `jasmine-rails` change the line 52 on _spec/javascripts/support/jasmine.yml_ to `use_phantom_gem: false`.

Please report any error regarding phantomjs installation in the github issue tracker. We will try to help you out as soon as we can!
