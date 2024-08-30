#!/bin/bash

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

ROUTE_SCRIPT=$(basename "$0")

current_date() {
  echo $(date +"%Y.%m.%d-%H:%M:%S")
}



write_log() {
  if [ $USE_LOG = "true" ]; then
    date=$(current_date)
    echo "$date $1" >>$LOG_IP_ROUTE 2>&1
  fi
}


write_log_monitor() {
  if [ $USE_LOG = "true" ]; then
    date=$(current_date)
    echo "$date $1" >>$LOG_IP_ROUTE 2>&1
  fi
}


write_memo_logging() {
  echo "Route log is $LOG_IP_ROUTE"
}


setup_routing() {
    # Create routing tables
    ip rule add fwmark 1 table $TABLE_VPN
    ip rule add fwmark 2 table $TABLE_WAN

    # Set up routes for the tables
    ip route add default dev $VPN table $TABLE_VPN
    ip route add default dev $WAN table $TABLE_WAN

    # Mark packets for routing
    iptables -t mangle -A PREROUTING -m set --match-set $IPSET_DIRECT dst -j MARK --set-mark 2
    iptables -t mangle -A PREROUTING -m set --match-set $IPSET_VPN_ADDITIONAL dst -j MARK --set-mark 1

    # Mark packets for ports 80 and 443 to go through VPN
    iptables -t mangle -A PREROUTING -p tcp --dport 80 -j MARK --set-mark 1
    iptables -t mangle -A PREROUTING -p tcp --dport 443 -j MARK --set-mark 1

    # All other packets go through WAN
    iptables -t mangle -A PREROUTING -j MARK --set-mark 2
}

cleanup_routing() {

    ip rule del fwmark 1 table $TABLE_VPN
    ip rule del fwmark 2 table $TABLE_WAN

    ip route flush table $TABLE_VPN
    ip route flush table $TABLE_WAN

    iptables -t mangle -F PREROUTING
}

monitor_vpn() {
    while true; do
        if ping -c 1 -W 2 $REMOTE_IP &>/dev/null; then
            if ! ip rule list | grep -q "fwmark 1 table $TABLE_VPN"; then
                write_log_monitor  "VPN restored. Setting up routing..."
                setup_routing
            fi
        else
            write_log_monitor  "VPN is down. Switching all traffic to WAN..."
            cleanup_routing
            ip route add default dev $WAN
        fi 
        sleep $TIME_TO_CHECK
    done
}

case "$1" in
start)
    echo "Starting routing..."
    setup_routing
    monitor_vpn &
    write_memo_logging
    ;;
stop)
    echo "Stopping routing..."
    pkill -f $ROUTE_SCRIPT
    cleanup_routing
    write_memo_logging
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
