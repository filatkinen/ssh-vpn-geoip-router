#!/bin/bash

apt install isc-dhcp-server -y

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"



# Append the configuration block to the /etc/dhcp/dhcpd.conf file
echo "$CONFIG_BLOCK" >> /etc/dhcp/dhcpd.conf


sed -i '/^INTERFACESv4=/s/^/#/' /etc/default/isc-dhcp-server
echo "INTERFACESv4=\"$INTERFACE_LOCAL\"" | sudo tee -a /etc/default/isc-dhcp-server > /dev/null


systemctl enable isc-dhcp-server
systemctl restart isc-dhcp-server
