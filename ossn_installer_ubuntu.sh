#!/bin/bash
# OSSN Installer Script created by
# Matthew Sweet <themattbook@gmail.com>
# This version intended for Ubuntu Server
# 16.04+ and will not work on non-Ubuntu
# distributions.

# Disclaimer
clear
echo ""
echo -e "\e[1m\e[32mOSSN Installer by Matthew Sweet <themattbook@gmail.com>\e[0m"
echo "https://github.com/themattbook/ossninstaller"
echo ""
echo -e "\e[1m\e[31mWARNING:\e[0m THIS SCRIPT WILL OVERWRITE APACHE CONFIGURATION FILES"
echo "AND WILL ONLY WORK ON A FRESH INSTALL OF UBUNTU 16.04 AND HIGHER."
echo ""
echo -e "\e[0mPlease view the \e[1mREADME.md\e[0m on GitHub before continuing. If you feel"
echo "comfortable that all requirements have been met, please proceed."
echo ""
echo "CTRL+C now to abort or press ENTER to continue with the installation."
read -s

# Check system for updates and install required programs
sudo apt update && sudo apt dist-upgrade -y
sudo apt install unzip -y

# Install LAMP packages and create UFW Firewall rules
sudo apt install apache2 -y
sudo ufw allow in "Apache full"
sudo apt install software-properties-common && sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt-get install php8.1
sudo apt-get install libapache2-mod-php8.1 php8.1-fpm libapache2-mod-fcgid php8.1-curl php8.1-dev php8.1-gd php8.1-mbstring php8.1-zip php8.1-mysql php8.1-xml php8.1-json -y
sudo apt install php8.1-{bcmath,common,curl,fpm,gd,intl,mbstring,mysql,soap,xml,xsl,zip,cli}
#mcrypt is no more supported in php 7.3 >
sudo apt-get install openssl
sudo apt-get install mysql-server -y
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '969Development#'"
# Clear screen and update user
clear
echo "Starting MySQL Secure Installation..."
echo ""

# Set up mysql_secure_installation
sudo mysql_secure_installation

# Create directories for OSSN
DOCROOT=/var/www
sudo mkdir $DOCROOT/public_html
sudo mkdir $DOCROOT/ossn_data
sudo rm -rf $DOCROOT/html


# Backup old and create new configuration file for Apache2
APACHE=/etc/apache2/sites-available
sudo cp $APACHE/000-default.conf $APACHE/000-default.conf.bak
sudo rm $APACHE/000-default.conf
cd $APACHE
wget https://raw.githubusercontent.com/KHUNARKARTHEIN/ossninstaller/main/000-default.conf

# Enable mcrypt and mod_rewrite
sudo phpenmod curl
sudo phpenmod xml
sudo phpenmod gd
sudo phpenmod zip
sudo phpenmod mbstring
sudo phpenmod json

sudo a2enmod rewrite

# Restart Apache for changes to take effect
sudo service apache2 restart

# Change directory and install OSSN
cd /var/www/
wget https://github.com/KHUNARKARTHEIN/KA/archive/refs/heads/master.zip
sudo unzip master.zip
sudo mv KA-master/* public_html/
sudo rm -rf master.zip

# Set up MySQL Database
clear
echo "Setting up MySQL Database for OSSN"
echo ""
echo "Please enter your MySQL password: "
read -s PASSWORD
mysql -uroot -p$PASSWORD -e "CREATE DATABASE ossn"

# Set correct ownership and permissions
sudo chgrp www-data $DOCROOT/public_html*
sudo chmod g+w $DOCROOT/public_html*
sudo chown -R www-data:www-data $DOCROOT/public_html
sudo chown -R www-data:www-data $DOCROOT/public_html/*

# Restart Apache for changes to take effect
sudo service apache2 restart

# Install phpmyadmin
sudo apt install phpmyadmin -y

# Finished
clear
echo ""
echo "OSSN Installer has completed the following tasks:"
echo "1. Updated the system"
echo "2. Installed the necessary components for running OSSN"
echo "3. Created the Directories required for installing OSSN"
echo "4. Backed up Apache 000-default.conf and downloaded modified version from ossninstaller repo"
echo "5. Enabled mcrypt and mod_rewrite"
echo "6. Installed current OSSN build to directories"
echo "7. Configured MySQL"
echo "8. Set proper permissions required to read/write OSSN from browser"
echo "9. Installed phpmyadmin for ease of use"
echo "10. Printed this fancy list"
echo ""
echo "For issues, please visit https://github.com/KHUNARKARTHEIN/ossninstaller"
echo ""
echo "That's it! We're done. Open your browser and navigate"
echo "to http://yourserver/ and finish setup"
echo ""
