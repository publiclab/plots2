build:
	cp config/database.yml.example config/database.yml
	cp db/schema.rb.example db/schema.rb
	docker-compose down --remove-orphans
	docker-compose build

redeploy-container:
	docker-compose build --pull
	docker-compose exec web rake db:migrate
	docker-compose exec web bower install --allow-root
	docker-compose exec web bower update --allow-root
	docker-compose exec web rake assets:precompile
	docker-compose exec web rake tmp:cache:clear
	docker-compose down --remove-orphans
	rm -f ./tmp/pids/server.pid
	docker-compose up -d
	docker-compose exec -T web bash -c "echo 172.19.0.1 smtp >> /etc/hosts"
	docker-compose exec -T mailman bash -c "echo 172.19.0.1 smtp >> /etc/hosts"
	docker-compose exec -T sidekiq bash -c "echo 172.19.0.1 smtp >> /etc/hosts"
	docker-compose exec -T web bundle exec whenever --update-crontab
	docker-compose exec -T web service cron start

deploy-container:
	docker-compose run web sleep 5
	docker-compose run web rake db:migrate
	docker-compose run web bower install --allow-root
	docker-compose run web bower update --allow-root
	docker-compose run web rake assets:precompile
	rm -f ./tmp/pids/server.pid
	docker-compose up -d
	docker-compose exec -T web bash -c "echo 172.19.0.1 smtp >> /etc/hosts"
	docker-compose exec -T mailman bash -c "echo 172.19.0.1 smtp >> /etc/hosts"
	docker-compose exec -T sidekiq bash -c "echo 172.19.0.1 smtp >> /etc/hosts"
	docker-compose exec -T web bundle exec whenever --update-crontab
	docker-compose exec -T web service cron start

test-container:
	docker-compose up -d
	docker-compose exec -T web bundle install
	docker-compose exec -T web rake db:setup
	docker-compose exec -T web rake db:migrate
	docker-compose exec -T web bower install --allow-root
	docker-compose exec -T web rake test:all
	docker-compose exec -T web rails test -d
	docker-compose down

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
