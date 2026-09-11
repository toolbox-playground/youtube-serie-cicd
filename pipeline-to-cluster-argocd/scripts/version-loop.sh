#!/usr/bin/env bash
# Bate na API a cada 300 ms e imprime a `version` (= tag sha- da imagem).
# Durante o rollout a version MUDA no meio do loop e nenhuma linha sai como ERRO —
# é a prova de maxUnavailable: 0 + readiness (vídeo passado) + Argo (este vídeo).
URL="${URL:-http://localhost:8080/}"
errors=0; last=""
trap 'echo; echo "erros: ${errors}"; exit 0' INT
while true; do
  v=$(curl -s --max-time 1 "${URL}" | jq -r '.version // empty' 2>/dev/null)
  ts=$(date +%H:%M:%S.%3N)
  if [ -z "${v}" ]; then errors=$((errors+1)); printf '%s  \033[31mERRO\033[0m (%d)\n' "$ts" "$errors"
  elif [ "${v}" != "${last}" ]; then printf '%s  \033[32m%s\033[0m  ← mudou\n' "$ts" "$v"; last="$v"
  else printf '%s  %s\n' "$ts" "$v"; fi
  sleep 0.3
done
