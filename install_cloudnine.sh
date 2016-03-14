read -p "Enter your cloud9 username: " un
rvm install ruby-2.1.2
rvm use ruby-2.1.2
sudo apt-get update
sudo apt-get -y install imagemagick ruby-rmagick
mysql-ctl start
bower install
bundle install
rake cloud9 username=$un
rake db:setup
rake db:migrate
rake db:seed
echo "Done! Now, click 'Run Project' at the top of the screen."

