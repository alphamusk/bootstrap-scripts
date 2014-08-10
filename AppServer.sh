#!/bin/sh

# Kill any php that's running
killall -3 php

# Restart our php script
nohup php AppServer.php &

