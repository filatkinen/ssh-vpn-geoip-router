#!/bin/bash

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

ROUTE_SCRIPT=$(basename "$0")

write_log() {
    if [ $USE_LOG = "true" ]; then
        exec > >(stdbuf -oL tee >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_IP_ROUTE")) 2>&1
    fi
}

write_log_monitor() {
    if [ $USE_LOG = "true" ]; then
        exec > >(stdbuf -oL awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_IP_ROUTE") 2>&1
    else
        exec >/dev/null 2>&1
    fi
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
    write_log_monitor
    while true; do
        if ip link show $VPN up &>/dev/null; then
            if ! ip rule list | grep -q "fwmark 1 table $TABLE_VPN"; then
                echo "VPN restored. Setting up routing..."
                setup_routing
            fi
        else
            echo "VPN is down. Switching all traffic to WAN..."
            cleanup_routing
            ip route add default dev $WAN
        fi
        sleep $TIME_TO_CHECK
    done
}

case "$1" in
start)
    write_log
    echo "Starting routing..."
    setup_routing
    monitor_vpn &
    ;;
stop)
    write_log
    echo "Stopping routing..."
    pkill -f $ROUTE_SCRIPT
    cleanup_routing
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
