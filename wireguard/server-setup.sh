#!/bin/bash

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard
cd /etc/wireguard
wg genkey | tee privatekey | wg pubkey > publickey

iptables -A INPUT -p udp --dport $REMOTE_PORT -j ACCEPT
iptables -A INPUT -i wg+ -j ACCEPT
iptables -A FORWARD -i wg0+ -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o wg0+ -m state --state RELATED,ESTABLISHED -j ACCEPT


#Do not forget put keys into the /etc/wireguard/wg0.conf
echo "$CONFIG_BLOCK_SERVER" >/etc/wireguard/wg0.conf

wg-quick up wg0

systemctl enable wg-quick@wg0

