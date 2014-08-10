#!/bin/sh

# Kill any php that's running
killall -3 php

# Restart our php script
nohup php AppServer.php &


# Schedule in Crontab
(crontab -l; echo '*/10 * * * * /opt/AppServer.sh') | crontab -
