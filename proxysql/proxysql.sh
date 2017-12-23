#!/bin/bash
# encoding: UTF-8
set -e

NODES=($(curl --silent 127.0.0.1:8500/v1/catalog/nodes | jq '.[] | select(.Meta.role == "mysql") | .Address'))

for IP_ADDRESS in "${NODES[@]}"
do
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT INTO mysql_servers (
      hostgroup_id,
      hostname,
      port
    ) VALUES (
      1,
      '${IP_ADDRESS}',
      3306
    );
  " 2> /dev/null
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
" 2> /dev/null
