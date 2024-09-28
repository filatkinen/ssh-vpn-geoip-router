#!/bin/bash

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard
cd /etc/wireguard
wg genkey | tee privatekey | wg pubkey > publickey

#Do not forget put keys into the /etc/wireguard/wg0.conf
echo "$CONFIG_BLOCK_CLIENT" >/etc/wireguard/wg0.conf

iptables -A INPUT -i wg+ -j ACCEPT
iptables -A FORWARD -i wg+ -o $INTERFACE_LOCAL_ROUTER -m state --state RELATED,ESTABLISHED -j ACCEPT
iptabes  -A POSTROUTING -s 192.168.0.0/16 -o wg+ -j MASQUERADE

netfilter-persistent save

wg-quick up wg0

systemctl enable wg-quick@wg0