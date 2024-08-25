#!/bin/bash

exec >/var/log/ssh_tunnel_monitor.log 2>&1
# Путь до PID файла
PID_FILE="/tmp/ssh_tunnel.pid"
PATH_START_TUNNEL="/home/fenych/ssh-tunnel/start_tunnel.sh"

# Проверяем, существует ли PID файл
if [ ! -f ${PID_FILE} ]; then
  echo "PID файл не найден. Поднимаем тоннель заново."
  "$PATH_START_TUNNEL"
  exit 0
fi

# Читаем PID процесса SSH
SSH_PID=$(cat ${PID_FILE})

# Проверяем, работает ли процесс с этим PID
if ! ps -p ${SSH_PID} > /dev/null; then
  echo "Тоннель упал. Поднимаем заново."
  "$PATH_START_TUNNEL"
else
  echo "Тоннель работает."
fi

