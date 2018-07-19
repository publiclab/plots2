source 'https://rubygems.org'
ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'activerecord-session_store'
gem "authlogic", "4.1.1"
gem 'authlogic-oid'
gem "composite_primary_keys"
gem 'figaro'
gem 'friendly_id'
gem 'gemoji'
gem 'geocoder'
gem 'geokit-rails'
gem 'georuby', '2.0'
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger', '~> 0.28.0'
gem 'grape-swagger-entity', '= 0.1.5'
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'
gem 'http_accept_language'
gem "i18n-js", ">= 3.0.0.rc11"
gem 'impressionist'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'less-rails', '~> 3.0'
gem 'mocha', '~> 1.1'
gem 'mustermann' , '1.0.2'
gem 'omniauth', '~> 1.3', '>= 1.3.1'
gem 'omniauth-facebook', '~> 4.0'
gem 'omniauth-github', '~> 1.1', '>= 1.1.2'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem "paperclip", "~> 5.2.0"
gem 'passenger'
gem "php-serialize", :require => "php_serialize"
gem 'progress_bar'
gem 'rack-cors', :require => 'rack/cors'
gem "rack-openid"
gem 'rails', '5.2.0'
gem 'rails-controller-testing'
gem 'rails-dom-testing'
gem 'rails-i18n', '~> 5.1.1'
gem 'rails_autolink'
gem 'rb-readline'
gem 'rdiscount', '~> 2.2', '>= 2.2.0.1'
gem "recaptcha", require: "recaptcha/rails"
gem 'responders', '~> 2.0'
gem 'rubocop', '~> 0.52.1', require: false
gem "ruby-openid", :require => "openid"
gem 'sanitize'
gem 'sidekiq'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
gem 'unicode-emoji'
gem 'whenever', require: false
gem 'will_paginate', '>= 3.0.6'
gem 'will_paginate-bootstrap', '>= 1.0.1'

# To implement incoming mail processing microframework
gem 'mailman', require: false

# To convert html to markdown
gem 'reverse_markdown'

# run with `bundle install --without production` or `bundle install --without mysql` to exclude this
group :mysql, :production do
  gem 'mysql2', '>= 0.4.4'
  # mysql 0.4.3+ causes a version mismatch, apparently, and demands 'activerecord-mysql2-adapter'
end

group :sqlite, :development do
  gem 'sqlite3'
end

gem 'coffee-rails', '~> 4.2.2'
gem 'execjs' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'therubyracer'
gem 'uglifier', '>= 1.0.3'

group :development do
  gem 'byebug', platform: :mri
  gem "letter_opener"
  gem 'listen', '~> 3.0.5'
  gem "nifty-generators"
  gem 'web-console', '>= 3.3.0'
end

group :test, :development do
  gem 'ci_reporter_test_unit'
  gem 'coveralls', require: false
  gem 'jasmine-jquery-rails'
  gem 'jasmine-rails'
  gem 'json_expressions'
  gem 'minitest-reporters', '~> 1.1.19'
  gem 'openssl', '~> 2.0.0.beta.1'
  gem 'rails-perftest'
  gem 'rake',  '~> 12.3.1'
  gem 'rest-client'
  gem 'rspec'
  gem 'test-unit'
  gem 'timecop'
end

group :production do
  gem "scrypt", "~> 3"
end
