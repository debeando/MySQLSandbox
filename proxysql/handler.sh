#!/bin/bash
# encoding: UTF-8

# el handler se activa si los checks pasan.
# Usar orchestrator para agregar los servers.
# validar si ya esta agregado, si hay nuevos hacer load & save.

exec >> /root/handler.log

[ $# -ge 1 -a -f "$1" ] && INPUT="$1" || INPUT="-"

JSON=$(cat $INPUT)

if [[ -n "${JSON}" &&  "${JSON}" -eq "null" ]]
then
  echo "No data"
  exit 1
fi

VALUES=$(echo $JSON | jq -r '.Value' | base64 --decode)
ARRAY=(${VALUES//,/ })

for IP in "${ARRAY[@]}"
do
  echo $IP
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT INTO mysql_servers (
      hostgroup_id,
      hostname,
      port
    ) VALUES (
      1,
      '${IP}',
      3306
    );"
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
"
