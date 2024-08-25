#!/bin/bash

#set -xv
source variables.sh

exec > >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >> $LOG_SSH_TUNNEL_MONITOR) 2>&1

# Find PID 
PID=$(ps aux | grep "ssh"|grep ${REMOTE_USER}@${REMOTE_HOST}|awk '{print $2}')

if kill -0 $PID 2>/dev/null; then
    echo "Found PID ssh tunnel=" $PID

    kill $PID
    echo "Tunnel Stopped "

else
    echo "Tunnel is down"
fi