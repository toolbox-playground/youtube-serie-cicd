# A parede de verdade: Workflow execution protections

`cache-mode: read` mora no YAML do workflow — e **o autor do PR pode editar o
YAML no próprio PR**. Por isso ele é um cinto de segurança, não a parede.

A parede é uma **política de repositório/organização**, que o PR não alcança:
as **Workflow execution protections** do GitHub Actions (GA em 17/set/2026).

## O que elas fazem

- **Regras de ator (allowlist):** definem *quem* pode disparar um workflow.
- **Regras de evento:** definem *quais eventos* podem disparar — inclusive
  **desabilitar `pull_request_target`**.
- **Escopo por arquivo de workflow:** regras diferentes por workflow no mesmo repo.
- **Modo "evaluate" (shadow):** testa a regra e mostra o que *seria* bloqueado
  antes de valer.
- **Regra padrão de segurança:** em repositórios **públicos**, a política padrão
  para `pull_request_target` está em modo **evaluate** em setembro de 2026.
  Ela só bloqueará execuções quando for aplicada (*enforce*). O GitHub anunciou
  aplicação automática em 2/nov/2026 para repositórios abrangidos pela regra.

## Como ligar (repositório)

1. **Settings → Actions → Execution protections** (ou nível de organização/enterprise).
2. Crie uma regra de **evento** que bloqueia `pull_request_target` para este repo
   e coloque em **Enforce**. Para a gravação da fase vulnerável, mantenha a
   regra apenas em **Evaluate**; só aplique o bloqueio na fase corrigida.
3. Antes de aplicar o bloqueio, você pode usar **Evaluate** e conferir em
   *Insights* o que seria bloqueado.
4. Gerencie por API (policy-as-code) se for padronizar na organização.

## A ordem mental para o vídeo

1. **Política** (execution protections) — desliga o gatilho perigoso. Não é editável no PR.
2. **Escopo por branch/merge ref** — o GitHub já isola o cache de um `pull_request`.
3. **Separação de chaves por confiança** (`trusted-` × `pr-`) — vale no seu YAML de push.
4. **`cache-mode: read`** — cinto para eventos de baixa confiança.
5. **`permissions:` mínimas + actions fixadas por SHA** — higiene de sempre.

Fonte: GitHub Changelog, "Workflow execution protections in GitHub Actions
generally available" (17/set/2026).
