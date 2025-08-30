# Opal Helm Chart

## R server

Opal deployment, with Rock spawner capability (on-demand R server management).

## Databases

Default database is an internally managed MongoDB instance. It is also possible to configure an externally managed one. A single instance of MongoDB server can contain both the databases of the Opal and of the Opal IDs. The later one is optional.

Other databases (PostgreSQL for instance) can also be internally/externally managed. There will be one PostgrSQL server per database, i.e. the Opal data and the Opal IDs. The later one is optional.

For each of these databases (internal/external Mongodb/PostgreSQL), a backup cron job can be enabled.

## Deployment

```
helm repo add obiba https://obiba.github.io/helm-charts
helm install myopal obiba/obiba-opal
```

## Values

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace` | Kubernetes namespace | `default` |
| `nameOverride` | Override the name of the chart | `"opal"` |
| `global.storageClassName` | Storage class for PVCs (leave empty for default) | `""` |
| `global.existingSecret` | Global existing secret name for credentials (can be overridden per component) | `""` |

### Service Account

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.name` | Service account name for Rock spawner | `rock-spawner-service-account` |

### MongoDB Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `useMongo` | Apply MongoDB configuration to Opal | `true` |
| `mongo.enabled` | Enable internally managed MongoDB | `true` |
| `mongo.name` | MongoDB StatefulSet name | `mongo` |
| `mongo.image` | MongoDB container image | `mongo:8.0` |
| `mongo.pvcSize` | Storage size for MongoDB PVC | `1Gi` |
| `mongo.backup.enabled` | Enable MongoDB backup cronjob | `false` |
| `mongo.backup.schedule` | Backup schedule (cron format) | `"0 1 * * *"` |
| `mongo.backup.pvcSize` | Storage size for backup PVC | `2Gi` |
| `mongo.host` | MongoDB host (internal or external) | `mongo` |
| `mongo.port` | MongoDB port | `"27017"` |
| `mongo.database.data` | MongoDB database name for data | `mongo` |
| `mongo.database.ids` | MongoDB database name for IDs. If empty, the database of IDs is not enabled. | `ids` |
| `mongo.user` | MongoDB username | `root` |
| `mongo.password` | MongoDB password | `example` |
| `mongo.existingSecret` | Name of existing secret for MongoDB credentials (overrides global.existingSecret) | `""` |
| `mongo.existingSecretKeys.database.data` | Secret key for data database name | `MONGO_DATABASE` |
| `mongo.existingSecretKeys.database.ids` | Secret key for IDs database name | `MONGO_IDS` |
| `mongo.existingSecretKeys.user` | Secret key for username | `MONGO_USER` |
| `mongo.existingSecretKeys.password` | Secret key for password | `MONGO_PASSWORD` |

### PostgreSQL Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `usePostgres.data` | Apply PostgreSQL data configuration to Opal | `false` |
| `usePostgres.ids` | Apply PostgreSQL IDs configuration to Opal | `false` |

#### PostgreSQL Data Database

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgres.data.enabled` | Enable internally managed PostgreSQL for data | `false` |
| `postgres.data.name` | PostgreSQL StatefulSet name | `postgres-data` |
| `postgres.data.image` | PostgreSQL container image | `postgres:17-alpine` |
| `postgres.data.pvcSize` | Storage size for PostgreSQL PVC | `1Gi` |
| `postgres.data.backup.enabled` | Enable PostgreSQL backup cronjob | `false` |
| `postgres.data.backup.schedule` | Backup schedule (cron format) | `"0 2 * * *"` |
| `postgres.data.backup.pvcSize` | Storage size for backup PVC | `2Gi` |
| `postgres.data.host` | PostgreSQL host (internal or external) | `postgres-data` |
| `postgres.data.port` | PostgreSQL port | `"5432"` |
| `postgres.data.database` | PostgreSQL database name | `postgres` |
| `postgres.data.user` | PostgreSQL username | `postgres` |
| `postgres.data.password` | PostgreSQL password | `example` |
| `postgres.data.existingSecret` | Name of existing secret for PostgreSQL credentials (overrides global.existingSecret) | `""` |
| `postgres.data.existingSecretKeys.database` | Secret key for database name | `POSTGRESDATA_DATABASE` |
| `postgres.data.existingSecretKeys.user` | Secret key for username | `POSTGRESDATA_USER` |
| `postgres.data.existingSecretKeys.password` | Secret key for password | `POSTGRESDATA_PASSWORD` |

#### PostgreSQL IDs Database

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgres.ids.enabled` | Enable internally managed PostgreSQL for IDs | `false` |
| `postgres.ids.name` | PostgreSQL StatefulSet name | `postgres-ids` |
| `postgres.ids.image` | PostgreSQL container image | `postgres:17-alpine` |
| `postgres.ids.pvcSize` | Storage size for PostgreSQL PVC | `1Gi` |
| `postgres.ids.backup.enabled` | Enable PostgreSQL backup cronjob | `false` |
| `postgres.ids.backup.schedule` | Backup schedule (cron format) | `"0 2 * * *"` |
| `postgres.ids.backup.pvcSize` | Storage size for backup PVC | `2Gi` |
| `postgres.ids.host` | PostgreSQL host (internal or external) | `postgres-ids` |
| `postgres.ids.port` | PostgreSQL port | `"5432"` |
| `postgres.ids.database` | PostgreSQL database name | `postgres` |
| `postgres.ids.user` | PostgreSQL username | `postgres` |
| `postgres.ids.password` | PostgreSQL password | `example` |
| `postgres.ids.existingSecret` | Name of existing secret for PostgreSQL credentials (overrides global.existingSecret) | `""` |
| `postgres.ids.existingSecretKeys.database` | Secret key for database name | `POSTGRESIDS_DATABASE` |
| `postgres.ids.existingSecretKeys.user` | Secret key for username | `POSTGRESIDS_USER` |
| `postgres.ids.existingSecretKeys.password` | Secret key for password | `POSTGRESIDS_PASSWORD` |

