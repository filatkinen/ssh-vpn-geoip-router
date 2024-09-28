
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
# Внутренний IP-адрес для WireGuard (вы можете выбрать другой, например, 10.0.0.2)
Address = $VPN_LOCAL_IP/24
# Приватный ключ сервера B (клиента)
PrivateKey = <приватный ключ сервера B>
# Порт, на котором будет слушать WireGuard (можно не указывать, если сервер B только инициатор)
ListenPort = 51820

[Peer]
# Публичный ключ сервера A
PublicKey = <публичный ключ сервера A>
# Внутренний IP-адрес сервера A
AllowedIPs = 192.168.100.1/32
# Внешний IP-адрес и порт сервера A
Endpoint = 10.0.0.1:51820
# Поддержание соединения активным для обхода NAT
PersistentKeepalive = 25


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
