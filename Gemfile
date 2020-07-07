source 'https://rubygems.org'
ruby '2.4.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'activerecord-session_store'
gem "authlogic", "4.4.2"
gem 'authlogic-oid'
gem "composite_primary_keys"
gem 'figaro'
gem 'friendly_id'
gem 'gemoji'
gem 'geocoder'
gem 'geokit-rails'
gem 'georuby', '2.0'
gem "google-cloud-storage"
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger', '~> 1.2.0'
gem 'grape-swagger-entity', '0.3.4'
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'
gem 'http_accept_language'
gem "i18n-js", ">= 3.0.0.rc11"
gem 'impressionist'
gem 'jbuilder', '~> 2.10'
gem 'jquery-rails'
gem 'less-rails', '~> 5.0'
gem 'mocha', '~> 1.11'
gem 'mustermann' , '1.1.1'
gem 'omniauth', '~> 1.9'
gem 'omniauth-facebook', '~> 6.0'
gem 'omniauth-github', '~> 1.4'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem "paperclip", "~> 6.1.0"
gem 'passenger'
gem "php-serialize", :require => "php_serialize"
gem 'progress_bar'
gem 'rack-cors', :require => 'rack/cors'
gem "rack-openid"
gem "rack-test", "1.1.0"
gem 'rails', '5.2.3'
gem 'rails-controller-testing'
gem 'rails-dom-testing'
gem 'rails-i18n', '~> 5.1.3'
gem 'rails_autolink'
gem 'rb-readline'
gem 'rdiscount', '~> 2.2', '>= 2.2.0.1'
gem "recaptcha", require: "recaptcha/rails"
gem 'responders', '~> 3.0'
gem 'rubocop', '~> 0.86.0', require: false
gem "ruby-openid", :require => "openid"
gem 'sanitize'
gem 'sentry-raven'
gem 'sidekiq'
gem 'skylight' # performance tracking via skylight.io
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
gem 'unicode-emoji'
gem 'whenever', require: false
gem 'will_paginate', '>= 3.0.6'
gem 'will_paginate-bootstrap4'
gem 'jquery-atwho-rails'
gem 'lemmatizer', '~> 0.2.2'
# To implement incoming mail processing microframework
gem 'mailman', require: false
# To implement fontawesome v4.7.0
gem "font-awesome-rails"
 gem "lazyload-rails"

# To convert html to markdown
gem 'reverse_markdown'

gem 'twitter'

# To impliment Datatables
gem 'jquery-datatables'

# run with `bundle install --without production` or `bundle install --without mysql` to exclude this
group :mysql, :production do
  gem 'mysql2', '>= 0.4.4'
  # mysql 0.4.3+ causes a version mismatch, apparently, and demands 'activerecord-mysql2-adapter'
end

group :sqlite, :development do
  gem 'sqlite3', '~> 1.3.6'
end

gem 'coffee-rails', '~> 5.0.0'
gem 'execjs' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'sassc-rails'
gem 'therubyracer'
gem 'uglifier', '>= 1.0.3'
gem 'grape-rails-cache'

group :development do
  gem 'byebug', platform: :mri
  gem "letter_opener"
  gem 'listen', '~> 3.2.1'
  gem "nifty-generators"
  gem 'web-console', '>= 3.3.0'
end

group :test, :development do
  gem 'capybara'
  gem 'ci_reporter_test_unit'
  gem 'simplecov', require: false
  gem 'codecov', require: false
  gem 'jasmine-jquery-rails'
  gem 'jasmine-rails'
  gem 'json_expressions'
  gem 'minitest-reporters', '~> 1.4.2'
  gem 'openssl', '~> 2.2.0'
  gem 'phantomjs'
  gem 'puma', '~> 4.3'
  gem 'rails-perftest'
  gem 'rake', '~> 13.0.1'
  gem 'rest-client'
  gem 'rspec'
  gem 'selenium-webdriver', '~> 3.142.7'
  gem 'test-unit'
  gem 'teaspoon-mocha'
  gem 'timecop'
  gem 'pry-rails'
  gem 'action-cable-testing'
  gem "webmock", "~> 3.8"
end

group :production do
  gem "scrypt", "~> 3"
end
