ARG CASSANDRA_VERSION=4.0
FROM docker.io/k8ssandra/cass-management-api:${CASSANDRA_VERSION}-ubi

RUN echo "AXONOPS_BUILD: Inheriting from k8ssandra/cass-management-api:${CASSANDRA_VERSION}-ubi"

# Build arguments for OCI labels
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Legacy labels (for backward compatibility)
LABEL maintainer="AxonOps <info@axonops.com>"
LABEL name="AxonOps K8ssandra Apache Cassandra"
LABEL vendor="AxonOps"
LABEL url="https://axonops.com"
LABEL release="${CASSANDRA_VERSION}"
LABEL summary="Apache Cassandra with integrated AxonOps monitoring and management agent, designed for deployment on Kubernetes using K8ssandra Operator."
LABEL description="Docker container combining Apache Cassandra ${CASSANDRA_VERSION}, K8ssandra Management API, AxonOps Agent for monitoring and management, and cqlai modern CQL shell. Optimized for Kubernetes deployments with jemalloc memory optimization."

# OCI standard labels
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.authors="AxonOps <info@axonops.com>"
LABEL org.opencontainers.image.url="https://axonops.com"
LABEL org.opencontainers.image.documentation="https://github.com/axonops/axonops-cassandra-containers/blob/main/k8ssandra/README.md"
LABEL org.opencontainers.image.source="https://github.com/axonops/axonops-cassandra-containers"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.vendor="AxonOps"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.title="AxonOps K8ssandra Apache Cassandra ${CASSANDRA_VERSION}"
LABEL org.opencontainers.image.description="Docker container combining Apache Cassandra ${CASSANDRA_VERSION}, K8ssandra Management API, AxonOps Agent for monitoring and management, and cqlai modern CQL shell. Optimized for Kubernetes deployments with jemalloc memory optimization."
LABEL org.opencontainers.image.base.name="docker.io/k8ssandra/cass-management-api:${CASSANDRA_VERSION}-ubi"

ENV AXON_AGENT_LOG_OUTPUT=std
ARG MAJOR_VERSION=4.0
ARG TARGETARCH

USER root

# Update all packages to latest versions (security patches)
RUN echo "Updating all packages to latest versions..." && \
    microdnf update -y && \
    microdnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf

COPY axonops-yum-repo.repo /etc/yum.repos.d/axonops-yum.repo

# Install jemalloc for memory allocation optimization
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    microdnf install -y jemalloc && \
    ln -sf /usr/lib64/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf && \
    ldconfig && \
    microdnf remove -y epel-release && \
    microdnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf

# Install AxonOps agents and configure
RUN groupadd --gid 9988 axonops && \
    useradd --gid 9988 --uid 9988 --shell /bin/bash -c "AxonOps" -G cassandra axonops && \
    usermod -aG axonops cassandra && \
    microdnf -y install axon-cassandra4.0-agent axon-agent gettext && \
    chown -R cassandra:cassandra /etc/axonops /var/lib/axonops /var/log/axonops && \
    chmod 755 /usr/share/axonops/axon-agent && \
    rm -f /etc/axonops/axon-agent.yml && \
    touch /var/run/utmp && \
    microdnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf

# Install cqlai (latest release)
RUN RPM_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64" || echo "aarch64") && \
    CQLAI_VERSION=$(curl -s --retry 3 --retry-delay 2 https://api.github.com/repos/axonops/cqlai/releases/latest | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') && \
    if [ -z "$CQLAI_VERSION" ]; then echo "ERROR: Failed to fetch cqlai version" && exit 1; fi && \
    rpm -i https://github.com/axonops/cqlai/releases/download/v${CQLAI_VERSION}/cqlai-${CQLAI_VERSION}-1.${RPM_ARCH}.rpm && \
    rm -rf /var/tmp/rpm-* /var/cache/yum /var/cache/dnf

ENV JVM_EXTRA_OPTS="-javaagent:/usr/share/axonops/axon-cassandra${MAJOR_VERSION}-agent.jar=/etc/axonops/axon-agent.yml"
COPY axonops-entrypoint.sh /axonops-entrypoint.sh
RUN chmod 755 /axonops-entrypoint.sh

CMD ["/axonops-entrypoint.sh"]
