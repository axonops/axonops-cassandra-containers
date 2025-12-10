#!/bin/bash
# AxonDB Time-Series Health Check Script
# Verifies Cassandra cluster is operational

set -e

CASSANDRA_LISTEN_ADDRESS="${CASSANDRA_LISTEN_ADDRESS:-127.0.0.1}"
CQL_PORT="${CQL_PORT:-9042}"

# Check 1: CQL port is listening
if ! nc -z localhost ${CQL_PORT} > /dev/null 2>&1; then
    echo "ERROR: CQL port ${CQL_PORT} not listening"
    exit 1
fi

# Check 2: Nodetool status succeeds and shows node is Up/Normal (UN)
if ! nodetool status 2>&1 | grep -q "^UN"; then
    echo "ERROR: Node not in Up/Normal state"
    nodetool status 2>&1 || true
    exit 1
fi

# All checks passed
exit 0
