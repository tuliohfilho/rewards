{{/* SERVICE */}}

{{/* Metadata Labels */}}
{{- define "service.metadata.labels" -}}
app: {{ .Values.application.name }}
tier: backend
{{- end -}}

{{/* Selector */}}
{{- define "service.spec.selector" -}}
app: {{ .Values.application.name }}
tier: backend
track: stable
{{- end -}}

{{/* DEPLOYMENT */}}

{{- define "datadog.env" -}}
{{ .Values.container.datadog.env }}
{{- end -}}

{{- define "datadog.service" -}}
{{ .Values.application.name }}
{{- end -}}

{{- define "datadog.version" -}}
{{ .Values.container.image.tag }}
{{- end -}}

{{- define "deployment.metadata.labels" -}}
app: {{ .Values.application.name }}
tier: backend
track: stable
tags.datadoghq.com/env: {{ include "datadog.env" . }}
tags.datadoghq.com/service: {{ include "datadog.service" . }}
tags.datadoghq.com/version: {{ include "datadog.version" . }}
{{- end -}}

{{- define "deployment.spec.selector" -}}
matchLabels:
  app: {{ .Values.application.name }}
  tier: backend
  track: stable
{{- end -}}

{{- define "deployment.spec.strategy" -}}
type: RollingUpdate
rollingUpdate:
  maxUnavailable: 25%
  maxSurge: 25%
{{- end -}}

{{- define "deployment.spec.template.metadata.annotations" -}}
ad.datadoghq.com/alpine.logs: '[{"source": "csharp"}]'
ad.datadoghq.com/tags: '{"source":"csharp"}'
{{- end -}}

{{- define "deployment.spec.template.spec.tolerations" -}}
effect: NoSchedule
key: kubernetes.azure.com/scalesetpriority
operator: Equal
value: spot
{{- end -}}

{{- define "deployment.spec.template.spec.containers.readinessProbe" -}}
failureThreshold: 3
httpGet:
    path: /ready
    port: 80
    scheme: HTTP
initialDelaySeconds: 60
periodSeconds: 60
successThreshold: 1
timeoutSeconds: 10
{{- end -}}

{{- define "deployment.spec.template.spec.containers.livenessProbe" -}}
failureThreshold: 3
httpGet:
    path: /health
    port: 80
    scheme: HTTP
initialDelaySeconds: 60
periodSeconds: 60
successThreshold: 1
timeoutSeconds: 10
{{- end -}}

{{- define "deployment.spec.template.spec.containers.resources" -}}
limits:
    cpu: "{{ .Values.container.limit.cpu }}"
    memory: "{{ .Values.container.limit.memory }}"
requests:
    cpu: "{{ .Values.container.require.cpu }}"
    memory: "{{ .Values.container.require.memory }}"
{{- end -}}