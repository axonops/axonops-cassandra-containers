# axon-server

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Install AxonOps server - Unified observability platform for Apache Cassandra

**Homepage:** <https://axonops.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| AxonOps Team | <info@axonops.com> | <https://axonops.com> |

## Source Code

* <https://github.com/axonops/axonops-containers>

## Requirements

Kubernetes: `>=1.19.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| agentIngress.annotations | object | `{}` |  |
| agentIngress.className | string | `"nginx"` |  |
| agentIngress.enabled | bool | `false` |  |
| agentIngress.hosts[0].host | string | `"agents.example.com"` |  |
| agentIngress.hosts[0].paths[0].path | string | `"/"` |  |
| agentIngress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| agentIngress.tls | list | `[]` |  |
| agentService.annotations | object | `{}` |  |
| agentService.clusterIP | string | `""` |  |
| agentService.externalIPs | list | `[]` |  |
| agentService.labels | object | `{}` |  |
| agentService.listenPort | int | `1888` |  |
| agentService.loadBalancerIP | string | `""` |  |
| agentService.loadBalancerSourceRanges | list | `[]` |  |
| agentService.nodePort | int | `0` |  |
| agentService.type | string | `"ClusterIP"` |  |
| apiIngress.annotations | object | `{}` |  |
| apiIngress.className | string | `"traefik"` |  |
| apiIngress.enabled | bool | `false` |  |
| apiIngress.hosts[0].host | string | `"api.example.com"` |  |
| apiIngress.hosts[0].paths[0].path | string | `"/"` |  |
| apiIngress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| apiIngress.tls | list | `[]` |  |
| apiService.annotations | object | `{}` |  |
| apiService.clusterIP | string | `""` |  |
| apiService.externalIPs | list | `[]` |  |
| apiService.labels | object | `{}` |  |
| apiService.listenPort | int | `8080` |  |
| apiService.loadBalancerIP | string | `""` |  |
| apiService.loadBalancerSourceRanges | list | `[]` |  |
| apiService.nodePort | int | `0` |  |
| apiService.type | string | `"ClusterIP"` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| config.alerting.notification_interval | string | `"3h"` |  |
| config.auth.enabled | bool | `false` |  |
| config.extraConfig.cql_autocreate_tables | bool | `true` |  |
| config.extraConfig.cql_batch_size | int | `100` |  |
| config.extraConfig.cql_hosts[0] | string | `"axondb-timeseries-headless.sergio.svc.cluster.local"` |  |
| config.extraConfig.cql_keyspace_replication | string | `"{ 'class': 'NetworkTopologyStrategy', 'axonopsdb_dc1': 1 }"` |  |
| config.extraConfig.cql_local_dc | string | `"axonopsdb_dc1"` |  |
| config.extraConfig.cql_max_searchqueriesparallelism | int | `100` |  |
| config.extraConfig.cql_metrics_cache_max_items | int | `500000` |  |
| config.extraConfig.cql_metrics_cache_max_size | int | `128` |  |
| config.extraConfig.cql_page_size | int | `100` |  |
| config.extraConfig.cql_password | string | `"axonops"` |  |
| config.extraConfig.cql_proto_version | int | `4` |  |
| config.extraConfig.cql_reconnectionpolicy_initialinterval | string | `"1s"` |  |
| config.extraConfig.cql_reconnectionpolicy_maxinterval | string | `"10s"` |  |
| config.extraConfig.cql_reconnectionpolicy_maxretries | int | `10` |  |
| config.extraConfig.cql_retrypolicy_max | string | `"10s"` |  |
| config.extraConfig.cql_retrypolicy_min | string | `"2s"` |  |
| config.extraConfig.cql_retrypolicy_numretries | int | `3` |  |
| config.extraConfig.cql_skip_verify | bool | `true` |  |
| config.extraConfig.cql_ssl | bool | `true` |  |
| config.extraConfig.cql_username | string | `"axonops"` |  |
| config.license_key | string | `""` |  |
| config.listener.agents_port | int | `1888` |  |
| config.listener.api_port | int | `8080` |  |
| config.listener.host | string | `"0.0.0.0"` |  |
| config.org_name | string | `"example"` |  |
| config.sslSecretName | string | `""` |  |
| config.tls.mode | string | `"disabled"` |  |
| dashboardUrl | string | `"https://axonops.example.com"` |  |
| deployment.annotations | object | `{}` |  |
| deployment.env | object | `{}` |  |
| deployment.secretEnv | string | `""` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.dockerRegistry | string | `""` |  |
| httpRoute.annotations | object | `{}` |  |
| httpRoute.enabled | bool | `false` |  |
| httpRoute.hostnames[0] | string | `"api.example.com"` |  |
| httpRoute.parentRefs[0].name | string | `"gateway"` |  |
| httpRoute.parentRefs[0].sectionName | string | `"http"` |  |
| httpRoute.rules[0].matches[0].path.type | string | `"PathPrefix"` |  |
| httpRoute.rules[0].matches[0].path.value | string | `"/"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.axonops.com/axonops-public/axonops-docker/axon-server"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| initResources | object | `{}` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/api/v1/healthz"` |  |
| livenessProbe.httpGet.port | string | `"api"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enableInitChown | bool | `true` |  |
| persistence.enabled | bool | `true` |  |
| persistence.size | string | `"1Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podManagementPolicy | string | `"OrderedReady"` |  |
| podSecurityContext.enabled | bool | `false` |  |
| podSecurityContext.fsGroup | int | `9988` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `9988` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/api/v1/healthz"` |  |
| readinessProbe.httpGet.port | string | `"api"` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| searchDb.hosts[0] | string | `"https://axondb-search-cluster-master:9200"` |  |
| searchDb.password | string | `"MyS3cur3P@ss2025"` |  |
| searchDb.skip_verify | bool | `true` |  |
| searchDb.username | string | `"admin"` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `9988` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.createClusterRole | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| sidecarResources | object | `{}` |  |
| startupProbe.failureThreshold | int | `60` |  |
| startupProbe.httpGet.path | string | `"/api/v1/healthz"` |  |
| startupProbe.httpGet.port | string | `"api"` |  |
| startupProbe.initialDelaySeconds | int | `0` |  |
| startupProbe.periodSeconds | int | `2` |  |
| startupProbe.timeoutSeconds | int | `3` |  |
| tolerations | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
