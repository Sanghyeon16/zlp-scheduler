# Steps to run ZLP on ubuntu-C9

# 1. Create a new c9 Ubuntu instance, it requires some disk space
# 2. follow the below command

git clone https://github.com/tamu-zlp/zlp-scheduler
cd zlp-scheduler/zlp-scheduler
#Remember to delete document fold to avoid memory exceed
gem install bundler:2.1.4

sudo apt-get install libpq-dev
# if you get (11: Resource temporarily unavailable), wait 5 minutes, the machine is still configuring itself
bundle install

# Install postgresql, it will run automatically after install
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install postgresql-10 pgadmin4

# If you are using c9+ubuntu, you should create a PG user called ubuntu
sudo -u postgres createuser --interactive
#set user name as "ubuntu"
#Select Yes


# Setup for run the script
wget https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz
tar -zxvf geckodriver-v0.27.0-linux64.tar.gz
sudo mv geckodriver /usr/local/bin/
rm geckodriver-v0.27.0-linux64.tar.gz

sudo apt-get install firefox


rake db:setup
rails s