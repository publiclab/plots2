source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.2'
gem 'rails', '3.2.20'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Database handling
#group :sqlite do
#  gem 'sqlite3'
#end
group :mysql do
  gem 'mysql2'
end
# TODO support postgresql
#group :postgresql do
#  gem "activerecord-postgresql-adapter"
#end

# Support composite primary keys
gem 'composite_primary_keys'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'less-rails',   '~> 2.6'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'passenger'

gem 'execjs'
gem 'therubyracer'
#gem 'secondbase', '0.5.0'
gem 'rdiscount', '1.6.8'
gem 'will_paginate'
gem 'will_paginate-bootstrap', '0.2.5'
gem 'georuby', '2.0'
gem 'geokit-rails'
gem 'spatial_adapter', :git => 'https://github.com/descentintomael/spatial_adapter.git'
gem 'rails_autolink'
gem 'rb-readline'
gem "paperclip", ">= 4.1.1"

gem "nifty-generators", :group => :development
gem "ruby-openid", :require => "openid"
gem "rack-openid"
gem "authlogic", "3.2.0"
#gem "authlogic-oid", :require => "authlogic_openid"
gem "php-serialize", :require => "php_serialize"

gem "scrypt", "~> 1.2.1"

group :development, :test do
  #gem 'rspec-rails'
  gem 'factory_girl_rails'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

#gem "mocha", :group => :test
