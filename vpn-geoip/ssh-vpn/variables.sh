set -o noglob

USE_LOG="true"

REMOTE_USER="root"
REMOTE_HOST="nl1.fenych.ru"
REMOTE_PORT="22"
LOCAL_IP="192.168.150.2"
#  REMOTE_IP is in global varibales - it used to monitoring for route
NETMASK="255.255.255.0"

LOG_SSH_TUNNEL="/var/log/vpn-geoip.ssh_tunnel.log"

TIME_TO_CHECK=60


