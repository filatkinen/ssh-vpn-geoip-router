set -o noglob

USE_LOG="true"

REMOTE_USER="root"
REMOTE_HOST="nl1.fenych.ru"
REMOTE_PORT="22"
LOCAL_IP="192.168.150.2"
REMOTE_IP="192.168.150.1"
NETMASK="255.255.255.0"

LOG_SSH_TUNNEL="/var/log/ssh_tunnel.log"
LOG_SSH_TUNNEL_MONITOR="/var/log/ssh_tunnel_monitor.log"

CRONTAB_JOB='*/5 * * * * root'
CRONTAB_FILE="/etc/crontab"
CRONTAB_FILE_TMP="/tmp/crontab-monitor.tmp"