### Opal Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opal.image` | Opal container image | `obiba/opal:latest` |
| `opal.imagePullPolicy` | Image pull policy | `Always` |
| `opal.pvcSize` | Storage size for Opal PVC | `1Gi` |
| `opal.javaOpts` | Java options for Opal | `"-Xms1G -Xmx2G -XX:+UseG1GC"` |
| `opal.backup.enabled` | Enable Opal files backup cronjob | `false` |
| `opal.backup.schedule` | Backup schedule (cron format) | `"0 3 * * *"` |
| `opal.backup.pvcSize` | Storage size for backup PVC | `2Gi` |

#### Opal Admin Password

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opal.adminPassword.password` | Opal administrator password | `password` |
| `opal.adminPassword.existingSecret` | Name of existing secret for admin password (overrides global.existingSecret) | `""` |
| `opal.adminPassword.secretKey` | Secret key for admin password | `OPAL_ADMINISTRATOR_PASSWORD` |

#### Opal Pod Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opal.resources.requests.memory` | Memory request | `1Gi` |
| `opal.resources.requests.cpu` | CPU request | `"1"` |
| `opal.resources.limits.memory` | Memory limit | `2Gi` |
| `opal.resources.limits.cpu` | CPU limit | `"2"` |

#### Rock (R Server) Pods Configuration

This section declares the default Rock server pods specifications.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opal.rock.imagesAllowed` | Comma-separated list of allowed Rock images. Empty value means that any images can be declared in the pod specifications.  | `""` |
| `opal.rock.specs[0].id` | Rock server profile identifier | `default` |
| `opal.rock.specs[0].type` | Rock server type | `rock` |
| `opal.rock.specs[0].description` | Rock server description | - |
| `opal.rock.specs[0].enabled` | Enable this Rock specification | `true` |
| `opal.rock.specs[0].namespace` | Namespace in which pod is to be created. Empty means same as Opal's. | - |
| `opal.rock.specs[0].nodeName` | Name of the node in which pod is to be created. | - |
| `opal.rock.specs[0].labels[0].key` | Pod label key | - |
| `opal.rock.specs[0].labels[0].value` | Pod label value | - |
| `opal.rock.specs[0].nodeSelector[0].key` | Node selection rule's key | - |
| `opal.rock.specs[0].nodeSelector[0].value` | Node selection rule's value | - |
| `opal.rock.specs[0].tolerations[0].key` | Pod [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) key | - |
| `opal.rock.specs[0].tolerations[0].operator` | Pod [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) operator | - |
| `opal.rock.specs[0].tolerations[0].value` | Pod [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) value | - |
| `opal.rock.specs[0].tolerations[0].effect` | Pod [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) effect | - |
| `opal.rock.specs[0].tolerations[0].tolerationSeconds` | Pod [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) seconds | - |
| `opal.rock.specs[0].container.name` | Pod name prefix | `rock-default` |
| `opal.rock.specs[0].container.image` | Rock container image | `datashield/rock-base:latest` |
| `opal.rock.specs[0].container.imagePullPolicy` | Image pull policy | `IfNotPresent` |
| `opal.rock.specs[0].container.imagePullSecret` | Image pull secret | - |
| `opal.rock.specs[0].container.port` | Rock container port | `8085` |
| `opal.rock.specs[0].container.resources.requests.cpu` | CPU request | `1000m` |
| `opal.rock.specs[0].container.resources.requests.memory` | Memory request | `500Mi` |
| `opal.rock.specs[0].container.resources.limits.cpu` | CPU limit | `2000m` |
| `opal.rock.specs[0].container.resources.limits.memory` | Memory limit | `1Gi` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class name | `"nginx"` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts[0].host` | Hostname | `opal.local` |
| `ingress.hosts[0].paths[0].path` | Path | `/` |
| `ingress.hosts[0].paths[0].pathType` | Path type | `Prefix` |
| `ingress.tls` | TLS configuration | `[]` |

## Examples

### Using Global Secret for All Credentials

