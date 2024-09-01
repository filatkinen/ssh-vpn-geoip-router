
INTERFACE="eth1"
SUB_NUM=12

ROUTER_IP="192.168.$SUB_NUM.1"
NETMASK="255.255.255.0"
POOL_START="192.168.$SUB_NUM.100"
POOL_END="192.168.$SUB_NUM.200"
BROADCAST="192.168.$SUB_NUM.255"
NETWORK="192.168.$SUB_NUM.0"

CONFIG_BLOCK="
subnet $NETWORK netmask $NETMASK {
    range $POOL_START $POOL_END;
    option routers $ROUTER_IP;
    option subnet-mask $NETMASK;
    option broadcast-address $BROADCAST;
    option domain-name-servers 8.8.8.8, 8.8.4.4; # Example of using public DNS
}
"