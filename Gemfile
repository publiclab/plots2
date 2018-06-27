source 'https://rubygems.org'
ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '5.2.0'
gem 'activerecord-session_store'
gem 'passenger'
gem 'sidekiq'
gem 'rails-i18n', '~> 5.1.1'
gem 'responders', '~> 2.0'
gem 'turbolinks', '~> 5'
gem 'whenever', require: false
gem 'unicode-emoji'
gem 'gemoji'
gem "composite_primary_keys"
gem 'jquery-rails'
gem 'rdiscount', '~> 2.2', '>= 2.2.0.1'
gem 'will_paginate', '>= 3.0.6'
gem 'will_paginate-bootstrap', '>= 1.0.1'
gem 'georuby', '2.0'
gem 'geokit-rails'
gem 'rails_autolink'
gem 'rb-readline'
gem "paperclip", "~> 5.2.0"
gem "ruby-openid", :require => "openid"
gem "rack-openid"
gem "authlogic", "4.1.0"
gem 'authlogic-oid'
gem "php-serialize", :require => "php_serialize"
gem 'less-rails', '~> 3.0'
gem 'progress_bar'
gem 'impressionist'
gem "recaptcha", require: "recaptcha/rails"
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger', '~> 0.28.0'
gem 'grape-swagger-entity', '= 0.1.5'
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'
gem 'rack-cors', :require => 'rack/cors'
gem 'mocha', '~> 1.1'
gem 'geocoder'
gem "i18n-js", ">= 3.0.0.rc11"
gem 'http_accept_language'
gem 'friendly_id'
gem 'jbuilder', '~> 2.5'
gem 'mustermann' , '1.0.2'
gem 'rails-dom-testing'
gem 'omniauth', '~> 1.3', '>= 1.3.1'
gem 'omniauth-facebook', '~> 4.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-github', '~> 1.1', '>= 1.1.2'
gem 'figaro'
gem 'sanitize'
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
gem 'rails-controller-testing'


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

gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'coffee-rails', '~> 4.2.2'
gem 'execjs' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'
gem 'uglifier', '>= 1.0.3'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem "letter_opener"
  gem "nifty-generators"
  gem 'byebug', platform: :mri
  gem 'rubocop', '~> 0.52.1', require: false
end

group :test, :development do
  gem 'test-unit'
  gem 'rails-perftest'
  gem 'minitest-reporters', '~> 1.1.19'
  gem 'rake',  '~> 12.3.1'
  gem 'rest-client'
  gem 'rspec'
  gem 'json_expressions'
  gem 'timecop'
  gem 'jasmine-rails'
  gem 'jasmine-jquery-rails'
  gem 'coveralls', require: false
  gem 'ci_reporter_test_unit'
  gem 'openssl', '~> 2.0.0.beta.1'
end

group :production do
  gem "scrypt", "~> 3"
end
