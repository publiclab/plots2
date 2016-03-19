read -p "Enter your cloud9 username: " un
rvm install ruby-2.1.2
rvm 2.1.2
sudo apt-get update
sudo apt-get -y install imagemagick ruby-rmagick
npm install -g bower
bower install
bundle install --without production
rake cloud9 username=$un
echo "Done! Run the application with 'rails s -b \$IP -p \$PORT'"

