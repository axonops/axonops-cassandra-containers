# axondb-search

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.3.2-1.1.0](https://img.shields.io/badge/AppVersion-3.3.2--1.1.0-informational?style=flat-square)

This helm chart installs the backeding search engine for AxonOps

**Homepage:** <https://opensearch.org>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| AxonOps Team | <info@aoxnops.com> |  |

## Source Code

* <https://github.com/opensearch-project/opensearch>
* <https://github.com/opensearch-project/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| antiAffinity | string | `"soft"` |  |
| antiAffinityTopologyKey | string | `"kubernetes.io/hostname"` |  |
| authentication.opensearch_password | string | `""` |  |
| authentication.opensearch_secret | string | `""` |  |
| authentication.opensearch_user | string | `""` |  |
| clusterName | string | `"axondb-search-cluster"` |  |
| config."opensearch.yml" | string | `"cluster.name: opensearch-cluster\n\n# Bind to all interfaces because we don't know what IP address Docker will assign to us.\nnetwork.host: 0.0.0.0\n"` |  |
| config.overrideExisting | bool | `false` |  |
| customAntiAffinity | object | `{}` |  |
| enableServiceLinks | bool | `true` |  |
| envFrom | list | `[]` |  |
| extraContainers | list | `[]` |  |
| extraEnvs | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraObjects | list | `[]` | Array of extra K8s manifests to deploy |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fsGroup | string | `""` |  |
| fullnameOverride | string | `""` |  |
| global.dockerRegistry | string | `""` |  |
| hostAliases | list | `[]` |  |
| httpHostPort | string | `""` |  |
| httpPort | int | `9200` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/axonops/development/axondb-search"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0] | string | `"chart-example.local"` |  |
| ingress.ingressLabels | object | `{}` |  |
| ingress.path | string | `"/"` |  |
| ingress.tls | list | `[]` |  |
| initResources | object | `{}` |  |
| labels | object | `{}` |  |
| lifecycle | object | `{}` |  |
| livenessProbe | object | `{}` |  |
| majorVersion | string | `"3"` |  |
| masterService | string | `"axondb-search-cluster-master"` |  |
| masterTerminationFix | bool | `false` |  |
| maxUnavailable | int | `1` |  |
| metricsPort | int | `9600` |  |
| nameOverride | string | `""` |  |
| networkHost | string | `"0.0.0.0"` |  |
| networkPolicy.create | bool | `false` |  |
| networkPolicy.http.enabled | bool | `false` |  |
| nodeAffinity | object | `{}` |  |
| nodeGroup | string | `"master"` |  |
| nodeSelector | object | `{}` |  |
| openSearchAnnotations | object | `{}` |  |
| opensearchHeapSize | string | `"2g"` |  |
| opensearchHome | string | `"/usr/share/opensearch"` |  |
| opensearchInitialAdminPassword | string | `""` |  |
| opensearchJavaOps | string | `""` |  |
| opensearchLifecycle | object | `{}` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enableInitChown | bool | `true` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.labels.additionalLabels | object | `{}` |  |
| persistence.labels.enabled | bool | `false` |  |
| persistence.size | string | `"8Gi"` |  |
| plugins.enabled | bool | `false` |  |
| plugins.installList | list | `[]` |  |
| plugins.removeList | list | `[]` |  |
| podAffinity | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podManagementPolicy | string | `"Parallel"` |  |
| podSecurityContext.fsGroup | int | `999` |  |
| podSecurityContext.runAsUser | int | `999` |  |
| podSecurityPolicy.create | bool | `false` |  |
| podSecurityPolicy.name | string | `""` |  |
| podSecurityPolicy.spec.fsGroup.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.privileged | bool | `true` |  |
| podSecurityPolicy.spec.runAsUser.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.seLinux.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.supplementalGroups.rule | string | `"RunAsAny"` |  |
| podSecurityPolicy.spec.volumes[0] | string | `"secret"` |  |
| podSecurityPolicy.spec.volumes[1] | string | `"configMap"` |  |
| podSecurityPolicy.spec.volumes[2] | string | `"persistentVolumeClaim"` |  |
| podSecurityPolicy.spec.volumes[3] | string | `"emptyDir"` |  |
| priorityClassName | string | `""` |  |
| protocol | string | `"https"` |  |
| rbac.automountServiceAccountToken | bool | `false` |  |
| rbac.create | bool | `false` |  |
| rbac.serviceAccountAnnotations | object | `{}` |  |
| rbac.serviceAccountName | string | `""` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.tcpSocket.port | int | `9200` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicas | int | `1` |  |
| resources.requests.cpu | string | `"1000m"` |  |
| resources.requests.memory | string | `"4096Mi"` |  |
| roles[0] | string | `"master"` |  |
| roles[1] | string | `"ingest"` |  |
| roles[2] | string | `"data"` |  |
| roles[3] | string | `"remote_cluster_client"` |  |
| schedulerName | string | `""` |  |
| secretMounts | list | `[]` |  |
| securityConfig.actionGroupsSecret | string | `nil` |  |
| securityConfig.config.data | object | `{}` |  |
| securityConfig.config.dataComplete | bool | `true` |  |
| securityConfig.config.securityConfigSecret | string | `""` |  |
| securityConfig.configSecret | string | `nil` |  |
| securityConfig.enabled | bool | `true` |  |
| securityConfig.internalUsersSecret | string | `nil` |  |
| securityConfig.path | string | `"/usr/share/opensearch/config/opensearch-security"` |  |
| securityConfig.rolesMappingSecret | string | `nil` |  |
| securityConfig.rolesSecret | string | `nil` |  |
| securityConfig.tenantsSecret | string | `nil` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `999` |  |
| service.annotations | object | `{}` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.headless.annotations | object | `{}` |  |
| service.httpPortName | string | `"http"` |  |
| service.labels | object | `{}` |  |
| service.labelsHeadless | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.metricsPortName | string | `"metrics"` |  |
| service.nodePort | string | `""` |  |
| service.transportPortName | string | `"transport"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceMonitor.basicAuth.enabled | bool | `false` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"10s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.path | string | `"/_prometheus/metrics"` |  |
| serviceMonitor.scheme | string | `"http"` |  |
| serviceMonitor.tlsConfig | object | `{}` |  |
| sidecarResources | object | `{}` |  |
| singleNode | bool | `true` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `5` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.tcpSocket.port | int | `9200` |  |
| startupProbe.timeoutSeconds | int | `3` |  |
| sysctl.enabled | bool | `false` |  |
| sysctlInit.enabled | bool | `false` |  |
| sysctlVmMaxMapCount | int | `262144` |  |
| terminationGracePeriod | int | `120` |  |
| tls.certManager.certificate.commonName | string | `""` |  |
| tls.certManager.certificate.dnsNames | list | `[]` |  |
| tls.certManager.certificate.duration | string | `"43800h"` |  |
| tls.certManager.certificate.ipAddresses | list | `[]` |  |
| tls.certManager.certificate.renewBefore | string | `"720h"` |  |
| tls.certManager.certificate.secretName | string | `"axondb-timeseries-tls-cert"` |  |
| tls.certManager.enabled | bool | `false` |  |
| tls.certManager.issuer.createSelfSigned | bool | `true` |  |
| tls.certManager.issuer.kind | string | `"ClusterIssuer"` |  |
| tls.certManager.issuer.name | string | `""` |  |
| tls.certManager.keystorePassword | string | `"changeme"` |  |
| tls.enabled | bool | `false` |  |
| tls.manual.existingSecret | string | `""` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| transportHostPort | string | `""` |  |
| transportPort | int | `9300` |  |
| updateStrategy | string | `"RollingUpdate"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
