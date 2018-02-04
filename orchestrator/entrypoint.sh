#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Start consul agent.'
consul agent -config-file=/etc/consul.d/config.json &

echo '[Entrypoint] Start Orchestrator.'
cd /usr/local/orchestrator && ./orchestrator --config=/etc/orchestrator.conf.json http
