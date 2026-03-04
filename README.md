# CI/CD na Prática — Série YouTube

Repositório central com **código e exemplos** dos vídeos da série **CI/CD na Prática**, feita para o canal **Toolbox**. Use este repositório para acompanhar os episódios, copiar snippets e experimentar em cima dos YAMLs e scripts mostrados nos vídeos.

---

## 📺 Vídeos da série

Cada vídeo tem uma pasta com o mesmo nome, contendo os arquivos exibidos (exemplos ERRADO vs CERTO, trechos de pipeline, etc.).

| # | Título | Vídeo | Pasta | Descrição |
|---|--------|--------|--------|-----------|
| 1 | **CI/CD explicado para uma criança (e para um adulto também)** | [assistir](https://www.youtube.com/watch?v=UnI4pa05kBI) | — | Conceitos de CI/CD |
| 2 | **Pipeline não é YAML: e se você acha que é, esse vídeo é pra você!** | [assistir](https://www.youtube.com/watch?v=LNVnI10DCWY) | — | O que é pipeline de verdade |
| 3 | **CI/CD com GitHub Actions: pipeline completa em 30 minutos** | [assistir](https://www.youtube.com/watch?v=vh4XtEmOp8k) | [`github-actions-pipeline-completa/`](./github-actions-pipeline-completa/) | App Node.js + workflow completo (build, test, deploy no GitHub Pages) |
| 4 | **GitHub Actions: Os 5 Erros Mais Comuns em Pipelines de CI/CD** | [assistir](https://www.youtube.com/watch?v=3bFGpe0ljIQ) | [`5-principais-erros-do-cicd/`](./5-principais-erros-do-cicd/) | Exemplos ERRADO vs CERTO: paralelismo, secrets, cache, testes de integração e proteção de ambientes |
| 5 | **GitHub Actions Secrets: como proteger suas credenciais do jeito certo** | [assistir](#) | [`github-actions-secrets-azure/`](./github-actions-secrets-azure/) | 4 níveis de proteção de credenciais: Repository Secrets, Environment Secrets, Organization Secrets e OIDC |

---

## 📁 Estrutura do repositório

```
youtube-serie-cicd/
├── README.md
├── .github/
│   └── workflows/
│       └── deploy.yml              # Pipeline do episódio 3 (build + deploy GitHub Pages)
├── github-actions-pipeline-completa/   # Episódio 3: pipeline completa em 30 min
│   ├── README.md
│   ├── package.json
│   ├── src/
│   │   └── build.js
│   ├── test/
│   │   └── build.test.js
│   └── dist/                        # gerado pelo build (publicado no Pages)
├── 5-principais-erros-do-cicd/      # Episódio 4: 5 erros comuns em CI/CD
│   ├── 1-pipeline-sem-paralelismo-ERRADO.yaml
│   ├── 1-pipeline-sem-paralelismo-CERTO.yaml
│   ├── 2-secret-direto-no-yaml-ERRADO.yaml
│   ├── 2-secret-direto-no-yaml-CERTO.yaml
│   ├── 3-nao-usar-cache-ERRADO.yaml
│   ├── 3-nao-usar-cache-CERTO.yaml
│   ├── 4-nao-testar-integracao-ERRADO.yaml
│   ├── 4-nao-testar-integracao-CERTO.yaml
│   ├── 5-fazer-deploy-qualquer-branch-ERRADO.yaml
│   └── 5-fazer-deploy-qualquer-branch-CERTO.yaml
└── github-actions-secrets-azure/    # Episódio 5: protegendo credenciais
    ├── README.md                    # Guia completo dos 4 níveis de segurança
    ├── checklist-aula.md           # Checklist prático para apresentação
    ├── setup-oidc-azure.md         # Tutorial passo-a-passo OIDC com Azure
    ├── nivel1-repository-secrets.yml
    ├── nivel2-environment-secrets.yml
    ├── nivel3-organization-secrets.yml
    └── nivel4-oidc-azure.yml
```

- **Uma pasta por vídeo** (quando há código) — nome da pasta = tema do episódio
- **Episódios 1 e 2** — só conceito; sem pasta de código
- **Episódio 3** — app completa + workflow em `.github/workflows/deploy.yml` (roda na pasta `github-actions-pipeline-completa/`)
- **Episódio 4** — trechos YAML “errado” vs “certo”; para usar em projeto real, adapte (ex.: adicionar `name:` e `on:` no workflow)
- **Episódio 5** — guia completo de segurança + workflows práticos para cada nível de proteção de secrets; inclui tutorial completo de OIDC com Azure
---

## 🛠 Como usar

1. **Assistir o vídeo** — a ordem recomendada é seguir a série (conceitos → GitHub Actions → pipelines → erros comuns → proteção de credenciais).
2. **Abrir a pasta do episódio** — todos os arquivos mostrados na tela estão aqui.
3. **Copiar e adaptar** — use os exemplos “CERTO” como base e ajuste ao seu projeto (repositório, branch, ambiente, etc.).

Se você usa **GitHub Actions**, os exemplos estão em sintaxe válida; em muitos casos basta colar dentro de um workflow em `.github/workflows/` e completar o que faltar (por exemplo `on:` e `name:`).

---

## 📚 Sobre a série

- **Série:** CI/CD na Prática  
- **Canal:** [Toolbox](https://www.youtube.com/@ToolboxTechnology) *(link do canal)*  
- **Nível:** conceitos + intermediário  
- **Foco:** GitHub Actions, pipelines, boas práticas e armadilhas comuns.

Vídeos anteriores da série (conceito de CI/CD, GitHub Actions na prática, o que é pipeline) estão disponíveis no canal — links na descrição de cada vídeo.

---

## 📄 Licença

Este repositório está sob a [LICENSE](./LICENSE) do projeto (MIT).
