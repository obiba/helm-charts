{{/*
Expand the name of the chart.
*/}}
{{- define "opal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}
