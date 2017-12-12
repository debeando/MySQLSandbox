#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Start consul.'
consul agent -server \
             -bootstrap \
             -bind=0.0.0.0 \
             -client=0.0.0.0 \
             -datacenter=mysql \
             -data-dir=/tmp/consul \
             -config-dir=/etc/consul.d \
             -enable-script-checks \
             -ui
