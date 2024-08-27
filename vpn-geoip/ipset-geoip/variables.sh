set -o noglob

USE_LOG="true"

LOG_GEOIP="/var/log/geo_ip_task.log"

CRONTAB_JOB='0 1 * * * root'
CRONTAB_FILE="/etc/crontab"
CRONTAB_FILE_TMP="/tmp/crontab-geoip.tmp"
