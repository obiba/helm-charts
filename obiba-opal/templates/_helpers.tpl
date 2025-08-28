{{/*
Expand the name of the chart.
*/}}
{{- define "opal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "opal.labels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end -}}