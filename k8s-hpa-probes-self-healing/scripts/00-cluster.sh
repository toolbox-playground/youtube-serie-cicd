#!/usr/bin/env bash
# Sobe o cluster kind e instala o metrics-server (pré-requisito do HPA).
# Roda UMA vez, antes de gravar. Tempo: ~2 min.
set -euo pipefail
cd "$(dirname "$0")/.."

kind create cluster --config kind/kind-config.yaml
kubectl cluster-info --context kind-tbx

# metrics-server: quem alimenta `kubectl top` e o HPA (API metrics.k8s.io —
# estável no Kubernetes 1.37, depois de 9 anos em beta).
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# kind não assina o certificado do kubelet com a CA do cluster, então o
# metrics-server recusa a conexão. Em laboratório: --kubelet-insecure-tls.
# Em cloud gerenciada isso NÃO é necessário (nem recomendado).
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

kubectl -n kube-system rollout status deploy/metrics-server --timeout=120s
echo "aguardando a primeira coleta (~30 s)..."
sleep 30
kubectl top nodes
