# AxonOps Server Helm Chart

AxonOps Server is a unified observability platform for Apache Cassandra that provides comprehensive monitoring, alerting, backup, and management capabilities.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- Elasticsearch cluster (for metrics storage)

## Installing the Chart

To install the chart with the release name `axonops-server`:

```bash
helm install axonops-server ./axon-server \
  --set config.org_name="myorg" \
  --set config.license_key="your-license-key" \
  --set elasticHost="http://elasticsearch:9200" \
  --set dashboardUrl="https://axonops.mycompany.com"
```

## Uninstalling the Chart

To uninstall/delete the `axonops-server` deployment:

```bash
helm delete axonops-server
```

## Configuration

The following table lists the configurable parameters of the AxonOps Server chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | AxonOps Server image repository | `registry.axonops.com/axonops-public/axonops-docker/axon-server` |
| `image.tag` | AxonOps Server image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Secrets for pulling images from private registry | `[]` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full name | `""` |
| `replicaCount` | Number of replicas (should be 1 for AxonOps Server) | `1` |

### AxonOps Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `elasticHost` | Elasticsearch endpoint URL | `http://axonops-elastic:9200` |
| `dashboardUrl` | Publicly accessible URL for AxonOps Dashboard | `https://axonops.example.com` |
| `config.org_name` | Your organization name | `example` |
| `config.license_key` | AxonOps license key | `""` |
| `config.listener.host` | Listen host for API and agents | `0.0.0.0` |
| `config.listener.api_port` | API port (server <-> dashboard) | `8080` |
| `config.listener.agents_port` | Agents port (server <-> agents) | `1888` |
| `config.alerting.notification_interval` | Time before sending notification again | `3h` |
| `config.tls.mode` | TLS mode: disabled, TLS, or mTLS | `disabled` |
| `config.auth.enabled` | Enable authentication | `false` |
| `config.extraConfig` | Additional configuration options | `{}` |

### Service Configuration

#### API Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `apiService.type` | Service type for API | `ClusterIP` |
| `apiService.listenPort` | API service port | `8080` |
| `apiService.annotations` | API service annotations | `{}` |
| `apiService.nodePort` | NodePort for API (if type is NodePort) | `0` |
| `apiService.loadBalancerIP` | LoadBalancer IP for API | `""` |

#### Agent Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `agentService.type` | Service type for agents | `ClusterIP` |
| `agentService.listenPort` | Agent service port | `1888` |
| `agentService.annotations` | Agent service annotations | `{}` |
| `agentService.nodePort` | NodePort for agents (if type is NodePort) | `0` |
| `agentService.loadBalancerIP` | LoadBalancer IP for agents | `""` |

### Ingress Configuration

#### API Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `apiIngress.enabled` | Enable API ingress | `false` |
| `apiIngress.className` | Ingress class name | `nginx` |
| `apiIngress.annotations` | API ingress annotations | `{}` |
| `apiIngress.hosts` | API ingress hosts | See values.yaml |
| `apiIngress.tls` | API ingress TLS configuration | `[]` |

#### Agent Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `agentIngress.enabled` | Enable agent ingress | `false` |
| `agentIngress.className` | Ingress class name | `nginx` |
| `agentIngress.annotations` | Agent ingress annotations | `{}` |
| `agentIngress.hosts` | Agent ingress hosts | See values.yaml |
| `agentIngress.tls` | Agent ingress TLS configuration | `[]` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class name | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Volume size | `10Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.automount` | Automount service account token | `true` |
| `serviceAccount.createClusterRole` | Create ClusterRole for Cassandra discovery | `false` |
| `serviceAccount.name` | Service account name | `""` |
| `podSecurityContext.enabled` | Enable pod security context | `false` |
| `podSecurityContext.runAsUser` | User ID | `1000` |
| `podSecurityContext.fsGroup` | Group ID | `1000` |
| `securityContext` | Container security context | See values.yaml |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | Not set |
| `resources.limits.memory` | Memory limit | Not set |
| `resources.requests.cpu` | CPU request | Not set |
| `resources.requests.memory` | Memory request | Not set |

### Probes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe` | Liveness probe configuration | See values.yaml |
| `readinessProbe` | Readiness probe configuration | See values.yaml |
| `startupProbe` | Startup probe configuration | See values.yaml |

### Other Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |
| `extraVolumes` | Extra volumes | `[]` |
| `extraVolumeMounts` | Extra volume mounts | `[]` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `deployment.annotations` | Pod annotations | `{}` |
| `deployment.env` | Environment variables | `{}` |
| `deployment.secretEnv` | Secret with env variables | `""` |

## Examples

### Basic Installation

```bash
helm install axonops-server ./axon-server \
  --set config.org_name="mycompany" \
  --set config.license_key="xxx-xxx-xxx" \
  --set elasticHost="http://elasticsearch.elastic.svc.cluster.local:9200"
```

### With External Access

```bash
helm install axonops-server ./axon-server \
  --set config.org_name="mycompany" \
  --set config.license_key="xxx-xxx-xxx" \
  --set elasticHost="http://elasticsearch:9200" \
  --set apiIngress.enabled=true \
  --set apiIngress.hosts[0].host="api.axonops.example.com" \
  --set agentIngress.enabled=true \
  --set agentIngress.hosts[0].host="agents.axonops.example.com"
```

### With LDAP Authentication

```yaml
# values-ldap.yaml
config:
  auth:
    enabled: true
    type: "LDAP"
    settings:
      host: "ldap.example.com"
      port: 636
      base: "dc=example,dc=com"
      useSSL: true
      bindDN: "cn=admin,dc=example,dc=com"
      bindPassword: "password"
      userFilter: "(uid=%s)"
```

```bash
helm install axonops-server ./axon-server -f values-ldap.yaml
```

### With Cassandra Discovery

To enable automatic discovery of Cassandra nodes in the cluster:

```bash
helm install axonops-server ./axon-server \
  --set serviceAccount.createClusterRole=true
```

## Upgrading

To upgrade an existing release:

```bash
helm upgrade axonops-server ./axon-server \
  --set config.org_name="mycompany" \
  --set config.license_key="xxx-xxx-xxx"
```

## Troubleshooting

### Check Server Logs

```bash
kubectl logs -l app.kubernetes.io/name=axon-server
```

### Verify Configuration

```bash
kubectl get configmap axonops-server-axon-server -o yaml
```

### Check Service Endpoints

```bash
kubectl get svc | grep axon-server
```

## License

For licensing information, please contact [AxonOps](https://axonops.com).

## Support

For support, please visit [https://axonops.com](https://axonops.com) or contact support@axonops.com.