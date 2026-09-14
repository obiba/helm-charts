# Opal Helm Chart Upgrade Notes

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
