#!/bin/bash
# AxonDB Time-Series Health Check
# Usage: healthcheck.sh {startup|liveness|readiness}

set -euo pipefail

MODE="${1:-readiness}"
CQL_PORT="${CASSANDRA_NATIVE_TRANSPORT_PORT:-9042}"
TIMEOUT="${HEALTH_CHECK_TIMEOUT:-10}"

log() {
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] [$MODE] $*" >&2
}

case "$MODE" in
  startup)
    # Lightweight startup check with init script coordination
    log "Checking if Cassandra is starting"

    # CRITICAL: Check if system keyspace init script semaphore exists
    INIT_KEYSPACE_SEMAPHORE="/etc/axonops/init-system-keyspaces.done"
    if [ ! -f "$INIT_KEYSPACE_SEMAPHORE" ]; then
      log "Waiting for system keyspace init script to complete (semaphore not found)"
      exit 1
    fi

    # CRITICAL: Check if database user init script semaphore exists
    INIT_USER_SEMAPHORE="/etc/axonops/init-db-user.done"
    if [ ! -f "$INIT_USER_SEMAPHORE" ]; then
      log "Waiting for database user init script to complete (semaphore not found)"
      exit 1
    fi

    # Check if Cassandra process is running
    if ! pgrep -f cassandra > /dev/null 2>&1; then
      log "Cassandra process not running"
      exit 1
    fi

    # Check if native transport port is listening
    if ! nc -z localhost "$CQL_PORT" 2>/dev/null; then
      log "CQL port $CQL_PORT not listening"
      exit 1
    fi

    log "Startup check passed (init scripts complete + process running + port listening)"
    exit 0
    ;;

  liveness)
    # Ultra-lightweight liveness check (runs every 10 seconds)
    log "Checking liveness"

    # Check if Cassandra process is running
    if ! pgrep -f cassandra > /dev/null 2>&1; then
      log "ERROR: Cassandra process not running"
      exit 1
    fi

    # Check if native transport port is listening
    if ! nc -z localhost "$CQL_PORT" 2>/dev/null; then
      log "ERROR: CQL port $CQL_PORT not listening"
      exit 1
    fi

    log "Liveness check passed (process running + port listening)"
    exit 0
    ;;

  readiness)
    log "Checking readiness"

    # Check if native transport port is listening
    if ! nc -z localhost "$CQL_PORT" 2>/dev/null; then
      log "ERROR: CQL port $CQL_PORT not listening"
      exit 1
    fi

    # Check native transport and gossip via nodetool info
    INFO=$(timeout "$TIMEOUT" nodetool info 2>/dev/null)

    if ! echo "$INFO" | grep -q "Native Transport active: true"; then
      log "ERROR: Native transport not active"
      echo "$INFO" | grep "Native Transport" >&2 || true
      exit 1
    fi

    if ! echo "$INFO" | grep -q "Gossip active: true"; then
      log "ERROR: Gossip not active"
      echo "$INFO" | grep "Gossip" >&2 || true
      exit 1
    fi

    log "Readiness check passed (port listening + native transport active + gossip active)"
    exit 0
    ;;

  *)
    log "ERROR: Invalid mode. Usage: $0 {startup|liveness|readiness}"
    exit 1
    ;;
esac
