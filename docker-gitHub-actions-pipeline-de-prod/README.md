# tbx-api — Docker + GitHub Actions: pipeline de produção

Repositório do vídeo **"Docker + GitHub Actions: pipeline de produção"** do canal TBX Tech.
Uma API FastAPI mínima, um Dockerfile multi-stage limpo e uma pipeline em três estágios:
**teste → build + push + scan → deploy com aprovação**.

```
PR aberto ──► test
push main ──► test ──► build (GHCR, tag sha-xxxxxxx, Trivy) ──► deploy (environment "production", aprovação) ──► VM via SSH + Docker Compose
```

## Estrutura

| Caminho | O que é |
|---|---|
| `app/main.py` | API com `/` (mostra a versão em produção) e `/health` |
| `tests/` | 2 testes — o gate nº 1 |
| `Dockerfile` | multi-stage, usuário non-root, `HEALTHCHECK`, deps em cache |
| `.dockerignore` | o que NUNCA entra no contexto de build |
| `.github/workflows/docker-gitHub-actions-pipeline-de-prod.yml` | a pipeline (actions fixadas por commit SHA) |
| `deploy/` | `docker-compose.yml`, `.env.example` e `setup-servidor.sh` (roda uma vez na VM) |

## Rodar local

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
pytest -q
uvicorn app.main:app --reload
```

## Build da imagem

```bash
docker build --build-arg APP_VERSION=local -t tbx-api .
docker run --rm -p 8000:8000 tbx-api
curl localhost:8000/        # {"service":"tbx-api","version":"local"}
```

## Preparar a VM (uma vez)

```bash
scp deploy/* usuario@SEU_IP:/tmp/ && ssh usuario@SEU_IP 'cd /tmp && sudo bash setup-servidor.sh'
```

Depois, no GitHub → **Settings → Environments → production**:

1. **Required reviewers**: você. (Em repositório privado, exige plano Pro/Team; em público, é grátis.)
2. **Environment secrets**: `SSH_HOST` (IP/DNS da VM), `SSH_USER` (`deploy`), `SSH_KEY` (conteúdo da chave privada ed25519 gerada para a pipeline).

Se o pacote no GHCR ficar **privado**, a VM precisa de `docker login ghcr.io` com um token `read:packages` antes do primeiro deploy.

## Por que assim (o que "limpa" significa aqui)

- **Tag imutável por commit** (`sha-abc1234`) — nunca `:latest` em produção. Rollback = trocar uma linha no `.env` e `docker compose up -d`.
- **`GITHUB_TOKEN` com `permissions` mínimas** — nenhum PAT, nenhum secret de registry criado à mão.
- **Actions fixadas por commit SHA** — o `trivy-action` teve 76 de 77 tags comprometidas em março/2026 (CVE-2026-33634). Tag mutável não é versão.
- **Scan antes do deploy** — CRITICAL/HIGH com correção disponível barra a pipeline.
- **Environment com aprovação** — "deploy automático" não significa "deploy sem ninguém olhar".
- **Cache de build no GitHub** (`type=gha`) — segundo build cai de minutos para segundos.

📺 Vídeo: [link] · Canal: [@ToolboxTechnology](https://www.youtube.com/@ToolboxTechnology)
