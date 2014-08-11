#!/bin/bash
# BootStrap EC2 Web Server
# Version: 140809
# Author: AlphaMusk.com

# Set the default region
REGION='us-west-2'
export AWS_DEFAULT_REGION=${REGION}

# Set default short domiain name, no .com etc
DOMAINNAME='itcloudarchitect'

## SETUP: Get Latest Git code
# Install git
apt-get update -y
apt-get update -y
apt-get install -y git php5 php5-mysql apache2 mysql-client awscli


# Create install directories
rm -rf /root/scripts
mkdir /root/scripts && cd /root/scripts

# Download script
wget https://raw.githubusercontent.com/alphamusk/bootstrap-scripts/master/getLastestGitCode.sh
chmod +x /root/scripts/getLastestGitCode.sh

# Clone latest code for App Client webserver
rm -rf /var/www/html
mkdir -p  /var/www/html
chown -R www-data.www-data /var/www/html
chmod 755 -R /var/www/html
cd /var/www/html && git clone https://github.com/alphamusk/mock-app-client

# Create crontab for getting latest code
codeCMD="/root/scripts/getLastestGitCode.sh /var/www/html https://github.com/alphamusk mock-app-client > /dev/null 2>&1"
job="*/30 * * * * $codeCMD"
cat <(grep -i -v "$codeCMD" <(crontab -l)) <(echo "$job") | crontab -

# Run script once to refresh AppClient webserver code
/root/scripts/getLastestGitCode.sh /var/www/html https://github.com/alphamusk mock-app-client


# Change apache settings
mv -v /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.org
rm -f /etc/apache2/sites-enabled/000-default.conf
touch /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo "<VirtualHost *:80>" 								>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " ServerName www.${DOMAINNAME}.com"				>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " ServerAdmin webmaster@${DOMAINNAME}.com"			>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " DocumentRoot /var/www/html/"						>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " "												>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " <Directory /var/www/html/>"						>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " Options Indexes FollowSymLinks"					>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " AllowOverride None"								>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " Require all granted"								>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " </Directory>"									>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " "												>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " ErrorLog ${APACHE_LOG_DIR}/${DOMAINNAME}_error.log"				>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " CustomLog ${APACHE_LOG_DIR}/${DOMAINNAME}_access.log combined"	>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo " "												>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf
echo "</VirtualHost>"									>> /etc/apache2/sites-enabled/${DOMAINNAME}.conf

cat /etc/apache2/sites-enabled/${DOMAINNAME}.conf

# Git shell scripts
rm -rf /opt
mkdir -p /opt && cd /opt && git clone https://github.com/alphamusk/bootstrap-scripts
/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk bootstrap-scripts
chmod +x /opt/bootstrap-scripts/*.sh

# Register web server with ELB
/opt/bootstrap-scripts/regEC2elb.sh ${REGION} ${DOMAINNAME}-web register

# Other code from S3 itcloudarchitect.com
export AWS_DEFAULT_REGION=${REGION} && aws s3 cp --recursive s3://itcloudarchitect.com-source /var/www/html
chown -R www-data.www-data /var/www/html
chmod 755 -R /var/www/html
echo 'environment=cloud' >> /etc/environment

# Create crontab for getting latest code
codeCMD=" export AWS_DEFAULT_REGION=us-west-2 && aws s3 cp s3://itcloudarchitect.com-source /var/www/html > /dev/null 2>&1"
job="*/30 * * * * $codeCMD"
cat <(grep -i -v "$codeCMD" <(crontab -l)) <(echo "$job") | crontab -


# Restart apache for changes to take affect
apachectl restart



