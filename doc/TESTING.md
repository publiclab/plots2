(Moved from https://github.com/publiclab/plots2/wiki/Testing)

Run all basic rails tests with `rails test -d`. This is **no longer required for submitting pull requests** (see [Pull Requests](#pull-requests), below), and to confirm you have a working local environment.

`rake test:all` runs teaspoon-mocha client-side tests and coverage reporting.

## Pull Requests

[Open a pull request](https://services.github.com/on-demand/github-cli/open-pull-request-github) early, and link it back to the issue you're working on! We run an automatic testing service called Travis on all [pull requests](https://github.com/publiclab/plots2/pulls); this means that it can be easier to simply upload your changes and see how they run in this standard test environment. That way other contributors can see what you've done, and help you out or provide support.

### Working in a pull request

The tests take between 6-12 minutes to run (we're working on shortening this!) so you won't see results immediately, but once you do, we have a bot to try to identify where things went wrong (if anything!). You can also view the complete output of the tests by clicking on the little red X or green checkmark that appears next to your changes, on the pull request page. This can really help in debugging your code! Feel free to keep pushing new commits to the same branch and pull request, and the tests will re-run as many times as you like. We encourage this!

****

## Coverage

See [plots2 on CodeClimate](https://codeclimate.com/github/publiclab/plots2) for how well covered our code is with tests; we are extremely interested in building out our test suite, so please consider helping us write tests!

## Client-side tests

Client-side tests (for JavaScript functions) are run using [teaspoon-mocha](https://github.com/jejacks0n/teaspoon) tests. You can run tests by navigating to `/teaspoon/` in the browser. Headless, or command-line test running may be possible with:

`rake teaspoon`

JavaScript tests can be found here: https://github.com/publiclab/plots2/tree/main/spec/javascripts but they're limited because they are only run against static HTML fixture files, which need to be kept up to date to match what's in the actual site HTML. 
We're also interested in exploring System Tests, which would run full-stack tests in a headless Chrome environment and allow testing of JavaScript functions on live code; see https://github.com/publiclab/plots2/issues/3683

****

If you get stuck on testing at any point, you can _open a pull request with your changes_ -- please add the prefix `[testing]` to the title -- which will then be automatically tested by our TravisCI service -- which runs **all tests**. If your additions are pretty basic, and you write tests against them, this may be sufficient without actually running the whole environment yourself!

## Running just one type of test

If you want to run just unit tests, to save time, you can run:

`rails test test/unit`

Likewise, for functional or integration tests:

`rails test test/functional`

`rails test test/integration`


## Running just one test

To run one test file:

`rails test test/unit/some_file.rb`

And to run just a single test within a file:

`rails test test/functional/some_file.rb:[line number of the test]`

### Testing mails in development environment

We are using 'letter_opener' gem to open the mails in development environment.
Whenever a email is sent then it will automatically catch by letter_opener and it will open in new window in development environment, nothing is to be done to run it, it will be done automatically.
Same links would work, no modification in links are required.
It will also show us how our actual mail will look like.
Mail will be same as actual mail we will get in production.

## Testing branches

We have three principal branches: a main, where all tested new features are live,
a stable and an unstable. Those last two are used to test new code before sending
them to production.
If you need to use the stable or the unstable branch,
please ask in the chatroom (https://publiclab.org/chat) if someone else is
already using it.

## How to run plots2 with MySQL on development and test environments

In development and test environments, the project uses SQLite3, but in production
it uses [MySQL (or mariadb)](https://github.com/publiclab/plots2/blob/main/containers/docker-compose-production.yml).

If you need to test something that SQLite3 doesn't support, like a full-text
search, for example, you need to add more steps to your configuration:

1 - Install MySQL or mariadb on your machine

2 - Update your `mysql` group on Gemfile to:

```
group :mysql, :production, :development, :test do
  gem 'mysql2', '>= 0.4.4'
  # mysql 0.4.3+ causes a version mismatch, apparently, and demands 'activerecord-mysql2-adapter'
end
```

3 - Comment this group:

```
group :sqlite, :development do
  gem 'sqlite3'
end
```

4 - Copy the file `config/database.yml.mysql.example` to your `config/database.yml`
You may need to add a password and a username. If you don't remember them when
you installed MySQL, run `mysql_secure_installation` to set a new password.

You may also need to create a database, it depends on which OS you're using.

This is an example of the config/database.yml file after following those steps:

```
development:
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: yourusername
  password: yourpassword
  database: plots2_development
  strict: false

production:
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: yourusername
  password: yourpassword
  database: plots2_production

test:
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: yourusername
  password: yourpassword
  database: plots2_test
  strict: false
```

5 - Run `bundle install`

6 - Run rake `db:setup`

If everything run smoothly, this will avoid some weird errors (like passing the
tests locally but not on travis). Remember *not to add* those to your commits.

## Tests with MySQL features

It may be a good practice to add the tests that use MySQL features in a different
file and use a skip method for the SQLite3 adapter:

`skip "full text search only works on mysql/mariadb" if ActiveRecord::Base.connection.adapter_name == 'sqlite3'`

Take a look at this test [search_service_full_text_search_test.rb](https://github.com/publiclab/plots2/blob/main/test/unit/api/search_service_full_text_search_test.rb) for more details.

This way we don't have errors either using SQLite3 or MySQL on development and tests
environments.

## Testing your work with Unstable

### What is _unstable_? 
It is a staging server that includes a copy of the production database and is intended for experimenting or debugging purposes. Those with [write permissions](https://help.github.com/en/articles/repository-permission-levels-for-an-organization) can push to the plots2 `unstable` branch on Github, which will initiate a build and deploy to https://unstable.publiclab.org.

Use it when you need database records that are too difficult or time-consuming to reproduce locally, or to debug a problem on the production site that you can't reproduce locally.
See summary and usage instructions below.

**Environment:** Test environment
**Database:** MySQL
**Data:** Data present at https://unstable.publiclab.org is updated occasionally using the Production database, so it has good amount of data for testing. 
**Email testing:** _unstable_ server can't send emails so Email related features can't be tested.  

### Pushing on `unstable`

1. Drop a message in the [Gitter chatroom](https://gitter.im/publiclab/publiclab) that you are pushing to _unstable_, as other members also use it for testing their work so you don't want to shock them by pushing your work over theirs. After dropping the message, wait for 5 mins, and if no one mentions that they are using the branch, then go to step 2.
2. Push using: `git push -f https://github.com/publiclab/plots2.git HEAD:unstable`.<br><br>**Note:** If you get this message - `remote: Permission to publiclab/plots2.git denied to <username>` then you don't have permission to push to _unstable_ branch.
But, don't worry, feel free to ping @publiclab/maintainers on your open PR to request access or ask in the chatroom and someone else with write access will push your work (PR/branch) for you.  
3. See build progress at https://jenkins.laboratoriopublico.org/job/Plots-Unstable/. It takes 8-15 mins for build to complete. 
4. Test website: https://unstable.publiclab.org/. 

Once your PR is merged into plots2/main, code is only deployed to the live site [publiclab.org](publiclab.org) after some time by our maintainers. (They often send a message in our chatroom to notify contributors of this update). Fortunately, you can see your changes implemented immediately at https://stable.publiclab.org, which builds from the main branch. This is useful for testing your work again after a merge.
