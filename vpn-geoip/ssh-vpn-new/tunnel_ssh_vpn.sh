#!/bin/bash

#set -xv

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

TUNNEL_SCRIPT=$(basename "$0")

get_pid_ssh() {
  pid=$(ps aux | grep "ssh" | grep '\-w' | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')
  echo $pid
}

write_log() {
  if [ $USE_LOG = "true" ]; then
    exec > >(stdbuf -oL tee >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_SSH_TUNNEL")) 2>&1
  fi
}

write_log_monitor() {
  if [ $USE_LOG = "true" ]; then
    exec > >(stdbuf -oL awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_SSH_TUNNEL_MONITOR") 2>&1
  else
    exec >/dev/null 2>&1
  fi
}

do_start_tunnel() {
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

  PID=$(get_pid_ssh)
  #   PID=$(ps aux | grep "ssh" | grep '\-w' | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')
  if kill -0 $PID 2>/dev/null; then
    echo "Tunnel is UP, PID="$PID
  else
    echo "Ups, something wrong... Tunnel is down"
  fi
}

do_stop_tunnel() {
  # Find PID
  PID=$(get_pid_ssh)
  #   PID=$(ps aux | grep "ssh" | grep '\-w' | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')

  if kill -0 $PID 2>/dev/null; then
    echo "Found PID ssh tunnel=" $PID
    kill $PID
    echo "Tunnel Stopped "

  else
    echo "Tunnel is down"
  fi
}

monitor_ssh_tunnel() {
  write_log_monitor
  while true; do
    PID=$(get_pid_ssh)
    if ! kill -0 $PID 2>/dev/null; then
      echo "Tunnel is DOWN. Trying to UP.."
      do_start_tunnel
    else
      echo "Tunnel is UP"
    fi
  done
}




if [ -z "$1" ]; then
  echo "use: $0 start/stop"
else
  case $1 in
  start)
    write_log
    echo "Starting...."
    do_start_tunnel
    monitor_ssh_tunnel &
    ;;
  stop)
    write_log
    echo "Stopping...."
    pkill -f $TUNNEL_SCRIPT
    do_stop_tunnel
    ;;
  *)
    echo "Unknown parameter: $1. Please Use: $0 start/stop"
    ;;
  esac
fi
