source 'https://rubygems.org'
ruby '2.3.7'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '5.0.6'


#Use Puma as the app server
gem 'puma', '~> 3.0'

gem 'activerecord-session_store'
# gem 'protected_attributes'
gem 'passenger'

gem 'rails-i18n', '~> 5.1.1'
gem 'responders', '~> 2.0' # for Rails 4.2

gem 'turbolinks', '~> 5'

# Whenever provides a clear syntax for writing and deploying cron jobs
gem 'whenever', require: false

# run with `bundle install --without production` or `bundle install --without mysql` to exclude this
group :mysql, :production do
  gem 'mysql2', '~> 0.3.20'
  # mysql 0.4.3+ causes a version mismatch, apparently, and demands 'activerecord-mysql2-adapter'
end

# ships with sqlite set up for easy setup during development
# run with `bundle install --without development` or `bundle install --without sqlite` to exclude this
group :sqlite, :development do
  gem 'sqlite3'
end

#group :postgresql do
#  gem "activerecord-postgresql-adapter"
#end

# Gems used only for assets and not required in production environments by default.
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'coffee-rails', '~> 4.2.2'
gem 'execjs' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'
gem 'uglifier', '>= 1.0.3'

# run with `bundle install --without development` to exclude these
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem "letter_opener"
  gem "nifty-generators"
  gem 'byebug', platform: :mri
  gem 'rubocop', '~> 0.52.1', require: false
end

# run with `bundle install --without test` to exclude these
group :test, :development do
  gem 'test-unit'
  gem 'rails-perftest'
  gem 'minitest-reporters', '~> 1.1.19'
  gem 'rake',  '~> 12.3.1'
  # gems to test RESTful API
  gem 'rest-client'
  gem 'rspec'
  gem 'json_expressions'
  gem 'timecop'
  gem 'jasmine-rails'
  gem 'jasmine-jquery-rails'
  gem 'coveralls', require: false
  gem 'ci_reporter_test_unit'
end

# run with `bundle install --without production` to exclude these
group :production do
  gem "scrypt", "~> 3"
end

gem 'unicode-emoji'
gem 'gemoji'

gem "composite_primary_keys"
gem 'jquery-rails'
gem 'rdiscount', '~> 2.2', '>= 2.2.0.1' # Markdown
gem 'will_paginate', '>= 3.0.6'
gem 'will_paginate-bootstrap', '>= 1.0.1'
# could be deprecated:
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
gem 'less-rails',   '~> 2.6'
gem 'progress_bar'
gem 'impressionist'
gem "recaptcha", require: "recaptcha/rails"

# RESTful API Support
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger', '~> 0.28.0' # later versions require
gem 'grape-swagger-entity', '= 0.1.5' # Ruby 2.2 or later
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'
gem 'rack-cors', :require => 'rack/cors'

gem 'mocha', '~> 1.1'

gem 'geocoder'
gem "i18n-js", ">= 3.0.0.rc11"
gem 'http_accept_language'

# The default friendly_id version compatible with Rails 3 is v4.0
gem 'friendly_id'
gem 'jbuilder', '~> 2.5'

gem 'strong_parameters'

# Pin mustermann to Ruby 2.1 compatible
gem 'mustermann' , '1.0.2'

#Gem for assertions used in testing
gem 'rails-dom-testing'
#OAuth Based login
gem 'omniauth', '~> 1.3', '>= 1.3.1'
gem 'omniauth-facebook', '~> 3.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-github', '~> 1.1', '>= 1.1.2'

#Gem for making tableless models
#gem 'activerecord-tableless'
gem 'figaro'
gem 'sanitize'
#Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
