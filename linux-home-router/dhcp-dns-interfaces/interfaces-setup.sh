#!/bin/bash


DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

CONFIG_BLOCK_NETWORK="

auto lo
iface lo inet loopback

# WAN
auto $INTERFACE_WAN
#iface $INTERFACE_WAN inet dhcp

# LAN 
auto $INTERFACE_LAN
iface eth1 inet static
    address $ROUTER_IP
    netmask $NETMASK
    network $NETWORK
    broadcast $BROADCAST

"



echo "$CONFIG_BLOCK_NETWORK" >> /etc/network/interfaces



systemctl restart networking
