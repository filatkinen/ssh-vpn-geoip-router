#!/bin/bash

#set -xv

source variables.sh

#send log

write_log() {
  if [ $USE_LOG = "true" ]; then
    exec > >(tee >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_SSH_TUNNEL")) 2>&1
  fi
}

do_start() {
  ssh \
    -o PermitLocalCommand=yes \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -o TCPKeepAlive=yes \
    -o LocalCommand="ifconfig tun0 $LOCAL_IP pointopoint $REMOTE_IP netmask $NETMASK" \
    -p ${REMOTE_PORT} \
    -w 0:0 ${REMOTE_USER}@${REMOTE_HOST} \
    "ifconfig tun0 $REMOTE_IP pointopoint $LOCAL_IP netmask $NETMASK" &

  sleep 2

  PID=$(ps aux | grep "ssh" | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')
  if kill -0 $PID 2>/dev/null; then
    echo "Tunnel is UP, PID="$PID
  else
    echo "Ups, something wrong... Tunnel is down"
  fi
}

do_stop() {
  # Find PID
  PID=$(ps aux | grep "ssh" | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')

  if kill -0 $PID 2>/dev/null; then
    echo "Found PID ssh tunnel=" $PID
    kill $PID
    echo "Tunnel Stopped "

  else
    echo "Tunnel is down"
  fi
}

if [ -z "$1" ]; then
  echo "use: $0 start/stop"
else
  case $1 in
  start)
    echo "Starting...."
    write_log
    do_start
    ;;
  stop)
    echo "Stopping...."
    write_log
    do_stop
    ;;
  *)
    echo "Unknown parameter: $1. Please Use: $0 start/stop"
    ;;
  esac
fi
