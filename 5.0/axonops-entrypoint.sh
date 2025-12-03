#!/bin/bash -x

touch /var/log/axonops/axon-agent.log

# Config generation
if [ ! -f /etc/axonops/axon-agent.yml ]; then
cat > /etc/axonops/axon-agent.yml <<END
axon-server:
    hosts: "${AXON_AGENT_HOST:-agents.axonops.cloud}"
axon-agent:
    key: ${AXON_AGENT_KEY}
    org: ${AXON_AGENT_ORG}
END
    if [ "$AXON_NTP_HOST" != "" ]; then
cat >> /etc/axonops/axon-agent.yml <<END
NTP:
    hosts:
      - ${AXON_NTP_HOST}
END
    fi
fi

# Start axon-agent in background
/usr/share/axonops/axon-agent $AXON_AGENT_ARGS 2>&1 | tee /var/log/axonops/axon-agent.log &

# Start Management API + Cassandra in foreground
# This keeps the container running as long as the management API is up
exec /docker-entrypoint.sh mgmtapi
