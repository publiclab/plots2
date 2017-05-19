install-dev:
	echo "Installing RubyGems"
	bundle install --without production mysql
	echo "Installing Bower Packages"
	bower install
	echo "Copying example configuartions"
	cp db/schema.rb.example db/schema.rb
	cp config/database.yml.sqlite.example config/database.yml
	echo "Setting up the database"
	rake db:setup

setup-complete:
	echo "Installing Ruby"
	rvm install ruby-2.1.2
	echo "Installing Bundler"
	gem install bundler
	echo "Installing Bower"
	yarn global add bower
