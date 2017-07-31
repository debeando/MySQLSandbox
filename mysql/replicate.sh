#!/bin/bash
# encoding: UTF-8
set -e

mysqlreplicate --master=admin:admin@172.20.1.201:3306 \
               --slave=admin:admin@$(hostname -i):3306 \
               --rpl-user=repl:repl
