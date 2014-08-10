#!/bin/sh

# Kill any php that's running
killall -9 php

# Restart our php script
nohup php /opt/mock-app-server/AppServer.php &

