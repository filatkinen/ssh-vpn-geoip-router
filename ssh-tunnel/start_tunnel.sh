#!/bin/bash

#set -xv

source variables.sh


#send log 
exec > >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >> $LOG_SSH_TUNNEL) 2>&1


# starting SSH-tunnel
ssh \
  -o PermitLocalCommand=yes \
  -o ServerAliveInterval=300 \
  -o ServerAliveCountMax=10 \
  -o TCPKeepAlive=yes \
  -o LocalCommand="ifconfig tun0 $LOCAL_IP pointopoint $REMOTE_IP netmask $NETMASK" \
  -p ${REMOTE_PORT} \
  -w 0:0 ${REMOTE_USER}@${REMOTE_HOST} \
  "ifconfig tun0 $REMOTE_IP pointopoint $LOCAL_IP netmask $NETMASK; echo tun0 ready"  &

