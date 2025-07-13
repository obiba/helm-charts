# Opal Helm Chart

## R server

Opal deployment, with Rock spawner capability (on-demand R server management).

## Databases

Default database is an internally managed MongoDB instance. It is also possible to configure an externally managed one.

Other databases (Postgresql for instance) can also be internally/externally managed.

## Deployment

```
helm repo add obiba https://www.obiba.org/helm-charts
helm install myopal obiba-opal
```