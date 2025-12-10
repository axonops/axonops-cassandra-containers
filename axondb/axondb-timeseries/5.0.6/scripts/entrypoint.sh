#!/bin/bash
set -e

# AxonDB Time-Series Entrypoint Script
# Processes cassandra.yaml template with environment variables and starts Cassandra

echo "=== AxonDB Time-Series Starting ==="
echo ""

# Fix JAVA_HOME and PATH to use Azul Zulu instead of base image's Temurin
if [ -d "/usr/lib/jvm/zulu17-ca-arm64" ]; then
    export JAVA_HOME="/usr/lib/jvm/zulu17-ca-arm64"
elif [ -d "/usr/lib/jvm/zulu17-ca-amd64" ]; then
    export JAVA_HOME="/usr/lib/jvm/zulu17-ca-amd64"
elif [ -d "/usr/lib/jvm/zulu17" ]; then
    export JAVA_HOME="/usr/lib/jvm/zulu17"
fi

# Prepend Azul Java to PATH (before base image's /opt/java/openjdk)
export PATH="${JAVA_HOME}/bin:${PATH}"

# Source build info if available
if [ -f /etc/axonops/build-info.txt ]; then
    source /etc/axonops/build-info.txt
    echo "Container Information:"
    echo "  Version:            ${CONTAINER_VERSION:-unknown}"
    echo "  Image:              ${CONTAINER_IMAGE:-unknown}"
    echo "  Build Date:         ${CONTAINER_BUILD_DATE:-unknown}"
    echo "  Production Release: ${IS_PRODUCTION_RELEASE:-false}"
    echo ""
    echo "Component Versions:"
    echo "  Cassandra:          ${CASSANDRA_VERSION:-unknown}"
    echo "  Java:               ${JAVA_VERSION:-unknown}"
    echo "  Jemalloc:           ${JEMALLOC_VERSION:-unknown}"
    echo "  OS:                 ${OS_VERSION:-unknown}"
    echo "  Platform:           ${PLATFORM:-unknown}"
    echo ""
fi

# Set default environment variables if not provided
# Export them so base image's docker-entrypoint.sh can use them
export CASSANDRA_CLUSTER_NAME="${CASSANDRA_CLUSTER_NAME:-axonopsdb-timeseries}"
export CASSANDRA_NUM_TOKENS="${CASSANDRA_NUM_TOKENS:-8}"
export CASSANDRA_LISTEN_ADDRESS="${CASSANDRA_LISTEN_ADDRESS:-auto}"
export CASSANDRA_RPC_ADDRESS="${CASSANDRA_RPC_ADDRESS:-0.0.0.0}"
export CASSANDRA_DC="${CASSANDRA_DC:-dc1}"
export CASSANDRA_RACK="${CASSANDRA_RACK:-rack1}"

# JVM heap settings
export CASSANDRA_HEAP_SIZE="${CASSANDRA_HEAP_SIZE:-2G}"
export CASSANDRA_HEAP_NEWSIZE="${CASSANDRA_HEAP_NEWSIZE:-512M}"

echo "Configuration:"
echo "  Cluster Name:       ${CASSANDRA_CLUSTER_NAME}"
echo "  DC/Rack:            ${CASSANDRA_DC}/${CASSANDRA_RACK}"
echo "  Num Tokens:         ${CASSANDRA_NUM_TOKENS}"
echo "  Listen Address:     ${CASSANDRA_LISTEN_ADDRESS}"
echo "  RPC Address:        ${CASSANDRA_RPC_ADDRESS}"
echo "  Heap Size:          ${CASSANDRA_HEAP_SIZE}"
echo "  Heap New Size:      ${CASSANDRA_HEAP_NEWSIZE}"
echo ""

# Apply environment variable substitutions to cassandra.yaml
# Copied from base image's docker-entrypoint.sh sed logic
_sed-in-place() {
    local filename="$1"; shift
    local tempFile
    tempFile="$(mktemp)"
    sed "$@" "$filename" > "$tempFile"
    cat "$tempFile" > "$filename"
    rm "$tempFile"
}

# Apply CASSANDRA_* environment variables to cassandra.yaml
for yaml in cluster_name num_tokens listen_address rpc_address broadcast_address broadcast_rpc_address endpoint_snitch; do
    var="CASSANDRA_${yaml^^}"
    val="${!var}"
    if [ "$val" ]; then
        _sed-in-place "/etc/cassandra/cassandra.yaml" -r 's/^(# )?('"$yaml"':).*/\2 '"$val"'/'
    fi
done

# Apply DC/Rack to cassandra-rackdc.properties
for rackdc in dc rack; do
    var="CASSANDRA_${rackdc^^}"
    val="${!var}"
    if [ "$val" ]; then
        _sed-in-place "/etc/cassandra/cassandra-rackdc.properties" -r 's/^('"$rackdc"'=).*/\1 '"$val"'/'
    fi
done

echo "✓ Configuration applied to cassandra.yaml"
echo ""

# Enable jemalloc for memory optimization
if [ -f /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 ]; then
    export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
    echo "✓ jemalloc enabled (x86_64)"
elif [ -f /usr/lib/aarch64-linux-gnu/libjemalloc.so.2 ]; then
    export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2
    echo "✓ jemalloc enabled (aarch64)"
else
    echo "⚠ jemalloc not found, continuing without it"
fi

# Set JVM options for Shenandoah GC
export JVM_OPTS="$JVM_OPTS -Xms${CASSANDRA_HEAP_SIZE}"
export JVM_OPTS="$JVM_OPTS -Xmx${CASSANDRA_HEAP_SIZE}"
export JVM_OPTS="$JVM_OPTS -Xmn${CASSANDRA_HEAP_NEWSIZE}"
export JVM_OPTS="$JVM_OPTS -XX:+UseShenandoahGC"
export JVM_OPTS="$JVM_OPTS -XX:+AlwaysPreTouch"

echo ""
echo "=== Starting Cassandra ==="
echo ""

# Execute the original Cassandra entrypoint or command
exec /usr/local/bin/docker-entrypoint.sh "$@"
