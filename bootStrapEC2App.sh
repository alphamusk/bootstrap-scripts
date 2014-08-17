#!/bin/bash
# BootStrap EC2 App Server, Ubuntu
# Version: 140809, 140816
# Author: AlphaMusk.com
# Bootstrap cmd: wget -qO- https://your-url/bootStrapEC2App.sh | bash


# Set the default region
REGION='us-west-2'
export AWS_DEFAULT_REGION=${REGION}

# Set default short domiain name, no .com etc
DOMAINNAME='itcloudarchitect'
TIER='app'

## SETUP: Get Latest Git code
# Install git
apt-get update -y
apt-get update -y
apt-get install -y git php5 php5-mysql mysql-client awscli

# Create install directories
rm -rf /root/scripts
mkdir -p /root/scripts && cd /root/scripts

# Download script
wget https://raw.githubusercontent.com/alphamusk/bootstrap-scripts/master/getLastestGitCode.sh
chmod +x /root/scripts/*.sh

# Clone latest code for AppServer
rm -rf /opt
mkdir /opt && cd /opt && git clone https://github.com/alphamusk/mock-app-server

# Create crontab for getting latest code every xx minutes
codeCMD="/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk mock-app-server > /dev/null 2>&1"
job="*/30 * * * * ${codeCMD}"
cat <(grep -i -v "${codeCMD}" <(crontab -l)) <(echo "${job}") | crontab -

# Run script once to grab AppServer appserver code
/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk mock-app-server


# Git bash shell scripts
cd /opt && git clone https://github.com/alphamusk/bootstrap-scripts
/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk bootstrap-scripts
chmod +x /opt/bootstrap-scripts/*.sh

# Register web server with ELB
/opt/bootstrap-scripts/regEC2elb.sh ${REGION} ${DOMAINNAME}-${TIER} register

# Create crontab for running app server
serverCMD="/opt/bootstrap-scripts/AppServer.sh > /dev/null 2>&1"
job="*/30 * * * * ${serverCMD}"
cat <(grep -i -v "${serverCMD}" <(crontab -l)) <(echo "${job}") | crontab -


# Start AppServer
/opt/bootstrap-scripts/AppServer.sh > /dev/null 2>&1

# Check to see if it is listening on port xxxx
netstat -antpu | grep 9001
