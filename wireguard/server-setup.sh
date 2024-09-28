#!/bin/bash

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard
cd /etc/wireguard
wg genkey | tee privatekey | wg pubkey > publickey

iptables -A INPUT -p udp --dport $REMOTE_PORT -j ACCEPT
