#!/usr/bin/env bash
# Três níveis de self-healing, na ordem do vídeo.
#   container: mata o processo dentro do container -> kubelet reinicia (RESTARTS +1, mesmo pod)
#   pod:       apaga o pod -> ReplicaSet cria outro (nome novo)
#   node:      drena um worker -> pods remarcados no outro nó, respeitando o PDB
set -euo pipefail
POD="$(kubectl -n tbx get pod -l app=tbx-api -o jsonpath='{.items[0].metadata.name}')"
case "${1:-}" in
  container) kubectl -n tbx exec "$POD" -- sh -c 'kill 1' ;;
  pod)       kubectl -n tbx delete pod "$POD" ;;
  node)
    NODE="$(kubectl -n tbx get pod "$POD" -o jsonpath='{.spec.nodeName}')"
    kubectl drain "$NODE" --ignore-daemonsets --delete-emptydir-data ;;
  uncordon)  kubectl uncordon $(kubectl get nodes -o name | grep worker | cut -d/ -f2) ;;
  *) echo "uso: $0 container|pod|node|uncordon"; exit 1 ;;
esac
