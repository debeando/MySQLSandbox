#!/bin/bash
# encoding: UTF-8
set -e

exec >> /root/handler.log

while read line
do
  VALUES=$(echo $A | jq -r '.Value' | base64 --decode)
  ARRAY=(${VALUES//,/ })

	for IP in "${ARRAY[@]}"
	do
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
done
