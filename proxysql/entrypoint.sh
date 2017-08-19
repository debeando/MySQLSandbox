#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Waiting 50 seconds for load all MySQL Server...'
sleep 50

echo '[Entrypoint] Start ProxySQL.'
/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf
