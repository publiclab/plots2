build:
	cp config/database.yml.example config/database.yml
	cp db/schema.rb.example db/schema.rb
	docker-compose down --remove-orphans
	docker-compose build

redeploy-container:
	docker-compose build --pull
	docker-compose run --rm web yarn install
	docker-compose run --rm web bash -c "rake db:migrate && rake assets:precompile && rake tmp:cache:clear"
	docker-compose down --remove-orphans
	rm -f ./tmp/pids/server.pid
	docker-compose up -d
	docker-compose exec -T web bash -c "echo 172.17.0.1 smtp >> /etc/hosts"
	docker-compose exec -T mailman bash -c "echo 172.17.0.1 smtp >> /etc/hosts"
	docker-compose exec -T sidekiq bash -c "echo 172.17.0.1 smtp >> /etc/hosts"
	docker-compose exec -T web bundle exec whenever --update-crontab
	docker-compose exec -T web service cron start

deploy-container:
	docker-compose run --rm web yarn install
	docker-compose run --rm web bash -c "sleep 5 && rake db:migrate && rake assets:precompile"
	rm -f ./tmp/pids/server.pid
	docker-compose up -d
	docker-compose exec -T web bash -c "echo 172.17.0.1 smtp >> /etc/hosts"
	docker-compose exec -T mailman bash -c "echo 172.17.0.1 smtp >> /etc/hosts"
	docker-compose exec -T sidekiq bash -c "echo 172.17.0.1 smtp >> /etc/hosts"
	docker-compose exec -T web bundle exec whenever --update-crontab
	docker-compose exec -T web service cron start

test-container:
	docker-compose up -d
	docker-compose exec -T web rake db:setup
	docker-compose exec -T web rake db:migrate
	docker-compose exec -T web yarn install
	docker-compose exec -T web rake assets:precompile
	docker-compose exec -T web rake test:all
	docker-compose exec -T web rails test -d
	docker-compose down

install-dev:
	echo "Installing RubyGems"
	bundle install --without production mysql
	echo "Installing yarn Packages"
	yarn install
	echo "Copying example configuartions"
	cp db/schema.rb.example db/schema.rb
	cp config/database.yml.sqlite.example config/database.yml
	echo "Setting up the database"
	rake db:setup

setup-complete:
	echo "Installing Ruby"
	rvm install ruby-2.4.4
	echo "Installing Bundler"
	gem install bundler
