#!/bin/bash

apt install dnsmasq -y

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

NODHCP="no-dhcp-interface=$INTERFACE_WAN"
CONFIG_BLOCK=${CONFIG_BLOCK}${NODHCP}



echo "$CONFIG_BLOCK" > /etc/dnsmasq.d/router.conf


#Example static lease 
#echo "dhcp-host=fc:01:7c:49:eb:13,192.168.11.196" >> /etc/dnsmasq.d/hosts-static.conf
#echo "dhcp-host=fc:01:7c:49:eb:13,brother-printer" >> /etc/dnsmasq.d/hosts-static.conf




systemctl enable dnsmasq
systemctl restart dnsmasq
