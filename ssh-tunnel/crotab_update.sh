#!/bin/bash

source variables.sh

echo "*/5 * * * * root $PATH_MONITOR" >> /etc/crontab
service cron reload 

