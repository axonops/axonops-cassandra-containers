#!/bin/bash
# AxonDB Search Health Check
# Usage: healthcheck.sh {startup|liveness|readiness}

set -euo pipefail

MODE="${1:-readiness}"
HTTP_PORT="${OPENSEARCH_HTTP_PORT:-9200}"
TIMEOUT="${HEALTH_CHECK_TIMEOUT:-10}"
OPENSEARCH_DATA_DIR="${OPENSEARCH_DATA_DIR:-/var/lib/opensearch}"

log() {
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] [$MODE] $*" >&2
}

case "$MODE" in
  startup)
    # Lightweight startup check with init script coordination
    log "Checking if OpenSearch is starting"

    # CRITICAL: Check if security init script semaphore exists
    # Located in /var/lib/opensearch (persistent volume) not /etc (ephemeral)
    INIT_SECURITY_SEMAPHORE="${OPENSEARCH_DATA_DIR}/.axonops/init-security.done"
    if [ ! -f "$INIT_SECURITY_SEMAPHORE" ]; then
      log "Waiting for security init script to complete (semaphore not found)"
      exit 1
    fi

    # CRITICAL: Check RESULT field in semaphore file - fail if initialization failed
    SECURITY_RESULT=$(grep "^RESULT=" "$INIT_SECURITY_SEMAPHORE" | cut -d'=' -f2)
    if [ "$SECURITY_RESULT" = "failed" ]; then
      SECURITY_REASON=$(grep "^REASON=" "$INIT_SECURITY_SEMAPHORE" | cut -d'=' -f2)
      log "ERROR: Security initialization failed: ${SECURITY_REASON}"
      exit 1
    fi

    # Check if OpenSearch Java process is running
    if ! pgrep -f "org.opensearch.bootstrap.OpenSearch" > /dev/null 2>&1; then
      log "OpenSearch process not running"
      exit 1
    fi

    # Check if port 9200 is listening (TCP check)
    if ! nc -z localhost "$HTTP_PORT" 2>/dev/null; then
      log "Port $HTTP_PORT not listening"
      exit 1
    fi

    # Check security plugin health endpoint (lightweight, no auth required)
    SECURITY_HEALTH=$(timeout "$TIMEOUT" curl -s --insecure "https://localhost:${HTTP_PORT}/_plugins/_security/health" 2>/dev/null || echo "")
    if [ -z "$SECURITY_HEALTH" ] || ! echo "$SECURITY_HEALTH" | grep -q "message"; then
      log "Security health endpoint not responding"
      exit 1
    fi

    log "Startup check passed (init: ${SECURITY_RESULT}, process running, port listening, security health OK)"
    exit 0
    ;;

  liveness)
    # Ultra-lightweight liveness check (runs every 10 seconds)
    # NO authentication required - uses security plugin health endpoint
    log "Checking liveness"

    # Check if OpenSearch process is running
    if ! pgrep -f "org.opensearch.bootstrap.OpenSearch" > /dev/null 2>&1; then
      log "ERROR: OpenSearch process not running"
      exit 1
    fi

    # Check if port 9200 is listening (TCP check)
    if ! nc -z localhost "$HTTP_PORT" 2>/dev/null; then
      log "ERROR: Port $HTTP_PORT not listening"
      exit 1
    fi

    # Check security plugin health endpoint (lightweight, no auth required)
    SECURITY_HEALTH=$(timeout "$TIMEOUT" curl -s --insecure "https://localhost:${HTTP_PORT}/_plugins/_security/health" 2>/dev/null || echo "")
    if [ -z "$SECURITY_HEALTH" ] || ! echo "$SECURITY_HEALTH" | grep -q "message"; then
      log "ERROR: Security health endpoint not responding"
      exit 1
    fi

    log "Liveness check passed (process running + port listening + security health OK)"
    exit 0
    ;;

  readiness)
    # Readiness check with authenticated cluster health verification
    log "Checking readiness"

    # Check if port 9200 is listening (TCP check)
    if ! nc -z localhost "$HTTP_PORT" 2>/dev/null; then
      log "ERROR: Port $HTTP_PORT not listening"
      exit 1
    fi

    # Determine admin credentials for API access
    # Priority: Custom user from semaphore > default admin password
    INIT_SEMAPHORE="${OPENSEARCH_DATA_DIR}/.axonops/init-security.done"
    ADMIN_USER="admin"
    ADMIN_PASSWORD="MyS3cur3P@ss2025"

    if [ -f "$INIT_SEMAPHORE" ]; then
      # Check if custom user was created
      if grep -q "^ADMIN_USER=" "$INIT_SEMAPHORE"; then
        ADMIN_USER=$(grep "^ADMIN_USER=" "$INIT_SEMAPHORE" | cut -d'=' -f2)
        # If custom user exists, use environment variable password
        if [ -n "$AXONOPS_SEARCH_PASSWORD" ]; then
          ADMIN_PASSWORD="$AXONOPS_SEARCH_PASSWORD"
        fi
      fi
    fi

    # Make authenticated HTTP GET request to /_cluster/health
    # Note: Using --insecure because we're using demo SSL certificates
    HEALTH_RESPONSE=$(timeout "$TIMEOUT" curl -s --insecure -u "${ADMIN_USER}:${ADMIN_PASSWORD}" -XGET "https://localhost:${HTTP_PORT}/_cluster/health" 2>/dev/null || echo "")

    if [ -z "$HEALTH_RESPONSE" ]; then
      log "ERROR: Failed to get cluster health response"
      exit 1
    fi

    # Check if response contains status field (indicates valid response)
    if ! echo "$HEALTH_RESPONSE" | grep -q '"status"'; then
      log "ERROR: Invalid cluster health response"
      echo "$HEALTH_RESPONSE" >&2
      exit 1
    fi

    # Extract cluster status and verify it's not "red"
    CLUSTER_STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')

    if [ "$CLUSTER_STATUS" = "red" ]; then
      log "ERROR: Cluster status is red (unhealthy)"
      exit 1
    fi

    log "Readiness check passed (port listening + cluster status: ${CLUSTER_STATUS})"
    exit 0
    ;;

  *)
    log "ERROR: Invalid mode. Usage: $0 {startup|liveness|readiness}"
    exit 1
    ;;
esac
