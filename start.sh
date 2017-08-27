#!/bin/bash
# encoding: UTF-8

mysql -h 127.0.0.1 -u sandbox -psandbox -P 3306 -e "
CREATE DATABASE IF NOT EXISTS sandbox;
USE sandbox;
CREATE TABLE IF NOT EXISTS sandbox.test (
  id INT NOT NULL AUTO_INCREMENT,
  token CHAR(36) NOT NULL,
  value INT NOT NULL,
  unixtimestamp INT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (token)
);
"

docker exec -it mysqlsandbox_orchestrator_1 \
  /usr/bin/orchestrator -c discover -i 172.20.1.201

docker exec -it mysqlsandbox_db1_1 \
  mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
                 --slave=admin:admin@172.20.1.202:3306 \
                 --rpl-user=repl:repl

docker exec -it mysqlsandbox_db1_1 \
  mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
                 --slave=admin:admin@172.20.1.203:3306 \
                 --rpl-user=repl:repl

docker exec -it mysqlsandbox_db1_1 \
  mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
                 --slave=admin:admin@172.20.1.204:3306 \
                 --rpl-user=repl:repl

docker exec -it mysqlsandbox_db1_1 \
  mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
                 --slave=admin:admin@172.20.1.205:3306 \
                 --rpl-user=repl:repl

docker exec -it mysqlsandbox_db1_1 \
  mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
                 --slave=admin:admin@172.20.1.206:3306 \
                 --rpl-user=repl:repl
