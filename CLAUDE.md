# youtube-serie-cicd — repositório dos vídeos da série CI/CD (canal Toolbox)

Este repositório é um **monorepo de episódios**: uma pasta por vídeo, vários workflows em `.github/workflows/`. Cada pasta e cada workflow pertence a um episódio diferente. **Você só trabalha em um deles** (abaixo). Tudo o mais é material de outras aulas — não altere, não "melhore", não apague.

## Escopo desta sessão: a pipeline de produção do episódio Docker + GitHub Actions

- Código do app: `docker-gitHub-actions-pipeline-de-prod/` (FastAPI, `Dockerfile` multi-stage, `tests/`, `pyproject.toml` com `pythonpath = ["."]`).
- Workflow: `.github/workflows/docker-gitHub-actions-pipeline-de-prod.yml` (`name: pipeline`). É o **único** workflow que você pode alterar.
- Ela existe e funciona: `test` (todo PR) → `build` (imagem, GHCR, scan Trivy — só em push na `main`) → `deploy` (VM via SSH, **só com aprovação humana** no environment `production`).
- Nome da imagem: `ghcr.io/${{ github.repository }}` (é o nome do monorepo, de propósito — o `docker-compose.yml` da VM aponta para ele). **Não renomeie.**
- Leia o workflow, o `Dockerfile`, o `.dockerignore` da pasta e o `README.md` da pasta antes de propor qualquer mudança.

Outros workflows do repo (`deploy-pages`, `2026-08-05_aws`, `github-actions-secrets-azure-*`, `github-actions-pipeline-completa`) podem aparecer em `gh run list` — **ignore-os**. Só o run com `name: pipeline` importa para você.

## Fluxo obrigatório

1. **Plano antes de código.** Apresente o plano (arquivos que vai tocar, comandos que vai rodar, o que espera ver na pipeline, **como vai validar**) e **espere meu OK** antes de editar qualquer arquivo.
2. Trabalhe **sempre em branch**, nunca direto na `main`.
3. Antes de qualquer `git push`: `actionlint` limpo no workflow, `pytest` verde **e** `docker build` local verde (comandos abaixo). Se um deles falhar, diagnostique e corrija antes de subir — não "testa no CI".
4. Abra o PR com `gh pr create`; acompanhe **o run do workflow `pipeline`** com `gh run watch` / `gh run view --log-failed`. Run vermelho é seu para diagnosticar: leia o log que falhou antes de mudar qualquer coisa. Não repita o mesmo push sem mudança.
5. PR verde → pode fazer `gh pr merge --squash`. Depois acompanhe o run da `main` até o job `deploy` ficar em **Waiting**.
6. **Pare aí.** Me diga que o deploy está esperando aprovação e o que você mudou. Quem aprova sou eu.

## O que você NÃO faz (não peça exceção)

- Não aprova, rejeita nem inspeciona deployments (`gh api .../pending_deployments`, `gh api .../deployments`). O botão é humano.
- Não acessa a VM: nada de `ssh`, `scp`, `docker compose`, `docker push`, `docker login`.
- Não lê nem edita `.env`, chaves (`*_key*`, `*.pem`, `pipeline_key*`) ou nada em `docker-gitHub-actions-pipeline-de-prod/deploy/`.
- Não mexe em secrets, environments ou configuração do repositório (`gh secret`, `gh environment`, Settings).
- Não toca em outras pastas nem em outros workflows (ver escopo acima).
- Não faz `git push --force`, não reescreve histórico, não apaga branch que não criou.
- **Mudança em `.github/workflows/` é exceção:** se precisar alterar a pipeline, me mostre o diff e espere meu OK **antes** do push. A pipeline é o que te executa — ela não muda sem um humano ler.

## Convenções da pipeline (não negociáveis)

- Imagem: multi-stage, `USER app` (non-root), `HEALTHCHECK` em `/health`, `CMD` em exec form. Não instale pacote na imagem de runtime.
- Tag da imagem: `sha-<commit>` (via `docker/metadata-action`, `type=sha`). `latest` não existe aqui.
- `permissions:` do workflow começa em `contents: read`; permissão extra só no job que precisa.
- Toda action fica fixada por **SHA de commit** com a versão em comentário (`# vX.Y.Z`). Sem tag, sem branch.
- `concurrency` da `main` nunca cancela run em andamento.
- Testes em `tests/`, `pytest`. Mensagens de commit em português, imperativo, uma linha de assunto.

## Como verificar (rode a partir da raiz do repo)

```bash
actionlint .github/workflows/docker-gitHub-actions-pipeline-de-prod.yml
cd docker-gitHub-actions-pipeline-de-prod && pip install -r requirements-dev.txt -q && pytest -q && cd ..
docker build --build-arg APP_VERSION=local -t tbx-api:local docker-gitHub-actions-pipeline-de-prod
docker run --rm -d -p 8000:8000 --name tbx-local tbx-api:local && sleep 2 && curl -s localhost:8000/health && docker stop tbx-local
hadolint docker-gitHub-actions-pipeline-de-prod/Dockerfile
```
