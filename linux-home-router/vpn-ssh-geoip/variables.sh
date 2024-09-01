set -o noglob

WAN="eth0"  
VPN="tun0"  

URL_GEOIP_DATA="https://mailfud.org/geoip-legacy/GeoIP-legacy.csv.gz"
COUNTRY_DIRECT="Russia"

VPN_REMOTE_IP="192.168.150.1"
VPN_LOCAL_IP="192.168.150.2"





# Probably you do not need change anything here
FILE_DIRECT="geoip.rus.ipv4.txt"
FILE_DIRECT_ADDITIONAL="additional.direct.ipv4.txt"

FILE_VPN_ADDITIONAL_ALL_PORTS="additional.vpn.ipv4.txt"

IPSET_DIRECT="set_direct"
IPSET_DIRECT_LOAD="set_direct_load"

IPSET_VPN_ADDITIONAL="set_vpn_addtitional"


IPSET_VPN_ADDITIONAL="set_vpn_addtitional"
IPSET_VPN_ADDITIONAL_LOAD="set_vpn_addtitional_load"
