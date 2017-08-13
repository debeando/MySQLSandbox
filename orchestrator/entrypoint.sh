#!/bin/bash
# encoding: UTF-8
set -e

echo '[Entrypoint] Waiting 60 seconds for load all MySQL Server...'
sleep 60

echo '[Entrypoint] Start Orchestrator.'
cd /usr/local/orchestrator && ./orchestrator http
