# updated for AWS Cloud9 with Amazon Linux Platform

read -p "Enter your cloud9 username: " un
rvm install ruby-2.4.4
source $(rvm 2.4.4 do rvm env --path)
bash -l -c "rvm use ruby-2.4.4"
gem install rails -v 5.2.0
sudo yum -y update
sudo yum install -y ImageMagick-devel 
gem install rmagick
sudo yum install -y redis
npm install -g yarn
yarn install
gem install bundler
bundle install --without production mysql
cp db/schema.rb.example db/schema.rb
cp config/database.yml.sqlite.example config/database.yml
rake db:setup
rake cloud9 username=$un
echo "Done! 1. Change directory out then back into plots2/
      2. Start the redis-server with 'redis-server'
      3. Run SideKiq: 'bundle exec sidekiq'
      4. Run the application with 'rails s -b \$IP -p \$PORT'"
