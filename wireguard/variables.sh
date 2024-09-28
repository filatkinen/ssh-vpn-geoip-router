
REMOTE_PORT=51820
REMOTE_HOST="nl1.fenych.ru"

INTERFACE_SERVER="eth0"
INTERFACE_LOCAL_ROUTER="eth1"

VPN_REMOTE_IP="192.168.150.1"
VPN_LOCAL_IP="192.168.150.2"

CONFIG_BLOCK_SERVER="

[Interface]
# IP-address  WireGuard 
Address = $VPN_REMOTE_IP/24
# Private key server
PrivateKey = <Do not forget put here key>
# port wireguard
ListenPort = $REMOTE_PORT

[Peer]
# Public key client
PublicKey = <Do not forget put here key>
# IP address client
AllowedIPs = $VPN_LOCAL_IP/32
# No endpoint - server is going only to accept connections

"

CONFIG_BLOCK_CLIENT="

[Interface]
# IP-address  WireGuard 
Address = $VPN_LOCAL_IP/24
# Private key server
PrivateKey = <Do not forget put here key>

[Peer]
# Public key server
PublicKey = <Do not forget put here key>
# IP address client
AllowedIPs = $VPN_REMOTE_IP/32
# No endpoint - server is going only to accept connections
Endpoint = $REMOTE_HOST:$REMOTE_PORT
# 
PersistentKeepalive = 25

"
