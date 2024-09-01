#!/bin/bash
#set -xv

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

FILE_DIRECT="$DIR_PATH/$FILE_DIRECT"
FILE_DIRECT_ADDITIONAL="$COMMON_DIR_PATH/$FILE_DIRECT_ADDITIONAL"

FILE_VPN_ADDITIONAL_ALL_PORTS="$COMMON_DIR_PATH/$FILE_VPN_ADDITIONAL_ALL_PORTS"

PATH_GEOIP="$DIR_PATH/$(basename "$0")"
CRONTAB_JOB="$CRONTAB_JOB $PATH_GEOIP start"

if ! command -v ipset &>/dev/null; then
  echo "ipset is not installed or not available in PATH."
  echo "run: sudo apt install ipset"
  exit 1
fi

write_log() {
  if [ $USE_LOG = "true" ]; then
    exec > >(stdbuf -oL tee >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_GEOIP")) 2>&1
  fi
}

get_geo_ip_data() {
  set -o pipefail # turn on  pipefail mode

  echo "Download new geoip list"
  #download list and put filter data to the file
  wget -qO- $URL_GEOIP_DATA | gunzip | grep $COUNTRY_DIRECT | grep -v ffff | grep -v '#' | sed 's/"\([^"]*\)","\([^"]*\)".*/\1-\2/' >$FILE_DIRECT

  if [ $? -ne 0 ]; then
    echo "Failure with  one of command in pipe - most probably with wget."
    exit 1
  fi
}

set_ip_sets() {
  # if ipsets were not created, they wiil be created ones
  ipset create -exist $IPSET_DIRECT hash:net
  ipset create -exist $IPSET_DIRECT_LOAD hash:net
  # flush load ipset
  ipset flush $IPSET_DIRECT_LOAD

  ipset create -exist $IPSET_VPN_ADDITIONAL hash:net
  ipset create -exist $IPSET_VPN_ADDITIONAL_LOAD hash:net
  # flush load ipset vpn direct
  ipset flush $IPSET_VPN_ADDITIONAL_LOAD

  echo "Loading geoip into the ipset. Number of records =" $(wc -l <$FILE_DIRECT)
  # load to ipset geo file
  count=0
  while IFS=',' read -r ip_range _; do
    
    # command to ipset
    ipset add -exist $IPSET_DIRECT_LOAD $ip_range
    count=$((count + 1))
    if [ "$count" -ge "$LIMIT" ]; then
      echo "Limit of $LIMIT records reached. Stopping."
      break
    fi
  done <"$FILE_DIRECT"

  # load additional file
  if [ -f $FILE_DIRECT_ADDITIONAL ]; then
    echo "Loading  additional geoip into the ipset. Number of records =" $(wc -l <$FILE_DIRECT_ADDITIONAL)
    while IFS=',' read -r ip_range _; do
      if [[ "$ip_range" == \#* ]]; then
        continue
      fi
      # command to ipset
      ipset add -exist $IPSET_DIRECT_LOAD $ip_range
    done <"$FILE_DIRECT_ADDITIONAL"
  fi

  # load additional file
  if [ -f $FILE_VPN_ADDITIONAL_ALL_PORTS ]; then
    echo "Loading  additional vpn geoip into the ipset. Number of records =" $(wc -l <$FILE_VPN_ADDITIONAL_ALL_PORTS)
    while IFS=',' read -r ip_range _; do
      if [[ "$ip_range" == \#* ]]; then
        continue
      fi
      # command to ipset
      ipset add -exist $IPSET_VPN_ADDITIONAL_LOAD $ip_range
    done <"$FILE_VPN_ADDITIONAL_ALL_PORTS"
  fi

  # finally swap ipsets base
  ipset swap $IPSET_DIRECT $IPSET_DIRECT_LOAD

  # finally swap ipsets vpn additional
  ipset swap $IPSET_VPN_ADDITIONAL $IPSET_VPN_ADDITIONAL_LOAD

  echo "Finish updating ip sets"
}

do_start() {
  #crotab part -check and add
  if grep -Fxq "$CRONTAB_JOB" $CRONTAB_FILE; then
    echo "job already in $CRONTAB_FILE"
  else
    echo $CRONTAB_JOB >>$CRONTAB_FILE
    service cron reload
  fi

  get_geo_ip_data
  set_ip_sets
}

do_stop() {
  #crotab part -check and dell
  if grep -Fxq "$CRONTAB_JOB" $CRONTAB_FILE; then
    echo "Deleting cron record from $CRONTAB_FILE"
    cat $CRONTAB_FILE | grep -v $PATH_GEOIP | grep -v '^$' >$CRONTAB_FILE_TMP && mv $CRONTAB_FILE_TMP $CRONTAB_FILE
    service cron reload
  else
    echo "job was not in $CRONTAB_FILE"
  fi
}

if [ -z "$1" ]; then
  echo "use: $0 start/stop"
else
  case $1 in
  start)
    echo "Starting...."
    write_log
    do_start
    ;;
  stop)
    echo "Stopping...."
    write_log
    do_stop
    ;;
  *)
    echo "Unknown parameter: $1. Please Use: $0 start/stop"
    ;;
  esac
fi
