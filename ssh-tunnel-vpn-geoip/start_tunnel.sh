#!/bin/bash

#send log 
exec > >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >> /var/log/ssh_tunnel.log) 2>&1


REMOTE_USER="root"
REMOTE_HOST="nl1.fenych.ru"
REMOTE_PORT="22"
LOCAL_IP="192.168.150.2"
REMOTE_IP="192.168.150.1"
NETMASK="255.255.255.0"


# stsrting SSH-tunnel
ssh \
  -o PermitLocalCommand=yes \
  -o LocalCommand="ifconfig tun0 $LOCAL_IP pointopoint $REMOTE_IP netmask $NETMASK" \
  -p ${REMOTE_PORT} \  
  -w 0:0 ${REMOTE_USER}@${REMOTE_HOST} \
  "ifconfig tun0 $REMOTE_IP pointopoint $LOCAL_IP netmask $NETMASK; echo tun0 ready"  &


# Saving PID  SSH 
echo $! > /tmp/ssh_tunnel.pid

if [ $? -eq 0 ]; then
    echo "SSH VPN- is up."
    exit 0
else
    echo "VPN down with error"
    exit 1
fi

