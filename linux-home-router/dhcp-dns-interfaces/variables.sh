
SUB_NUM=12

ROUTER_IP="192.168.$SUB_NUM.1"
NETMASK="255.255.255.0"
POOL_START="192.168.$SUB_NUM.50"
POOL_END="192.168.$SUB_NUM.190"
BROADCAST="192.168.$SUB_NUM.255"
NETWORK="192.168.$SUB_NUM.0"

CONFIG_BLOCK_DHCP_DNS="
filterwin2k
bogus-priv
server=8.8.8.8
server=8.8.4.4
server=1.1.1.1
server=1.0.0.1

#comment if you want to use system resolver. Be carefull. Some russians providers mangle and filter records  
no-resolv
no-poll
no-hosts


# Disable AAAA (IPv6) DNS records resolution
filter-AAAA

dhcp-range=$POOL_START,$POOL_END,120h
dhcp-option=option:dns-server,$ROUTER_IP
dhcp-option=option:ntp-server,$ROUTER_IP
#mask
dhcp-option=1,$NETMASK
#broadcastt
dhcp-option=28,$BROADCAST
#gateway
dhcp-option=3,$ROUTER_IP

"

