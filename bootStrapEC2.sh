#!/bin/bash
# BootStrapEC2
# Version: 140809
# Author: AlphaMusk.com

## SETUP: Get Latest Git code
# Install git
apt-get install -y git


# Create install directories
rm -rf /root/scripts
mkdir -p /root/scripts && cd /root/scripts

# Download script
rm -f /root/scripts/getLastestGitCode.sh && wget https://raw.githubusercontent.com/alphamusk/bootstrap-scripts/master/getLastestGitCode.sh
chmod +x /root/scripts/getLastestGitCode.sh

# Clone latest code for AppServer
rm -rf /opt/
mkdir -p /opt && cd /opt && git clone https://github.com/alphamusk/mock-app-server

# Create crontab for getting latest code
codeCMD="/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk mock-app-server > /dev/null 2>&1"
job="*/15 * * * * $codeCMD"
cat <(grep -i -v "$codeCMD" <(crontab -l)) <(echo "$job") | crontab -

# Run script once to grab AppServer code
/root/scripts/getLastestGitCode.sh /opt https://github.com/alphamusk mock-app-server

