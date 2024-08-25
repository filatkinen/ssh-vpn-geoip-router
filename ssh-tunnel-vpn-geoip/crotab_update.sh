#!/bin/bash

PATH_MONITOR="/home/fenych/ssh-tunnel/monitor_tunnel.sh"

echo "*/5 * * * * root $PATH_MONITOR" >> /etc/crontab
service cron reload 

