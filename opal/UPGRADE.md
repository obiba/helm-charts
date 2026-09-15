# Opal Helm Chart Upgrade Notes

## 2.0.0

Chart 2.0.0 moves the Opal image from 5.7.6 to 6.0. Opal 6.0 changes where it keeps its own configuration (projects, users, permissions, registered databases, DataSHIELD profiles...): it leaves OrientDB for an embedded H2 database, or a PostgreSQL server. The migration runs by itself the first time the upgraded Opal starts. What follows is what you have to decide or check around it; the full account is in the [Opal upgrade notes](https://github.com/obiba/opal/blob/master/UPGRADE.md).

Replace `myopal` with your Helm release name and `-n mynamespace` with your namespace.

### Before upgrading

1. If you are upgrading from a chart version <= 1.2.1, apply the [1.3.0 procedure](#130) first.

2. Back up the Opal volume. The migration reads `data/orientdb` and writes `data/config`, both on the `opal-storage-opal-0` PVC, and the key to the new database goes in `data/opal-config.xml` on the same volume. If `opal.backup` is enabled, trigger a run now rather than waiting for the schedule:

   ```
   kubectl create job -n mynamespace --from=cronjob/opal-backup-cronjob opal-backup-pre-2.0.0
   ```

   Back up the data databases as usual (`mongo.backup`, `postgres.data.backup`, `postgres.ids.backup`), although the upgrade does not touch them.

3. Decide now whether the configuration goes to PostgreSQL. This is the one moment where it can be chosen: Opal migrates into whatever is configured at its first 6.0 start, and once the configuration exists in H2, turning `usePostgres.config` on gives an Opal with an empty configuration (no administrator password, no databases, no projects). To use PostgreSQL, add it to the values of this same `helm upgrade`:

   ```yaml
   usePostgres:
     config: true
   postgres:
     config:
       enabled: true   # or false with host/database/credentials of an external, empty database
       backup:
         enabled: true
   ```

   See [Opal configuration on PostgreSQL](README.md#opal-configuration-on-postgresql) in the README. Leaving `usePostgres.config` at `false` keeps the embedded H2 database and requires nothing else.

4. If `usePostgres.ids` is enabled with the internal PostgreSQL server, check `postgres.ids.pvcSize`. Chart versions up to 1.3.1 sized the IDs volume from `postgres.data.pvcSize` by mistake; 2.0.0 reads `postgres.ids.pvcSize`. The size is in the immutable `volumeClaimTemplates` of the `postgres-ids` StatefulSet, so if the two values differ the upgrade fails with the `Forbidden: updates to statefulset spec` error described under 1.3.0. Look up the size the PVC was created with:

   ```
   kubectl get pvc -n mynamespace postgres-storage-postgres-ids-0
   ```

   and set `postgres.ids.pvcSize` to that value in your values file. Nothing needs to be done when neither `postgres.data.pvcSize` nor `postgres.ids.pvcSize` is set, or both are equal.

### Upgrading

```
helm repo update
helm upgrade myopal obiba/opal -n mynamespace [-f my-values.yaml]
```

### After upgrading

1. Read the migration log before declaring the upgrade done. It is the only place the record counts appear: what was found in OrientDB, a line per class as it migrates, and a summary. A failure names the class and the record it was on; the OrientDB folder is untouched, so the pod can simply be restarted once the cause is dealt with, and a repeated run is always safe.

   ```
   kubectl logs -n mynamespace opal-0 | grep -i -E "migrat|orientdb|config"
   ```

2. Log in and check that the projects, the users and the registered databases are there.

3. Keep `data/orientdb` on the volume until you are satisfied. It is the way back (see rollback below) and nothing reads it any more. Once the upgraded installation has been verified it can be deleted:

   ```
   kubectl exec -n mynamespace opal-0 -- rm -rf /srv/data/orientdb
   ```

4. If a backup of your own targets `data/orientdb` on the Opal volume, point it at `data/config` and `data/opal-config.xml` instead: they only work as a pair. The chart's `opal.backup` archives the whole `data` directory and needs no change. With `usePostgres.config`, the pair is `postgres.config.backup` and `opal.backup` from the same moment.

5. Opal 6.0 verifies the certificate and the host name of a remote Opal in "Import from Opal" tasks. An import from an Opal with a self-signed certificate fails after the upgrade until that certificate is added under *Administration > Identities > Credentials*. Rotate the personal access tokens and passwords used for such imports, as they were sent without verification before.

6. Optional: exporting to OpenTelemetry (`opal.otel`) on a volume created by Opal 5 needs the `logback.xml` update described under [Exporting to OpenTelemetry](README.md#exporting-to-opentelemetry) in the README; otherwise traces and metrics are exported but no log records.

### Rollback

`helm rollback myopal -n mynamespace` restores the 5.7.6 image, which finds its configuration untouched in `data/orientdb`. Any configuration change made after the upgrade is lost, since it was written to the new database. This only works as long as `data/orientdb` has not been deleted (step 3 above).

## 1.3.0

### PersistentVolumeClaim template labels

Chart versions up to 1.2.1 set the `helm.sh/chart` and `app.kubernetes.io/version` labels on the `volumeClaimTemplates` of the StatefulSets (`opal`, `mongo`, `postgres-data`, `postgres-ids`). This section of a StatefulSet is immutable, so any chart or application version bump caused `helm upgrade` to fail with:

```
StatefulSet.apps "opal" is invalid: spec: Forbidden: updates to statefulset spec for fields
other than 'replicas', 'ordinals', 'template', 'updateStrategy',
'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden
```

Version 1.3.0 removes these labels from the PVC templates. The removal is itself a `volumeClaimTemplates` change, so upgrading an existing release to 1.3.0 (or later) requires a one-time manual step: the StatefulSets must be deleted and recreated. Pods and PersistentVolumeClaims are preserved when deleting with `--cascade=orphan`, so **no data is lost and there is no downtime** as long as the steps below are followed.

This is only needed once, when upgrading from a chart version <= 1.2.1. Fresh installs and later upgrades are not affected.

#### Actions

Replace `myopal` with your Helm release name and `-n mynamespace` with your namespace.

1. Check the current chart version of the release:

   ```
   helm list -n mynamespace
   ```

   If the `CHART` column shows `opal-1.2.1` or lower, continue. Otherwise nothing needs to be done.

2. Back up your data (Opal file system, MongoDB, PostgreSQL) before proceeding. The procedure below does not touch the volumes, but a backup is always recommended before a manual operation on the cluster.

3. List the StatefulSets managed by the release:

   ```
   kubectl get statefulset -n mynamespace -l app.kubernetes.io/instance=myopal
   ```

   Depending on your configuration you should see some of: `opal`, `mongo`, `postgres-data`, `postgres-ids`.

4. Delete the StatefulSets **without** deleting their pods and volumes:

   ```
   kubectl delete statefulset -n mynamespace -l app.kubernetes.io/instance=myopal --cascade=orphan
   ```

   The `--cascade=orphan` flag is essential: it removes only the StatefulSet objects, leaving the running pods and their PersistentVolumeClaims in place. Opal keeps serving requests during this step.

5. Verify that the pods and PVCs are still there:

   ```
   kubectl get pods,pvc -n mynamespace -l app.kubernetes.io/instance=myopal
   ```

6. Upgrade the release:

   ```
   helm repo update
   helm upgrade myopal obiba/opal -n mynamespace [-f my-values.yaml]
   ```

   Helm recreates the StatefulSets with the new PVC templates. They adopt the orphaned pods, whose names (`opal-0`, `mongo-0`, ...) match the StatefulSet naming scheme, and the pods re-attach to the existing PVCs (`opal-storage-opal-0`, `mongo-storage-mongo-0`, ...).

7. Check that the StatefulSets are back and healthy:

   ```
   kubectl get statefulset,pods -n mynamespace -l app.kubernetes.io/instance=myopal
   ```

   If the pod template changed between the two chart versions (image, environment, resources...), the StatefulSets will perform a rolling restart of the adopted pods; wait for them to be `Running` and `READY`.

#### Rollback

If something goes wrong after step 6, run `helm rollback myopal -n mynamespace` to restore the previous chart version. Because the previous version also has a different `volumeClaimTemplates`, apply steps 4 to 5 again before rolling back.
