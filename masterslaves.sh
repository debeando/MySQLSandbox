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
" > /dev/null 2>&1

for i in {2..6}
do
  docker exec -it mysqlsandbox_db1_1 \
    mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
                   --slave=admin:admin@172.20.1.20${i}:3306 \
                   --rpl-user=repl:repl \
                   --start-from-beginning \
                   -vvv
done
