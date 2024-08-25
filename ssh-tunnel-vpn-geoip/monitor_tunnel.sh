#!/bin/bash

exec >/var/log/ssh_tunnel_monitor.log 2>&1
# Путь до PID файла
PID_FILE="/tmp/ssh_tunnel.pid"
PATH_START_TUNNEL="/home/fenych/ssh-tunnel/start_tunnel.sh"

# Check if PID exist
if [ ! -f ${PID_FILE} ]; then
  echo "PID not found. Trying one more ."
  "$PATH_START_TUNNEL"
  exit 0
fi

# Reading PID of SSH
SSH_PID=$(cat ${PID_FILE})

# Check if prcess with PID is alive
if ! ps -p ${SSH_PID} > /dev/null; then
  echo "Tunnel is down, trying put it up"
  "$PATH_START_TUNNEL"
else
  echo "Tonnel is working"
fi

