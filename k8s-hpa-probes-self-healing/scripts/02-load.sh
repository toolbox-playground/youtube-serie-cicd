#!/usr/bin/env bash
# Liga/desliga a carga: ./scripts/02-load.sh on | off
set -euo pipefail
case "${1:-on}" in
  on)  kubectl -n tbx scale deploy/load --replicas=3 ;;
  off) kubectl -n tbx scale deploy/load --replicas=0 ;;
  *) echo "uso: $0 on|off"; exit 1 ;;
esac
echo "acompanhe em outro terminal:  kubectl -n tbx get hpa -w   e   kubectl -n tbx top pods"