```yaml
global:
  existingSecret: "opal-credentials"

# All components will use the global secret unless overridden
mongo:
  # Uses global.existingSecret
  enabled: false
  host: mongodb.example.com

postgres:
  data:
    # Uses global.existingSecret
    enabled: false
    host: postgres.example.com

opal:
  # Uses global.existingSecret for admin password
  adminPassword:
    # Will use global.existingSecret with key OPAL_ADMINISTRATOR_PASSWORD
    password: ""  # Not used when existingSecret is set
```

### Mixing Global and Component-Specific Secrets

```yaml
global:
  existingSecret: "shared-credentials"

mongo:
  # Override global secret for MongoDB only
  existingSecret: "mongodb-specific-secret"
  enabled: false
  host: mongodb.example.com

postgres:
  data:
    # Uses global.existingSecret
    enabled: false
    host: postgres.example.com

opal:
  adminPassword:
    # Override global secret for Opal admin password
    existingSecret: "opal-admin-secret"
```

### Using External MongoDB

```yaml
useMongo: true
mongo:
  enabled: false  # Disable internal MongoDB
  host: mongodb.example.com
  port: "27017"
  database:
    data: opal_data
    ids: opal_ids
  user: opal_user
  existingSecret: mongodb-credentials
```

### Using External PostgreSQL

```yaml
usePostgres:
  data: true
postgres:
  data:
    enabled: false  # Disable internal PostgreSQL
    host: postgres.example.com
    port: "5432"
    database: opal_db
    user: opal_user
    existingSecret: postgres-credentials
```

### Enabling Backups

```yaml
mongo:
  backup:
    enabled: true
    schedule: "0 2 * * *"  # Daily at 2 AM
    pvcSize: 5Gi

postgres:
  data:
    backup:
      enabled: true
      schedule: "0 3 * * *"  # Daily at 3 AM
      pvcSize: 10Gi

opal:
  backup:
    enabled: true
    schedule: "0 4 * * *"  # Daily at 4 AM
    pvcSize: 2Gi
```

### Custom Storage Classes

```yaml
global:
  storageClassName: "fast-ssd"

# Or per component
mongo:
  pvcSize: 2Gi
  backup:
    pvcSize: 5Gi

postgres:
  data:
    pvcSize: 5Gi
    backup:
      pvcSize: 10Gi
```

### Rock Pod Configuration with Labels, Node Selection and Tolerations

```yaml
opal:
  rock:
    # Allow only specific Rock images
    imagesAllowed: "datashield/rock-base:latest,datashield/rock-demodata:latest"
    specs:
      - id: default
        type: rock
        description: "Production Rock server for data analysis"
        enabled: true
        # Target specific namespace (optional)
        namespace: "rock-servers"
        # Target specific node (optional)
        nodeName: "worker-node-1"
        # Add custom labels to Rock pods
        labels:
          - key: "environment"
            value: "production"
          - key: "team"
            value: "datascience"
          - key: "cost-center"
            value: "research"
        # Select nodes with specific labels
        nodeSelector:
          - key: "node-type"
            value: "compute-optimized"
          - key: "storage"
            value: "ssd"
        # Allow pods on tainted nodes
        tolerations:
          - key: "dedicated"
            operator: "Equal"
            value: "research"
            effect: "NoSchedule"
          - key: "gpu"
            operator: "Exists"
            effect: "NoExecute"
            tolerationSeconds: 3600
        container:
          name: rock-production
          image: datashield/rock-base:latest
          imagePullPolicy: IfNotPresent
          imagePullSecret: "private-registry-secret"
          port: 8085
          resources:
            requests:
              cpu: 2000m
              memory: 1Gi
            limits:
              cpu: 4000m
              memory: 4Gi
      
      # Additional Rock specification for development
      - id: development
        type: rock
        description: "Development Rock server"
        enabled: true
        labels:
          - key: "environment"
            value: "development"
        nodeSelector:
          - key: "node-type"
            value: "general-purpose"
        tolerations:
          - key: "development"
            operator: "Equal"
            value: "true"
            effect: "NoSchedule"
        container:
          name: rock-dev
          image: datashield/rock-demodata:latest
          imagePullPolicy: Always
          port: 8085
          resources:
            requests:
              cpu: 500m
              memory: 512Mi
            limits:
              cpu: 1000m
              memory: 1Gi
```

### Rock Pod Configuration for GPU Workloads

```yaml
opal:
  rock:
    specs:
      - id: gpu-enabled
        type: rock
        description: "GPU-accelerated Rock server for ML workloads"
        enabled: true
        # Target GPU nodes
        nodeSelector:
          - key: "accelerator"
            value: "nvidia-tesla-v100"
        # Tolerate GPU node taints
        tolerations:
          - key: "nvidia.com/gpu"
            operator: "Exists"
            effect: "NoSchedule"
        # Add GPU-specific labels
        labels:
          - key: "workload-type"
            value: "gpu-compute"
          - key: "gpu-memory"
            value: "16gb"
        container:
          name: rock-gpu
          image: datashield/rock-gpu:latest
          resources:
            requests:
              cpu: 4000m
              memory: 8Gi
              nvidia.com/gpu: 1
            limits:
              cpu: 8000m
              memory: 16Gi
              nvidia.com/gpu: 1
```

