#!/bin/bash
# encoding: UTF-8

# Todo: Query to the consul to get the number of instances.
# necesary for create co-master:

# Set default replication user and password into mysql.slave_master_info
docker exec -it mysqlsandbox_mysql_1 \
   mysql -u admin -padmin -e "
CHANGE MASTER TO MASTER_USER = 'repl', MASTER_PASSWORD = 'repl';
SET GLOBAL auto_increment_increment = 2;
"

# show variables like 'auto_increment_%';

docker exec -it mysqlsandbox_mysql_2 \
   mysql -u admin -padmin -e "
SET GLOBAL auto_increment_increment = 2;
SET GLOBAL auto_increment_offset = 2;
SET GLOBAL read_only = OFF;
"

# docker exec -it mysqlsandbox_mysql_2 \
#   mysqlreplicate --master=admin:admin@172.16.238.2:3306 \
#                  --slave=admin:admin@172.16.238.3:3306 \
#                  --rpl-user=repl:repl \
#                  -vvv

docker exec -it mysqlsandbox_mysql_1 \
  mysqlreplicate --master=admin:admin@172.16.238.3:3306 \
                 --slave=admin:admin@172.16.238.2:3306 \
                 --rpl-user=repl:repl \
                 -vvv

# docker exec -it mysqlsandbox_mysql_1 \
# 	mysql -u admin -padmin -Bse "select concat('KILL ',id,';') from information_schema.processlist where user='sandbox';" | mysql -u admin -padmin

# docker exec -it mysqlsandbox_db2_1 \
# 	mysql -u admin -padmin -Bse "select concat('KILL ',id,';') from information_schema.processlist where user='sandbox';" | mysql -u admin -padmin
