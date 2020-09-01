{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "catalogueContainerPort" }}8080{{ end -}}
{{- define "paymentContainerPort" }}8080{{ end -}}
{{- define "userContainerPort" }}8080{{ end -}}
{{- define "ordersContainerPort" }}8080{{ end -}}
{{- define "shippingContainerPort" }}8080{{ end -}}
{{- define "cartsContainerPort" }}8080{{ end -}}
