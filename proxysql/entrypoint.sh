#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Start ProxySQL.'
/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf
