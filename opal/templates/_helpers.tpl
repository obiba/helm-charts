{{/*
Expand the name of the chart.
*/}}
{{- define "opal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "obiba.labels" -}}
helm.sh/chart: {{ include "opal.chart" . }}
{{ include "obiba.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "obiba.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "opal.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: opal
{{- end -}}
{{- define "opal.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: opal-pvc
{{- end -}}
{{- define "opal.backup.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: opal-backup
{{- end -}}
{{- define "opal.backup.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: opal-backup-pvc
{{- end -}}

{{- define "mongo.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: mongo
{{- end -}}
{{- define "mongo.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: mongo-pvc
{{- end -}}
{{- define "mongo.dump.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: mongo-dump
{{- end -}}
{{- define "mongo.dump.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: mongo-dump-pvc
{{- end -}}

{{- define "postgres.data.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-data
{{- end -}}
{{- define "postgres.data.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-data-pvc
{{- end -}}
{{- define "postgres.data.dump.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-data-dump
{{- end -}}
{{- define "postgres.data.dump.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-data-dump-pvc
{{- end -}}

{{- define "postgres.ids.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-ids
{{- end -}}
{{- define "postgres.ids.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-ids-pvc
{{- end -}}
{{- define "postgres.ids.dump.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-ids-dump
{{- end -}}
{{- define "postgres.ids.dump.pvc.labels" -}}
{{ include "obiba.labels" . }}
app.kubernetes.io/component: postgres-ids-dump-pvc
{{- end -}}

{{/*
Component specific selector labels
*/}}
{{- define "opal.selectorLabels" -}}
{{ include "obiba.selectorLabels" . }}
app.kubernetes.io/component: opal
{{- end }}
{{- define "mongo.selectorLabels" -}}
{{ include "obiba.selectorLabels" . }}
app.kubernetes.io/component: mongo
{{- end }}
{{- define "postgres.data.selectorLabels" -}}
{{ include "obiba.selectorLabels" . }}
app.kubernetes.io/component: postgres-data
{{- end }}
{{- define "postgres.ids.selectorLabels" -}}
{{ include "obiba.selectorLabels" . }}
app.kubernetes.io/component: postgres-ids
{{- end }}