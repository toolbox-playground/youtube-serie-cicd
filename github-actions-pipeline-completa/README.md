# GitHub Actions - Pipeline Completa (Build, Test, Deploy)

Aplicação Hello World simples feita com **Node.js** e publicada no **GitHub Pages** via **GitHub Actions**. Ideal para tutoriais que mostram as etapas do pipeline: instalar → buildar → testar → publicar.

## Stack

- **Node.js** (módulos ES) — script de build e testes
- **GitHub Actions** — pipeline de CI/CD
- **GitHub Pages** — hospedagem de site estático

## Rodar localmente

```bash
npm ci
npm run build
npm test
```

Depois, sirva o site gerado:

```bash
npx serve dist
# ou: python3 -m http.server 8000 --directory dist
```

Abra a URL exibida (ex.: `http://localhost:3000`).

## Pipeline (GitHub Actions)

O workflow fica na **raiz do repositório**: [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml). Ele roda a cada push na branch `main` e executa os comandos dentro desta pasta (`github-actions-pipeline-completa/`):

| Etapa | Ação | O que faz |
|-------|------|-----------|
| 1 | **Checkout** | Clona o repositório |
| 2 | **Setup Node.js** | Instala Node 20.x e faz cache do npm |
| 3 | **Install dependencies** | `npm ci` (instalação reproduzível a partir do lockfile) |
| 4 | **Build** | `npm run build` — gera a pasta `dist/` (HTML + .nojekyll) |
| 5 | **Test** | `npm test` — verifica se `dist/index.html` existe e contém "Hello World" |
| 6 | **Upload artifact** | Envia a pasta `dist/` para o GitHub Pages |
| 7 | **Deploy** | Publica o artefato no GitHub Pages |

### Ativar o GitHub Pages (Actions)

1. Envie este repositório para o GitHub.
2. Vá em **Settings → Pages**.
3. Em **Build and deployment**, defina **Source** como **GitHub Actions**.
4. Faça push na branch `main`; o workflow vai buildar e publicar.
5. O site ficará em `https://<seu-usuario>.github.io/<nome-do-repo>/`.

Na primeira publicação pode ser necessário criar o ambiente **github-pages** (ou ele é criado automaticamente quando o workflow rodar).
