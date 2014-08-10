#!/bin/sh
# Start PHP AppServer
# Version: 140809
# Author: AlphaMusk.com

# Kill any php that's running
killall -9 php

# Restart our php script
nohup php /opt/mock-app-server/AppServer.php &

