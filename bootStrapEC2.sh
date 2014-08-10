#!/bin/bash
# BootStrapEC2
# Version: 140809
# Author: AlphaMusk.com

## SETUP: Get Latest Git code
# Install git
apt-get install -y git


# Create install directories
mkdir -p /root/scripts && cd /root/scripts

# Download script
rm -f getLastestGitCode.sh && wget https://github.com/alphamusk/bootstrap-scripts/blob/master/getLastestGitCode.sh
chmod +x /root/scripts/getLastestGitCode.sh

# Clone latest code for AppServer
cd /var/www/html && git clone https://github.com/alphamusk/mock-app-server

# Create crontab for getting latest code
codeCMD="/root/scripts/getLastestGitCode.sh /var/www/html https://github.com/alphamusk/mock-app-server > /dev/null 2>&1"
job="*/15 * * * * $codeCMD"
cat <(grep -i -v "$codeCMD" <(crontab -l)) <(echo "$job") | crontab -

# Run script once to grab AppServer code
/root/scripts/getLastestGitCode.sh /var/www/html https://github.com/alphamusk/mock-app-server

## SETUP: Get AppServer
cd 