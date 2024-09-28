#!/bin/bash

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard
cd /etc/wireguard
wg genkey | tee privatekey | wg pubkey > publickey

echo "$CONFIG_BLOCK_CLIENT" >/etc/wireguard/wg0.conf

wg-quick up wg0

systemctl enable wg-quick@wg0