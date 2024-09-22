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

    if ip rule list | grep -q "fwmark 0x1 lookup $TABLE_VPN"; then
        write_log_monitor "Route probably was not clean correctly. Cleaning"
        cleanup_routing
    fi

    write_log_monitor "Starting setup route"

    # Create routing tables
    ip rule add fwmark 1 table $TABLE_VPN

    # Set up routes for the tables
    ip route add default via $VPN_REMOTE_IP dev $VPN table $TABLE_VPN

    #vpn access 
    iptables -t mangle -A PREROUTING -m set --match-set $IPSET_VPN_ADDITIONAL dst -j MARK --set-mark 1
#    iptables -t mangle -A PREROUTING -m mark --mark 1 -j RETURN

    # VPN for packets that are not in direct list and with dport=80,443  - all web traffic 
    iptables -t mangle -A PREROUTING -m set ! --match-set $IPSET_DIRECT dst -p tcp -m multiport --dports 80,443 -j MARK --set-mark 1
    iptables -t mangle -A PREROUTING -m set ! --match-set $IPSET_DIRECT dst -p tcp -m multiport --dports 80,443 -j MARK --set-mark 1
 #   iptables -t mangle -A PREROUTING -m mark --mark 1 -j RETURN

    #use vpn gate for dns google and cloudflare    
    iptables -A PREROUTING -t mangle -p tcp --dport 53 -m set ! --match-set $IPSET_DIRECT dst -j MARK --set-xmark 1
    iptables -A PREROUTING -t mangle -p udp --dport 53 -m set ! --match-set $IPSET_DIRECT dst -j MARK --set-xmark 1
 #   iptables -t mangle -A PREROUTING -m mark --mark 1 -j RETURN


    ip route flush cache
}

cleanup_routing() {
    
    write_log_monitor "Cleanup route to default"

    ip rule del fwmark 1 table $TABLE_VPN &>>$LOG_IP_ROUTE
    ip route flush table $TABLE_VPN &>>$LOG_IP_ROUTE

    iptables -t mangle -F PREROUTING
}

monitor_vpn() {
    write_log_monitor "Starting monitor route. Checking every  $TIME_TO_CHECK seconds"
    while true; do
        if ping -c 1 -W 2 $VPN_REMOTE_IP &>/dev/null; then
            if ! ip rule list | grep -q "fwmark 0x1 lookup $TABLE_VPN"; then
                write_log_monitor "VPN restored. Setting up routing..."
                setup_routing
            fi
        else
            write_log_monitor "VPN is down. Switching all traffic to WAN..."
            cleanup_routing
        fi
        sleep $TIME_TO_CHECK
    done
}

cleanup() {
    echo "Interrupted(stop), so clean up"
    cleanup_routing
    exit 0
}

trap cleanup SIGTERM

case "$1" in
start)
    echo "Starting routing..."
    setup_routing
    monitor_vpn &
    write_memo_logging
    ;;
stop)
    echo "Stopping routing..."
    cleanup_routing
    write_memo_logging
    pkill -f $ROUTE_SCRIPT
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
