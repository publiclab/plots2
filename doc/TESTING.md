(Moved from https://github.com/publiclab/plots2/wiki/Testing)

Run all basic rails tests with `rake test`. This is required for submitting pull requests, and to confirm you have a working local environment.

`rake test:all` runs **all** tests. This includes Jasmine client-side tests and Solr-dependent tests.

### Coverage

See [plots2 on CodeClimate](https://codeclimate.com/github/publiclab/plots2) for how well covered our code is with tests; we are extremely interested in building our out test suite, so please consider helping us write tests! 

### Client-side tests

Client-side tests (for JavaScript functions) are run using [Jasmine](https://jasmine.github.io/) in [jasmine-rails](https://github.com/searls/jasmine-rails). You can run tests by navigating to `/specs/` in the browser. Headless, or command-line test running may be possible with:

`RAILS_ENV=test bundle exec rake spec:javascript`

...[if you have phantomjs installed](#phantomjs-for-javascript-tests) (see above). 

### Solr tests

Solr (search) require [installing the Solr search engine](#solr-search-engine) (see above). Once you've done that, you still need to turn it off in development mode before running tests, with `rake sunspot:solr:stop`. Read more about [this issue here](https://github.com/publiclab/plots2/issues/832#issuecomment-249695309). 

****

If you get stuck on testing at any point, you can _open a pull request with your changes_ -- please add the prefix `[testing]` to the title -- which will then be automatically tested by our TravisCI service -- which runs **all tests** with `rake test:all`. If your additions are pretty basic, and you write tests against them, this may be sufficient without actually running the whole environment yourself! 

