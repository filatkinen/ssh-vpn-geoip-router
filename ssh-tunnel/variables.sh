set -o noglob

REMOTE_USER="root"
REMOTE_HOST="nl1.fenych.ru"
REMOTE_PORT="22"
LOCAL_IP="192.168.150.2"
REMOTE_IP="192.168.150.1"
NETMASK="255.255.255.0"

USE_LOG="true"

LOG_SSH_TUNNEL="/var/log/ssh_tunnel.log"
LOG_SSH_TUNNEL_MONITOR="/var/log/ssh_tunnel_monitor.log"


PATH_TUNNEL="/home/fenych/configs/ssh-tunnel/tunnel.sh"
PATH_MONITOR="/home/fenych/configs/ssh-tunnel/tunnel_monitor.sh"


CRONTAB_JOB='*/5 * * * * root'" $PATH_MONITOR"
CRONTAB_FILE="/etc/crontab"
CRONTAB_FILE_TMP="/tmp/crontab.tmp"
