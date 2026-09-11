#!/usr/bin/env bash
# Instala o Argo CD DENTRO do kind, com duas configurações de laboratório:
#   1. servidor sem TLS (para abrir em http://localhost:8081 sem aviso de certificado)
#   2. polling do Git a cada ARGOCD_POLL (padrão do Argo: 180s — em vídeo, 3 min parado parece bug)
# Em cloud/produção: TLS atrás do Ingress/Gateway, polling padrão + webhook do GitHub.
set -euo pipefail

ARGOCD_VERSION="${ARGOCD_VERSION:-v3.5.2}"   # fixado, como tudo nesta série. `stable` muda sem avisar.
ARGOCD_POLL="${ARGOCD_POLL:-60s}"
MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "==> Argo CD ${ARGOCD_VERSION} (poll ${ARGOCD_POLL})"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
# server-side apply: o client-side grava o objeto inteiro na annotation last-applied-configuration,
# e o CRD applicationsets.argoproj.io estoura o limite de 262144 bytes de uma annotation.
kubectl apply -n argocd --server-side --force-conflicts -f "${MANIFEST}"

echo "==> esperando CRDs"
kubectl wait --for=condition=Established crd/applications.argoproj.io crd/appprojects.argoproj.io --timeout=120s

echo "==> configuração de laboratório (http + poll curto)"
kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl -n argocd patch configmap argocd-cm --type merge \
  -p "{\"data\":{\"timeout.reconciliation\":\"${ARGOCD_POLL}\"}}"

# Os dois componentes leem o ConfigMap só na subida — reinicia para valer.
kubectl -n argocd rollout restart deployment/argocd-server
kubectl -n argocd rollout restart statefulset/argocd-application-controller

echo "==> esperando o Argo ficar pronto (1–3 min no kind)"
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s
kubectl -n argocd rollout status deployment/argocd-repo-server --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s

echo "==> pronto. UI: make ui  |  senha: make password"
