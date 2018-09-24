(Moved from https://github.com/publiclab/plots2/wiki/Testing)

Run all basic rails tests with `rails test -d`. This is **no longer required for submitting pull requests** (see [Pull Requests](#pull-requests), below), and to confirm you have a working local environment.

`rake test:all` runs teaspoon-mocha client-side tests and coverage reporting.

## Pull Requests

[Open a pull request](https://services.github.com/on-demand/github-cli/open-pull-request-github) early, and link it back to the issue you're working on! We run an automatic testing service called Travis on all [pull requests](https://github.com/publiclab/plots2/pulls); this means that it can be easier to simply upload your changes and see how they run in this standard test environment. That way other contributors can see what you've done, and help you out or provide support.

### Working in a pull request

The tests take between 6-12 minutes to run (we're working on shortening this!) so you won't see results immediately, but once you do, we have a bot to try to identify where things went wrong (if anything!). You can also view the complete output of the tests by clicking on the little red X or green checkmark that appears next to your changes, on the pull request page. This can really help in debugging your code! Feel free to keep pushing new commits to the same branch and pull request, and the tests will re-run as many times as you like. We encourage this!

****

## Coverage

See [plots2 on CodeClimate](https://codeclimate.com/github/publiclab/plots2) for how well covered our code is with tests; we are extremely interested in building our out test suite, so please consider helping us write tests!

## Client-side tests

Client-side tests (for JavaScript functions) are run using [teaspoon-mocha](https://github.com/jejacks0n/teaspoon) tests. You can run tests by navigating to `/teaspoon/` in the browser. Headless, or command-line test running may be possible with:


`rake teaspoon`

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

We have three principle branches: a master, where all tested new features are live,
a stable and an unstable. Those last two are used to test new code before sending
them to production.
If you need to use the stable or the unstable branch,
please ask in the chatroom (https://publiclab.org/chat) if someone else is
already using it.
