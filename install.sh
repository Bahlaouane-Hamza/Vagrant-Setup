#!/usr/bin/env bash

echo "--- Good morning, master. Let's get to work. Installing now. ---"

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties

echo "--- We want the bleeding edge of PHP, right master? ---"
sudo add-apt-repository -y ppa:ondrej/php5

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-intl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql phpmyadmin git-core

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite

echo "--- Setting document root ---"
sudo rm -rf /var/www
sudo ln -fs /vagrant/public /var/www

sudo ln -fs /usr/share/phpmyadmin /vagrant/public/phpmyadmin


echo "--- What developer codes without errors turned on? Not you, master. ---"
# sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
# sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
export TZ="Europe/London"
sudo sed -i "s/^;date.timezone =$/date.timezone = Europe\/London/" /etc/php5/apache2/php.ini
sudo sed -i "s/^;date.timezone =$/date.timezone = Europe\/London/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i "s/html_errors = Off/html_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i "s/track_errors = Off/track_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i "s/short_open_tag = On/short_open_tag = Off/" /etc/php5/apache2/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 20M/" /etc/php5/apache2/php.ini
sudo sed -i "s/max_execution_time = 30/max_execution_time = 0/" /etc/php5/apache2/php.ini

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- Restarting Apache ---"
sudo service apache2 restart
sudo service mysql restart

sudo apt-get clean
echo "--- Composer is the future. But you knew that, did you master? Nice job. ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Laravel stuff here, if you want

echo "--- All set to go! Would you like to play a game? ---"
