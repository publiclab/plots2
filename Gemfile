source 'https://rubygems.org'
ruby '2.4.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'activerecord-session_store'
gem "authlogic", "4.4.2"
gem 'authlogic-oid'
gem 'coffee-rails', '~> 4.2.2'
gem "composite_primary_keys"
gem 'execjs' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'figaro'
gem 'friendly_id'
gem 'gemoji'
gem 'geocoder'
gem 'geokit-rails'
gem 'georuby', '2.0'
gem 'grape'
gem 'grape-entity'
gem 'grape-rails-cache'
gem 'grape-swagger', '~> 0.32.1'
gem 'grape-swagger-entity', '0.3.3'
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'
gem 'http_accept_language'
gem "i18n-js", ">= 3.0.0.rc11"
gem 'impressionist'
gem 'jbuilder', '~> 2.8'
gem 'jquery-atwho-rails'
gem 'jquery-rails'
gem 'lemmatizer', '~> 0.2.1'
gem 'less-rails', '~> 4.0'
gem 'mailman', require: false # To implement incoming mail processing microframework
gem 'mocha', '~> 1.8'
gem 'mustermann', '1.0.3'
gem 'mysql2', '>= 0.4.4'
gem 'omniauth', '~> 1.9'
gem 'omniauth-facebook', '~> 5.0'
gem 'omniauth-github', '~> 1.1', '>= 1.1.2'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem "paperclip", "~> 6.1.0"
gem 'passenger'
gem "php-serialize", :require => "php_serialize"
gem 'progress_bar'
gem 'rack-cors', :require => 'rack/cors'
gem "rack-openid"
gem "rack-test", "1.1.0"
gem 'rails', '5.2.2'
gem 'rails-controller-testing'
gem 'rails-dom-testing'
gem 'rails-i18n', '~> 5.1.3'
gem 'rails_autolink'
gem 'rb-readline'
gem 'rdiscount', '~> 2.2', '>= 2.2.0.1'
gem "recaptcha", require: "recaptcha/rails"
gem 'responders', '~> 2.4'
gem 'reverse_markdown' # To convert html to markdown
gem "ruby-openid", :require => "openid"
gem 'sanitize'
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'sidekiq'
gem 'skylight' # performance tracking via skylight.io
gem 'therubyracer'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
gem 'uglifier', '>= 1.0.3'
gem 'unicode-emoji'
gem 'whenever', require: false
gem 'will_paginate', '>= 3.0.6'
gem 'will_paginate-bootstrap', '>= 1.0.1'

group :development do
  gem 'byebug', platform: :mri
  gem "letter_opener"
  gem 'listen', '~> 3.1.5'
  gem "nifty-generators"
  gem 'web-console', '>= 3.3.0'
end

group :test, :development do
  gem 'ci_reporter_test_unit'
  gem 'coveralls', require: false
  gem 'jasmine-jquery-rails'
  gem 'jasmine-rails'
  gem 'json_expressions'
  gem 'minitest-reporters', '~> 1.3.6'
  gem 'openssl', '~> 2.1.2'
  gem 'phantomjs'
  gem 'pry-rails'
  gem 'rails-perftest'
  gem 'rake', '~> 12.3.2'
  gem 'rest-client'
  gem 'rubocop', '~> 0.65.0', require: false
  gem 'teaspoon-mocha'
  gem 'test-unit'
  gem 'timecop'
end

group :production do
  gem "scrypt", "~> 3"
end
