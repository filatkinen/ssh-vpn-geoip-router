#!/bin/bash

apt install dnsmasq -y

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

NODHCP="no-dhcp-interface=$INTERFACE_WAN"
CONFIG_BLOCK_DHCP=${CONFIG_BLOCK_DHCP}${NODHCP}



echo "$CONFIG_BLOCK_DHCP" > /etc/dnsmasq.d/router.conf


#Example static lease 
#echo "dhcp-host=FC:01:7C:49:EB:13,192.168.11.196" >> /etc/dnsmasq.d/hosts-static.conf
#echo "dhcp-host=FC:01:7C:49:EB:13,HomeBrother2520WiFi" >> /etc/dnsmasq.d/hosts-static.conf
#echo "" >> /etc/dnsmasq.d/hosts-static.conf
#echo "dhcp-host=B8:69:F4:F0:A9:80,192.168.11.149" >> /etc/dnsmasq.d/hosts-static.conf
#echo "dhcp-host=B8:69:F4:F0:A9:80,MikroTik-hAP2" >> /etc/dnsmasq.d/hosts-static.conf




systemctl enable dnsmasq
systemctl restart dnsmasq
