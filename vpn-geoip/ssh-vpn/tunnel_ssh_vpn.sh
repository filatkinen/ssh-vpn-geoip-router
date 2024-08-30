#!/bin/bash

#set -xv

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

TUNNEL_SCRIPT=$(basename "$0")

current_date() {
  echo $(date +"%Y.%m.%d-%H:%M:%S")
}

get_pid_ssh() {
  pid=$(ps aux | grep "ssh" | grep '\-w' | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')
  echo $pid
}

write_memo_logging() {
  echo "Tunnel log here: $LOG_SSH_TUNNEL"
}

write_log() {
  if [ $USE_LOG = "true" ]; then
    date=$(current_date)
    echo "$date $1" >>$LOG_SSH_TUNNEL 2>&1
  fi
}

write_log_monitor() {
  if [ $USE_LOG = "true" ]; then
    date=$(current_date)
    echo "$date $1" >>$LOG_SSH_TUNNEL 2>&1
  fi
}

do_start_tunnel() {

  # #delete old interface interface at vpn host
  # ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} \
  #   "if ! ip addr | grep $VPN 2>/dev/null; then
  #       sudo ip link delete $VPN
  #   fi"

  ssh \
    -o PermitLocalCommand=yes \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -o TCPKeepAlive=yes \
    -o LocalCommand="ifconfig $VPN $LOCAL_IP pointopoint $REMOTE_IP netmask $NETMASK" \
    -p ${REMOTE_PORT} \
    -w 0:0 ${REMOTE_USER}@${REMOTE_HOST} \
    "ifconfig $VPN $REMOTE_IP pointopoint $LOCAL_IP netmask $NETMASK" &>>$LOG_SSH_TUNNEL &

  sleep 2

  PID=$(get_pid_ssh)

  if kill -0 $PID 2>/dev/null; then
    write_log "Tunnel is UP, PID=$PID"
  else
    write_log "Ups, something wrong... Tunnel is down"
  fi
}

do_stop_tunnel() {

  PID=$(get_pid_ssh)

  if kill -0 $PID 2>/dev/null; then
    write_log "Found PID ssh tunnel=$PID"
    kill $PID
    write_log "Tunnel Stopped "

  else
    write_log "Tunnel is down"
  fi
}

monitor_ssh_tunnel() {
  write_log_monitor "Starting monitor ssh vpn. Checking every  $TIME_TO_CHECK seconds"
  while true; do
    PID=$(get_pid_ssh)
    if ! kill -0 $PID 2>/dev/null; then
      write_log_monitor "Tunnel is DOWN. Trying to UP.."
      do_start_tunnel
    fi
    sleep $TIME_TO_CHECK
  done
}

if [ -z "$1" ]; then
  echo "use: $0 start/stop"
else
  case $1 in
  start)
    echo "Starting...."
    do_start_tunnel
    monitor_ssh_tunnel &
    write_memo_logging
    ;;
  stop)
    echo "Stopping...."
    pkill -f $TUNNEL_SCRIPT
    do_stop_tunnel
    write_memo_logging
    ;;
  *)
    echo "Unknown parameter: $1. Please Use: $0 start/stop"
    ;;
  esac
fi
