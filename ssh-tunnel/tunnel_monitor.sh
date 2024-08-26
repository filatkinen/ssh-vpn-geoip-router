#!/bin/bash

#set -xv
source variables.sh

PID=$(ps aux | grep "ssh" | grep ${REMOTE_USER}@${REMOTE_HOST} | awk '{print $2}')

write_log() {
    if [ $USE_LOG = "true" ]; then
        exec > >(awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; }' >>$LOG_SSH_TUNNEL_MONITOR) 2>&1
    fi
}

do_start() {
    #crotab part
    echo $CRONTAB_JOB
    if grep -Fxq "$CRONTAB_JOB" $CRONTAB_FILE; then
        echo "job already in $CRONTAB_FILE"
    else
        echo $CRONTAB_JOB >>$CRONTAB_FILE
        service cron reload
    fi

    if kill -0 $PID 2>/dev/null; then
        echo "Tunnel is up=" $PID
    else
        echo "Tunnel is down, trying start"
        #deleting tun0 on remote host if it is
        ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "ip link delete tun0"

        $PATH_TUNNEL start
    fi
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
