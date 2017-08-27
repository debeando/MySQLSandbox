#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Check whether MySQL is running...'
while ! mysqladmin ping --host="172.20.1.201" --user="monitor" --password="monitor" --silent > /dev/null 2>&1 ; do
  sleep 1
done

echo '[Entrypoint] Start ProxySQL.'
/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf
