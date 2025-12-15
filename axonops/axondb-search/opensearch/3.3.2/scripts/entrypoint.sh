#!/bin/bash
set -e

# AxonDB Search Entrypoint Script
# Configures OpenSearch and starts the search engine

# Display comprehensive startup banner
print_startup_banner() {
    if [ -f /etc/axonops/build-info.txt ]; then
      source /etc/axonops/build-info.txt 2>/dev/null || true
    fi

    echo "================================================================================"
    # Title
    echo "AxonOps AxonDB Search (OpenSearch ${OPENSEARCH_VERSION:-unknown})"

    # Image and build info (CI builds only - not shown for local/unknown builds)
    if [ -n "${CONTAINER_IMAGE}" ] && [ "${CONTAINER_IMAGE}" != "unknown" ] && [ "${CONTAINER_IMAGE}" != "" ]; then
      echo "Image: ${CONTAINER_IMAGE}"
    fi
    if [ -n "${CONTAINER_BUILD_DATE}" ] && [ "${CONTAINER_BUILD_DATE}" != "unknown" ] && [ "${CONTAINER_BUILD_DATE}" != "" ]; then
      echo "Built: ${CONTAINER_BUILD_DATE}"
    fi

    # Show release/tag link if available (CI builds)
    if [ -n "${CONTAINER_GIT_TAG}" ] && [ "${CONTAINER_GIT_TAG}" != "unknown" ] && [ "${CONTAINER_GIT_TAG}" != "" ]; then
      if [ "${IS_PRODUCTION_RELEASE:-false}" = "true" ]; then
        # Production build - link to release page (has release notes)
        echo "Release: https://github.com/axonops/axonops-containers/releases/tag/${CONTAINER_GIT_TAG}"
      else
        # Development build - link to tag/tree
        echo "Tag:     https://github.com/axonops/axonops-containers/tree/${CONTAINER_GIT_TAG}"
      fi
    fi

    # Show who built it if available (CI builds)
    if [ -n "${CONTAINER_BUILT_BY}" ] && [ "${CONTAINER_BUILT_BY}" != "unknown" ] && [ "${CONTAINER_BUILT_BY}" != "" ]; then
      if [ "${CONTAINER_BUILT_BY}" = "GitHub Actions" ] || [ "${IS_PRODUCTION_RELEASE:-false}" = "true" ]; then
        echo "Built by: ${CONTAINER_BUILT_BY}"
      fi
    fi

    echo "================================================================================"
    echo ""

    # Component versions (from build-info.txt)
    echo "Component Versions:"
    echo "  OpenSearch:         ${OPENSEARCH_VERSION:-unknown}"
    echo "  Java:               ${JAVA_VERSION:-unknown}"
    echo "  OS:                 ${OS_VERSION:-unknown}"
    echo "  Platform:           ${PLATFORM:-unknown}"
    echo ""

    # Supply chain verification (base image digest for security audit)
    echo "Supply Chain Security:"
    echo "  Base image:         registry.access.redhat.com/ubi9/ubi-minimal:latest"
    echo "  Base image digest:  ${UBI9_BASE_DIGEST:-unknown}"
    echo ""

    # Runtime environment (dynamic - only knowable at runtime)
    echo "Runtime Environment:"
    echo "  Hostname:           $(hostname 2>/dev/null || echo 'unknown')"

    # Kubernetes detection (safe - only if vars exist)
    if [ -n "${KUBERNETES_SERVICE_HOST}" ]; then
      echo "  Kubernetes:         Yes"
      echo "    API Server:       ${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
      if [ -n "${HOSTNAME}" ]; then
        echo "    Pod:              ${HOSTNAME}"
      fi
    fi
    echo ""

    echo "================================================================================"
    echo "Starting OpenSearch..."
    echo "================================================================================"
    echo ""
}

print_startup_banner

# Export OpenSearch paths
export OPENSEARCH_HOME=${OPENSEARCH_HOME:-/opt/opensearch}
export OPENSEARCH_PATH_CONF=${OPENSEARCH_PATH_CONF:-/etc/opensearch}
export OPENSEARCH_DATA_DIR=${OPENSEARCH_DATA_DIR:-/var/lib/opensearch}
export OPENSEARCH_LOG_DIR=${OPENSEARCH_LOG_DIR:-/var/log/opensearch}

# The virtual file /proc/self/cgroup should list the current cgroup
# membership. For each hierarchy, you can follow the cgroup path from
# this file to the cgroup filesystem (usually /sys/fs/cgroup/) and
# introspect the statistics for the cgroup for the given
# hierarchy. Alas, Docker breaks this by mounting the container
# statistics at the root while leaving the cgroup paths as the actual
# paths. Therefore, OpenSearch provides a mechanism to override
# reading the cgroup path from /proc/self/cgroup and instead uses the
# cgroup path defined the JVM system property
# opensearch.cgroups.hierarchy.override. Therefore, we set this value here so
# that cgroup statistics are available for the container this process
# will run in.
export OPENSEARCH_JAVA_OPTS="-Dopensearch.cgroups.hierarchy.override=/ $OPENSEARCH_JAVA_OPTS"

# Set default environment variables if not provided
export OPENSEARCH_CLUSTER_NAME="${OPENSEARCH_CLUSTER_NAME:-axonopsdb-search}"
export OPENSEARCH_NODE_NAME="${OPENSEARCH_NODE_NAME:-${HOSTNAME}}"
export OPENSEARCH_NETWORK_HOST="${OPENSEARCH_NETWORK_HOST:-0.0.0.0}"
export OPENSEARCH_DISCOVERY_TYPE="${OPENSEARCH_DISCOVERY_TYPE:-single-node}"

# JVM heap settings (default: 8G, matches AxonDB Time-Series)
export OPENSEARCH_HEAP_SIZE="${OPENSEARCH_HEAP_SIZE:-8g}"

echo "Configuration:"
echo "  Cluster Name:       ${OPENSEARCH_CLUSTER_NAME}"
echo "  Node Name:          ${OPENSEARCH_NODE_NAME}"
echo "  Network Host:       ${OPENSEARCH_NETWORK_HOST}"
echo "  Discovery Type:     ${OPENSEARCH_DISCOVERY_TYPE}"
echo "  Heap Size:          ${OPENSEARCH_HEAP_SIZE}"
echo ""

# Apply environment variable substitutions to opensearch.yml
_sed-in-place() {
    local filename="$1"; shift
    local tempFile
    tempFile="$(mktemp)"
    sed "$@" "$filename" > "$tempFile"
    cat "$tempFile" > "$filename"
    rm "$tempFile"
}

# Apply cluster name
if [ -n "$OPENSEARCH_CLUSTER_NAME" ]; then
    _sed-in-place "/etc/opensearch/opensearch.yml" -r 's/^(# )?(cluster\.name:).*/\2 '"$OPENSEARCH_CLUSTER_NAME"'/'
fi

# Apply node name
if [ -n "$OPENSEARCH_NODE_NAME" ]; then
    _sed-in-place "/etc/opensearch/opensearch.yml" -r 's/^(# )?(node\.name:).*/\2 '"$OPENSEARCH_NODE_NAME"'/'
fi

# Apply network host
if [ -n "$OPENSEARCH_NETWORK_HOST" ]; then
    _sed-in-place "/etc/opensearch/opensearch.yml" -r 's/^(# )?(network\.host:).*/\2 '"$OPENSEARCH_NETWORK_HOST"'/'
fi

# Apply discovery type
if [ -n "$OPENSEARCH_DISCOVERY_TYPE" ]; then
    _sed-in-place "/etc/opensearch/opensearch.yml" -r 's/^(# )?(discovery\.type:).*/\2 '"$OPENSEARCH_DISCOVERY_TYPE"'/'
fi

# Apply heap size override to jvm.options if env var set
if [ -n "$OPENSEARCH_HEAP_SIZE" ]; then
    _sed-in-place "/etc/opensearch/jvm.options" -r 's/^-Xms[0-9]+[GgMm]$/-Xms'"$OPENSEARCH_HEAP_SIZE"'/'
    _sed-in-place "/etc/opensearch/jvm.options" -r 's/^-Xmx[0-9]+[GgMm]$/-Xmx'"$OPENSEARCH_HEAP_SIZE"'/'
fi

echo "✓ Configuration applied to opensearch.yml"
echo ""

# Files created by OpenSearch should always be group writable too
umask 0002

# Prevent root execution
if [[ "$(id -u)" == "0" ]]; then
    echo "OpenSearch cannot run as root. Please start your container as another user."
    exit 1
fi

# Initialize OpenSearch security in background (non-blocking)
# This will wait for OpenSearch to be ready, then:
#   1. Install demo SSL configuration (required for security plugin)
#   2. Create custom admin user (if AXONOPS_SEARCH_USER and AXONOPS_SEARCH_PASSWORD are set)
# Can be disabled by setting INIT_OPENSEARCH_SECURITY=false
INIT_OPENSEARCH_SECURITY="${INIT_OPENSEARCH_SECURITY:-true}"

# Performance Analyzer - disabled by default (AxonOps provides monitoring)
export DISABLE_PERFORMANCE_ANALYZER_AGENT_CLI="${DISABLE_PERFORMANCE_ANALYZER_AGENT_CLI:-true}"

# Display security configuration
if [ "$DISABLE_SECURITY_PLUGIN" = "true" ]; then
    echo "⚠ WARNING: Security plugin disabled (DISABLE_SECURITY_PLUGIN=true)"
    echo "  This is NOT recommended for production!"
elif [ -n "$AXONOPS_SEARCH_USER" ] && [ -n "$AXONOPS_SEARCH_PASSWORD" ]; then
    echo "✓ Security enabled with custom admin user: $AXONOPS_SEARCH_USER"
else
    echo "✓ Security enabled with default demo configuration"
    echo "  Default credentials: admin / admin (change for production!)"
fi
echo ""

if [ "$INIT_OPENSEARCH_SECURITY" = "true" ]; then
    echo "Starting security initialization in background..."
    (/usr/local/bin/init-opensearch.sh > ${OPENSEARCH_LOG_DIR}/init-opensearch.log 2>&1 &)
else
    echo "OpenSearch security initialization disabled (INIT_OPENSEARCH_SECURITY=false)"
    echo "Writing semaphore file to allow healthcheck to proceed..."
    # Write semaphore immediately so healthcheck doesn't block
    # Located in /var/lib/opensearch (persistent volume) not /etc (ephemeral)
    mkdir -p ${OPENSEARCH_DATA_DIR}/.axonops
    {
        echo "COMPLETED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo "RESULT=skipped"
        echo "REASON=disabled_by_env_var"
    } > ${OPENSEARCH_DATA_DIR}/.axonops/init-security.done
fi

# Parse Docker env vars to customize OpenSearch
# e.g. Setting the env var cluster.name=testcluster
# will cause OpenSearch to be invoked with -Ecluster.name=testcluster
opensearch_opts=()

# Handle special OpenSearch control variables (not dotted notation)
# These need to be handled before the general environment variable parsing
if [ "$DISABLE_SECURITY_PLUGIN" = "true" ]; then
    echo "Security plugin disabled (DISABLE_SECURITY_PLUGIN=true)"
    opensearch_opt="-Eplugins.security.disabled=true"
    opensearch_opts+=("${opensearch_opt}")
fi

# Parse environment variables with dotted notation
while IFS='=' read -r envvar_key envvar_value
do
    # OpenSearch settings need to have at least two dot separated lowercase
    # words, e.g. `cluster.name`, except for `processors` which we handle
    # specially
    if [[ "$envvar_key" =~ ^[a-z0-9_]+\.[a-z0-9_]+ || "$envvar_key" == "processors" ]]; then
        if [[ ! -z $envvar_value ]]; then
        opensearch_opt="-E${envvar_key}=${envvar_value}"
        opensearch_opts+=("${opensearch_opt}")
        fi
    fi
done < <(env)

if [ ${#opensearch_opts[@]} -gt 0 ]; then
    echo "Additional OpenSearch options from environment variables:"
    for opt in "${opensearch_opts[@]}"; do
        echo "  $opt"
    done
    echo ""
fi

echo ""
echo "=== Starting OpenSearch ==="
echo ""

# Prepend "opensearch" command if no argument was provided or if the first
# argument looks like a flag (i.e. starts with a dash).
if [ $# -eq 0 ] || [ "${1:0:1}" = '-' ]; then
    set -- opensearch "$@"
fi

# Execute command (CMD is ["opensearch"] which gets passed as $@)
exec "$@" "${opensearch_opts[@]}"
