#!/bin/bash
# BootStrap EC2 App Server
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
apt-get install -y git php5 php5-mysql mysql-client awscli


# Create install directories
rm -rf /root/scripts
mkdir -p /root/scripts && cd /root/scripts

# Download script
rm -f /root/scripts/getLastestGitCode.sh && wget https://raw.githubusercontent.com/alphamusk/bootstrap-scripts/master/getLastestGitCode.sh
chmod +x /root/scripts/getLastestGitCode.sh

# Clone latest code for AppServer
rm -rf /opt
mkdir -p /opt
# rm -rf /var/www/html
# mkdir -p  /var/www/html
# chown -R www-data.www-data /var/www/html
# chmod 755 -R /var/www/html
cd /opt && git clone https://github.com/alphamusk/mock-app-server

# Create crontab for getting latest code
codeCMD="/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk mock-app-server > /dev/null 2>&1"
job="*/10 * * * * $codeCMD"
cat <(grep -i -v "$codeCMD" <(crontab -l)) <(echo "$job") | crontab -

# Run script once to grab AppServer appserver code
/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk mock-app-server


# Git shell scripts
cd /opt && git clone https://github.com/alphamusk/bootstrap-scripts
/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk bootstrap-scripts
chmod +x /opt/bootstrap-scripts/*.sh

# Register web server with ELB
/opt/bootstrap-scripts/regEC2elb.sh ${REGION} ${DOMAINAME}-app register

# Other code from S3 itcloudarchitect.com
# export AWS_DEFAULT_REGION=${REGION} && aws s3 cp --recursive s3://itcloudarchitect.com-source /var/www/html
# chown -R www-data.www-data /var/www/html
# chmod 755 -R /var/www/html
# echo 'environment=cloud' >> /etc/environment

# Create crontab for running app server
serverCMD="/opt/bootstrap-scripts/AppServer.sh > /dev/null 2>&1"
job="*/1 * * * * $serverCMD"
cat <(grep -i -v "$serverCMD" <(crontab -l)) <(echo "$job") | crontab -


# Restart apache for changes to take affect
# apachectl restart

# Start AppServer
/opt/bootstrap-scripts/AppServer.sh > /dev/null 2>&1
netstat -antpu | grep 9001
