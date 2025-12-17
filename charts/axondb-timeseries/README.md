# axondb-timeseries

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.0.5-1.0.0](https://img.shields.io/badge/AppVersion-5.0.5--1.0.0-informational?style=flat-square)

This helm chart installs the time series database for AxonOps

**Homepage:** <https://axonops.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| AxonOps Team | <info@aoxnops.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| authentication | object | `{"db_password":"","db_secret":"","db_user":""}` | ------------- The credentials will be passed to the container as environment variables: - AXONOPS_DB_USER: The username for database authentication - AXONOPS_DB_PASSWORD: The password for database authentication  These environment variables can be used by the application to authenticate with the database. |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| customLivenessProbe | object | `{}` |  |
| customReadinessProbe | object | `{}` |  |
| customStartupProbe | object | `{}` |  |
| envVars | list | `[]` |  |
| envVarsSecret | string | `""` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| heapSize | string | `"1024M"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/axonops/development/axondb-timeseries"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `5` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.commitlog.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.commitlog.annotations | object | `{}` |  |
| persistence.commitlog.enabled | bool | `false` |  |
| persistence.commitlog.mountPath | string | `"/var/lib/cassandra/commitlog"` |  |
| persistence.commitlog.size | string | `"5Gi"` |  |
| persistence.commitlog.storageClass | string | `""` |  |
| persistence.data.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.data.annotations | object | `{}` |  |
| persistence.data.mountPath | string | `"/var/lib/cassandra"` |  |
| persistence.data.size | string | `"10Gi"` |  |
| persistence.data.storageClass | string | `""` |  |
| persistence.enabled | bool | `true` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `999` |  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.failureThreshold | int | `5` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `30` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `999` |  |
| service.port | int | `9042` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.metricRelabelings | list | `[]` |  |
| serviceMonitor.port | string | `"jmx"` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| serviceMonitor.selector | object | `{}` |  |
| tls.cassandra.clientToNode.acceptedProtocols | string | `"TLSv1.2,TLSv1.3"` |  |
| tls.cassandra.clientToNode.cipherSuites | list | `[]` |  |
| tls.cassandra.clientToNode.enabled | bool | `false` |  |
| tls.cassandra.clientToNode.protocol | string | `"TLS"` |  |
| tls.cassandra.clientToNode.requireClientAuth | bool | `false` |  |
| tls.cassandra.clientToNode.storeType | string | `"JKS"` |  |
| tls.cassandra.internode.acceptedProtocols | string | `"TLSv1.2,TLSv1.3"` |  |
| tls.cassandra.internode.cipherSuites | list | `[]` |  |
| tls.cassandra.internode.encryption | string | `"all"` |  |
| tls.cassandra.internode.protocol | string | `"TLS"` |  |
| tls.cassandra.internode.requireClientAuth | bool | `true` |  |
| tls.cassandra.internode.storeType | string | `"JKS"` |  |
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

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
