#!/bin/bash
# encoding: UTF-8
set -e

# TODO: Obtener la IP de orchestrator desde consul.
ORCHESTRATOR_IP="172.20.1.200"
LOCAL_IP=$(awk 'END{print $1}' /etc/hosts)

echo "--> Check whether MySQL is running..."
while ! mysqladmin ping --host=$LOCAL_IP --user="monitor" --password="monitor" --silent > /dev/null 2>&1 ; do
  sleep 1
done

# TODO: :
echo "--> Check if registered instance..."
IS_REGISTERED=$(curl --silent --output /dev/null --write-out '%{http_code}' http://$ORCHESTRATOR_IP:3000/api/instance/$LOCAL_IP/3306)
if [ $IS_REGISTERED -ne 200 ]
then
  echo "--> Register new instance..."
  curl --silent http://$ORCHESTRATOR_IP:3000/api/discover/$LOCAL_IP/3306
  # Wait 10 seconds for internal checks on orchestrator.
  sleep 10
fi

MASTER_IP=$(curl --silent http://$ORCHESTRATOR_IP:3000/api/clusters | jq -r 'first(.[]) | split(":")[0]')
SLAVES_IP=($(curl --silent http://$ORCHESTRATOR_IP:3000/api/cluster/$MASTER_IP | jq -r '.[0].SlaveHosts | map(.Hostname) | join(",")'))
SLAVES_IP=(${SLAVES_IP//,/ })

echo "--> LOCAL_IP: ${LOCAL_IP}"
echo "--> MASTER_IP: ${MASTER_IP}"
echo "--> SLAVES_IP: ${SLAVES_IP}"

# TODO: Revisar si esta instancia esta OK para irnorar todo el proceso.

if [ -z "$MASTER_IP" ]; then
  echo "--> Is not set variable: MASTER_IP"
  exit 1
fi

HOST_IP=$MASTER_IP

if [ "$MASTER_IP" != "$LOCAL_IP" ]
then
  if [ ${#SLAVES_IP[@]} -gt 0 ]
  then
    for SLAVE_IP in "${SLAVES_IP[@]}"
    do
      if [ "$SLAVE_IP" != "$LOCAL_IP" ]
      then
        SLAVE_STATUS=$(curl --silent http://$ORCHESTRATOR_IP:3000/api/instance/$SLAVE_IP/3306 | jq '(.Slave_SQL_Running == true and .Slave_IO_Running == true)')
        echo "--> Collect slave status from ${SLAVE_IP}: ${SLAVE_STATUS}"

        if [ $SLAVE_STATUS == "true" ]
        then
          HOST_IP=$SLAVE_IP
          break
        fi
      fi
    done
  fi

  echo "--> Backup data from: ${HOST_IP}"
  # hacer dump dependiendo si es master o slave.
  mysqldump --host=$HOST_IP \
            --user=admin \
            --password=admin \
            --all-databases \
            --triggers \
            --routines \
            --events \
            --master-data | mysql --force

  mysqlreplicate --master=admin:admin@$MASTER_IP:3306 \
                 --slave=admin:admin@127.0.0.1:3306 \
                 --rpl-user=repl:repl \
                 -vvv

  mysql --execute="SET GLOBAL read_only = ON;"

  # Esperar hasta que el slave haya hecho catchup.
fi

if [ -z $(consul kv get -recurse) ]
then
  consul kv put mysql/servers $LOCAL_IP
else
  VALUES=$(consul kv get mysql/servers)
  VALUES+=",${LOCAL_IP}"
  VALUES=(${VALUES//,/ })
  VALUES=($(echo "${VALUES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  VALUES=${VALUES[@]}
  VALUES=${VALUES// /,}

  consul kv put mysql/servers $VALUES
fi
