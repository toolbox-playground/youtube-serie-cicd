# Pipeline → cluster: deploy no Kubernetes com GitHub Actions + Argo CD (GitOps)

Terceira peça da trilha, mesma API, mesmo repo:

| Vídeo | O que entrega | Pasta |
|---|---|---|
| Docker + GitHub Actions: pipeline de produção | imagem escaneada no GHCR + deploy em VM | `docker-github-actions-pipeline/` |
| Kubernetes na prática: HPA, probes e self-healing | a mesma imagem num cluster que se cura, cresce e troca sem cair | `k8s-hpa-probes-self-healing/` |
| **Pipeline → cluster (este)** | **a pipeline entrega no cluster — sem nunca falar com ele** | `pipeline-to-cluster-argocd/` |

```
push na main
  └─ test → build (scan → push GHCR)          ← já existia
       └─ bump-manifest: troca 1 linha         ← NOVO: 1 job, 0 kubectl
            └─ commit "deploy(k8s): …:sha-abc1234"
                 └─ Argo CD (dentro do kind) vê o commit
                      └─ sync → rollout → readiness segura o tráfego
```

A pipeline **não tem kubeconfig**. O "deploy" é um commit. Quem aplica é o Argo CD,
puxando de dentro do cluster — por isso funciona num kind no seu laptop, sem expor
nada, sem runner self-hosted, sem cloud.

## Reproduza em casa (5 passos, ~15 min)

Pré-requisitos: Docker, `kind`, `kubectl`, `yq`, `jq`, `gh` (logado), conta GitHub grátis.

1. **Fork** de `toolbox-playground/youtube-serie-cicd` → habilite Actions na aba *Actions* do fork.
2. **Pipeline:** cole o job de `pipeline/bump-manifest.job.yml` no workflow de 28/ago e
   faça as 3 checagens de `pipeline/README.md` (SHA do checkout, `paths`, proteção da main).
   Faça um push na `main` e espere o run ficar verde: o GHCR agora tem uma tag `sha-…`.
   **Torne o pacote público** (*Packages → Package settings → Change visibility*).
3. **Cluster + Argo:** `cd pipeline-to-cluster-argocd && make preflight && make up`
   (fork: `make up REPO_URL=https://github.com/SEU-USUARIO/youtube-serie-cicd.git`).
4. **Veja acontecer:** `make ui` → http://localhost:8081 (admin / `make password`).
   Em outro terminal `make watch`; em outro `make version-loop`.
5. **O deploy:** mude qualquer coisa na API, `git push`. Acompanhe: Actions verde →
   commit do bot no `git log` → Argo *OutOfSync* → *Synced/Healthy* → a `version` muda
   no loop, sem uma linha de erro. **Rollback = `git revert <commit do bot>` + push.**

`make down` destrói tudo. `make up` de novo recria em ~5 min.

## Os 5 erros da primeira rodada

1. **Argo fica `OutOfSync` para sempre e o HPA "não sobe".** O HPA muda `spec.replicas`; o Git diz `2`.
   Sem `ignoreDifferences` + `RespectIgnoreDifferences=true`, o `selfHeal` volta para 2 e o HPA sobe de novo.
   Já está na `application.yaml` — leia o comentário.
2. **`resource Namespace is not permitted in project tbx`.** O `namespace.yaml` é recurso de cluster;
   o `AppProject` precisa liberar `Namespace` em `clusterResourceWhitelist`. Está no `project.yaml`.
3. **`ImagePullBackOff`.** O pacote no GHCR do fork nasce privado. Ou o manifesto ainda tem `sha-xxxxxxx`
   e a pipeline ainda não rodou (o 1º run troca).
4. **Commitou e "nada aconteceu".** O Argo olha o Git a cada 60 s aqui (180 s por padrão). `make refresh`
   ou botão *Refresh* na UI. Webhook do GitHub não chega num kind local — em cloud, chega.
5. **`push` do bot recusado: `protected branch hook declined`.** `main` protegida — `pipeline/README.md` item 3.

## O que ficou de fora, de propósito

- **Kustomize / overlays por ambiente** (dev/prod com `images:`): é o passo seguinte natural; aqui a
  pipeline edita o `deployment.yaml` direto para o diff ser **uma linha** — a mesma linha que no vídeo
  passado você trocou na mão.
- **Argo CD Image Updater** (o Argo detecta a tag nova sozinho, sem job na pipeline): tira o commit do
  desenho, e o commit é a auditoria.
- **Webhook do GitHub → Argo** (sync em segundos): precisa de endpoint público.
- **Segredos** (Sealed Secrets / External Secrets): o `AppProject` bloqueia `Secret` de propósito.
- **Argo gerenciando um cluster remoto** (`argocd cluster add`): o kind expõe a API só em `127.0.0.1`.
- **App-of-apps / ApplicationSet**, Rollouts (canary/blue-green), notificações.

## Arquivos

```
argocd/project.yaml        AppProject tbx — o escopo (repo, namespace, Namespace liberado, Secret bloqueado)
argocd/application.yaml    Application tbx-api — auto-sync + ignoreDifferences em /spec/replicas
argocd/install.sh          Argo CD v3.5.2 fixado, http, poll 60 s
pipeline/bump-manifest.job.yml   o job novo (cola no workflow de 28/ago)
pipeline/README.md         3 checagens antes de colar + o que muda no fork
scripts/preflight.sh       tudo o que quebra na 1ª rodada, checado antes
scripts/version-loop.sh    prova do rollout sem erro
Makefile                   preflight · up · ui · watch · refresh · version-loop · down
```
