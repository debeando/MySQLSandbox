#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Start consul.'
consul agent -config-file=/etc/consul.d/config.json \
             -bind=0.0.0.0 \
             -client=0.0.0.0 \
             -ui
