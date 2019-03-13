#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Start consul agent.'
consul agent -config-file=/etc/consul.d/config.json &

MYSQL_REPORT_HOST=$(/sbin/ip route | awk '/kernel/ { print $9 }')
MYSQL_SERVER_ID="${MYSQL_REPORT_HOST//./}"

sed -i -e "s/#REPORT_HOST/${MYSQL_REPORT_HOST}/g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -e "s/#SERVER_ID/${MYSQL_SERVER_ID}/g" /etc/mysql/mysql.conf.d/mysqld.cnf

DATADIR="/var/lib/mysql"
SOCKETDIR="/var/run/mysqld/"
SOCKET="/var/run/mysqld/mysqld.sock"
CMD=(mysql --protocol=socket -uroot --socket="$SOCKET")

rm -rf "$DATADIR"
mkdir -p "$DATADIR"
mkdir -p "$SOCKETDIR"
chown -R mysql:mysql "$DATADIR"
chown -R mysql:root "$SOCKETDIR"
> /var/log/mysql/error.log

echo '[Entrypoint] Initializing database.'
mysqld --initialize-insecure \
       --datadir="$DATADIR"
echo '[Entrypoint] Database initialized.'

mysqld --daemonize --skip-networking --socket="$SOCKET"

if [ ! -z "" ];
then
  for i in {30..0}; do
    if mysqladmin --socket="$SOCKET" ping &>/dev/null; then
      break
    fi
    echo '[Entrypoint] Waiting for server...'
    sleep 1
  done
  if [ "$i" = 0 ]; then
    echo >&2 '[Entrypoint] Timeout during MySQL init.'
    exit 1
  fi
fi

echo "[Entrypoint] Populate TimeZone..."
# With "( .. ) 2> /dev/null" suppress any std[out/err].
( mysql_tzinfo_to_sql /usr/share/zoneinfo | "${CMD[@]}" --force ) 2> /dev/null

echo "[Entrypoint] Create users."
"${CMD[@]}" <<-EOSQL
SET @@SESSION.SQL_LOG_BIN=0;
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS orchestrator;
CREATE DATABASE IF NOT EXISTS sandbox;
CHANGE MASTER TO MASTER_USER = 'repl', MASTER_PASSWORD = 'repl';
GRANT ALL PRIVILEGES ON orchestrator.* TO 'orchestrator'@'%' IDENTIFIED BY 'orchestrator';
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON orchestrator.* TO 'orchestrator'@'localhost' IDENTIFIED BY 'orchestrator';
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON orchestrator.* TO 'orchestrator'@'localhost' IDENTIFIED BY 'orchestrator';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.16.238.%' IDENTIFIED BY 'repl';
GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'admin' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, DROP, INDEX ON *.* TO 'sandbox'@'%' IDENTIFIED BY 'sandbox';
GRANT SELECT, CREATE USER, REPLICATION CLIENT, SHOW DATABASES, SUPER, PROCESS ON *.* TO 'monitor'@'%' IDENTIFIED BY 'monitor';
FLUSH PRIVILEGES;
SET @@SESSION.SQL_LOG_BIN=1;
EOSQL

mysqladmin shutdown -uroot --socket="$SOCKET"

echo '[Entrypoint] MySQL init process done. Ready for start up.'
mysqld
