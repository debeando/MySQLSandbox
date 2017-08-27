#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Check whether MySQL for Orchestrator is running...'
while ! mysqladmin ping --host="172.20.1.207" --user="monitor" --password="monitor" --silent > /dev/null 2>&1 ; do
  sleep 1
done

echo '[Entrypoint] Start Orchestrator.'
cd /usr/local/orchestrator && ./orchestrator http
