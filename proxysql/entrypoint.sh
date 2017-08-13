#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] ProxySQL process done. Ready for start up.'
/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf
