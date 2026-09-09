#!/usr/bin/env bash
# Hook PreToolUse (matcher: Bash) — segunda trava, independente da lista deny.
# Recebe o JSON da chamada de ferramenta no stdin; sai com 2 para BLOQUEAR
# (a mensagem no stderr volta pro agente como motivo).
#
# Por que existe além do deny: o deny casa por prefixo de comando. Um
# `bash -c "ssh ..."`, um `eval`, ou um `gh api` no meio de um pipe passam
# pelo prefixo. O hook olha o comando inteiro.

set -euo pipefail

entrada="$(cat)"
comando="$(printf '%s' "$entrada" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

bloquear() {
  echo "BLOQUEADO pela guarda da pipeline: $1. Isso é decisão humana — pare e me avise." >&2
  exit 2
}

# 1) Aprovação/inspeção de deployment — o botão é humano.
if grep -Eqi 'pending_deployments|/deployments|review-deploy' <<<"$comando"; then
  bloquear "aprovação de deployment via API"
fi

# 2) Qualquer caminho até a VM ou o registry.
if grep -Eqi "(^|[[:space:];&|(\"'])(ssh|scp|sftp|rsync)([[:space:]]|$)" <<<"$comando"; then
  bloquear "acesso à VM ($comando)"
fi
if grep -Eqi 'docker[[:space:]]+(compose|push|login)|docker-compose' <<<"$comando"; then
  bloquear "deploy/push manual fora da pipeline"
fi

# 3) Secrets, environments, configuração do repo.
if grep -Eqi 'gh[[:space:]]+(api|secret|environment|workflow|auth)' <<<"$comando"; then
  bloquear "configuração do repositório / API do GitHub"
fi

# 4) Histórico e força.
if grep -Eqi 'push[[:space:]]+(-f|--force)|reset[[:space:]]+--hard|filter-branch|rebase' <<<"$comando"; then
  bloquear "reescrita de histórico"
fi

# 5) Push direto na main.
if grep -Eqi 'git[[:space:]]+push.*[[:space:]](origin[[:space:]]+)?(main|master)([[:space:]]|:|$)' <<<"$comando"; then
  bloquear "push direto na main"
fi

# 6) Leitura de segredo por caminho (cat/less/sed/python em .env, chaves, deploy/).
if grep -Eqi '(\.env([[:space:]]|$)|_key|\.pem|(^|[[:space:]/])deploy/)' <<<"$comando"; then
  bloquear "leitura/escrita de segredo ou de deploy/"
fi

exit 0
