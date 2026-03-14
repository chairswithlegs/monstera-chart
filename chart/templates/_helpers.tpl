{{/*
Chart name
*/}}
{{- define "monstera.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Full name (release + chart)
*/}}
{{- define "monstera.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Server full name
*/}}
{{- define "monstera.server.fullname" -}}
{{- printf "%s-server" (include "monstera.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
UI full name
*/}}
{{- define "monstera.ui.fullname" -}}
{{- printf "%s-ui" (include "monstera.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "monstera.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "monstera.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Server image
*/}}
{{- define "monstera.server.image" -}}
{{- printf "%s:%s" .Values.server.image.repository .Values.server.image.tag }}
{{- end }}

{{/*
UI image
*/}}
{{- define "monstera.ui.image" -}}
{{- printf "%s:%s" .Values.ui.image.repository .Values.ui.image.tag }}
{{- end }}

{{/*
Server URL (public API base URL, always uses instanceDomain)
*/}}
{{- define "monstera.server.url" -}}
{{- printf "https://%s" .Values.instanceDomain }}
{{- end }}

{{/*
UI URL (falls back to instanceDomain if uiDomain is not set)
*/}}
{{- define "monstera.ui.url" -}}
{{- $domain := .Values.uiDomain | default .Values.instanceDomain }}
{{- printf "https://%s" $domain }}
{{- end }}

{{/*
Media PVC name (for local storage)
*/}}
{{- define "monstera.server.mediaPvcName" -}}
{{- printf "%s-media" (include "monstera.server.fullname" .) }}
{{- end }}

{{/*
DB Host (uses bundled postgresql service name when enabled, otherwise falls back to database.host)
*/}}
{{- define "monstera.db.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-postgresql" .Release.Name }}
{{- else -}}
{{- .Values.database.host }}
{{- end }}
{{- end }}

{{/*
NATS URL for bundled NATS (no authentication; cluster-internal only)
*/}}
{{- define "monstera.nats.url" -}}
{{- printf "nats://%s-nats:4222" .Release.Name }}
{{- end }}
