#!/usr/bin/env bash
# Aplica o app na ordem certa e espera ficar Ready.
set -euo pipefail
cd "$(dirname "$0")/.."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
kubectl apply -f load/load.yaml
kubectl -n tbx rollout status deploy/tbx-api --timeout=120s
kubectl -n tbx get deploy,po,svc,hpa,pdb -o wide
echo; echo "curl http://localhost:8080/"
curl -s http://localhost:8080/ || echo "(sem resposta ainda — kind mapeia 30080 -> 8080)"
