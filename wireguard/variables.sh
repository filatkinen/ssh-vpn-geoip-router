
REMOTE_PORT=51820
REMOTE_HOST="nl1.fenych.ru"

VPN_REMOTE_IP="192.168.150.1"
VPN_LOCAL_IP="192.168.150.2"

CONFIG_BLOCK_SERVER="

[Interface]
# IP-address  WireGuard 
Address = $VPN_REMOTE_IP/24
# Private key server
PrivateKey = /etc/wireguard/privatekey
# port wireguard
ListenPort = $REMOTE_PORT

[Peer]
# Public key client
PublicKey = /etc/wireguard/peer/publickey
# IP address client
AllowedIPs = $VPN_LOCAL_IP/32
# No endpoint - server is going only to accept connections

"

CONFIG_BLOCK_CLIENT="

[Interface]
# IP-address  WireGuard 
Address = $VPN_LOCAL_IP/24
# Private key server
PrivateKey = /etc/wireguard/privatekey

[Peer]
# Public key server
PublicKey = /etc/wireguard/peer/publickey
# IP address client
AllowedIPs = $VPN_REMOTE_IP/32
# No endpoint - server is going only to accept connections
Endpoint = $REMOTE_HOST:$REMOTE_PORT
# 
PersistentKeepalive = 25

"
