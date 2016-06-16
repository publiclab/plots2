source 'https://rubygems.org'

ruby '2.1.2'
gem 'rails', '~> 3.2.20'
gem 'passenger'

gem 'rails-i18n', '~> 3.0.0'

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
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'execjs' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

# run with `bundle install --without development` to exclude these
group :development do
  gem "nifty-generators"
end

# run with `bundle install --without test` to exclude these
group :test do
  gem 'test-unit'
  gem 'rake',  '~> 10.5.0'
end

# run with `bundle install --without production` to exclude these
group :production do
  gem "scrypt", "~> 1.2.1"
end

gem 'composite_primary_keys'
gem 'jquery-rails'
gem 'rdiscount', '1.6.8' # Markdown
gem 'will_paginate', '>= 3.0.6'
gem 'will_paginate-bootstrap', '>= 1.0.1'
gem 'georuby', '2.0'
gem 'geokit-rails'
gem 'rails_autolink'
gem 'rb-readline'
gem "paperclip", ">= 4.1.1"
gem "ruby-openid", :require => "openid"
gem "rack-openid"
gem "authlogic", "3.2.0"
gem "php-serialize", :require => "php_serialize"
gem 'less-rails',   '~> 2.6'


# RESTful API Support
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape-swagger-rails'
gem 'grape-swagger-ui'
gem 'rack-cors', :require => 'rack/cors'

>>>>>>> Successful RESTful search call for typeahead
gem 'mocha', '~> 1.1'
gem 'jasmine-rails'
gem 'jasmine'
gem 'jasmine-jquery-rails'
gem 'strong_parameters'
gem 'sunspot_rails'
gem 'sunspot_solr'

