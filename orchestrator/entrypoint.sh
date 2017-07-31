#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Waiting for MySQL Server...'
sleep 60

echo '[Entrypoint] Orchestrator process done. Ready for start up.'
cd /usr/local/orchestrator && ./orchestrator http
