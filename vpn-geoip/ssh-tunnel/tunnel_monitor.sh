#!/bin/bash

#set -xv

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

COMMON_DIR_PATH=$(dirname "$DIR_PATH")
source "$COMMON_DIR_PATH/variables.sh"

PATH_TUNNEL="$DIR_PATH/tunnel.sh"
PATH_MONITOR="$DIR_PATH/tunnel_monitor.sh"

CRONTAB_JOB="$CRONTAB_JOB $PATH_MONITOR start"


write_log() {
    if [ $USE_LOG = "true" ]; then
        exec > >(stdbuf -oL tee >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>"$LOG_SSH_TUNNEL_MONITOR")) 2>&1
    fi
}

do_start() {
    #crotab part
    if grep -Fxq "$CRONTAB_JOB" $CRONTAB_FILE; then
        echo "job already in $CRONTAB_FILE"
    else
        echo $CRONTAB_JOB >>$CRONTAB_FILE
        service cron reload
    fi

    $PATH_TUNNEL start
}

do_stop() {
    #crotab part
    if grep -Fxq "$CRONTAB_JOB" $CRONTAB_FILE; then
        echo "Deleting cron record from $CRONTAB_FILE"
        cat $CRONTAB_FILE | grep -v $PATH_MONITOR | grep -v '^$' >$CRONTAB_FILE_TMP && mv $CRONTAB_FILE_TMP $CRONTAB_FILE
        service cron reload
    else
        echo "job was not in $CRONTAB_FILE"
    fi
    $PATH_TUNNEL stop
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
