# "Pipeline → cluster: deploy no Kubernetes com GitHub Actions + Argo CD"
# Tudo roda num laptop: kind + Argo CD dentro do kind + GitHub Actions grátis + GHCR grátis.
# Reusa o cluster e os manifestos do vídeo "HPA, probes e self-healing" — nada copiado.
SHELL := /bin/bash
.DEFAULT_GOAL := help

# ATENÇÃO (lição de 11/set): NUNCA comentário na mesma linha de uma variável —
# o Make guarda os espaços antes do `#` dentro do valor ("60s   ", "…git   ").
# Pasta do vídeo passado (cluster, manifestos)
PREV_DIR ?= ../k8s-hpa-probes-self-healing
# Fork: make up REPO_URL=https://github.com/SEU-USUARIO/youtube-serie-cicd.git
REPO_URL ?= https://github.com/toolbox-playground/youtube-serie-cicd.git
# Fixado. `stable` muda sem avisar.
ARGOCD_VERSION ?= v3.5.2
# Intervalo de leitura do Git. Padrão do Argo: 180s (veja argocd/install.sh)
ARGOCD_POLL ?= 60s
# 8080 já é a API (NodePort 30080 do vídeo passado)
ARGO_PORT ?= 8081
KIND_CLUSTER ?= $(shell yq -r '.name // "kind"' $(PREV_DIR)/kind/kind-config.yaml 2>/dev/null || echo kind)
# Remove espaços que possam ter vindo da linha de comando ou de edição
REPO_URL := $(strip $(REPO_URL))
ARGOCD_POLL := $(strip $(ARGOCD_POLL))
ARGO_PORT := $(strip $(ARGO_PORT))
ARGOCD_VERSION := $(strip $(ARGOCD_VERSION))
PREV_DIR := $(strip $(PREV_DIR))
ORIGIN_URL := https://github.com/toolbox-playground/youtube-serie-cicd.git

.PHONY: help preflight cluster argocd project app up ui password refresh status watch version-loop diff down

help: ## lista os alvos
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n",$$1,$$2}'

preflight: ## checa ferramentas, repo público, imagem pública, tag no manifesto, proteção da main
	@bash scripts/preflight.sh "$(REPO_URL)" "$(PREV_DIR)"

cluster: ## kind (3 nós) + metrics-server — o MESMO alvo do vídeo passado
	$(MAKE) -C $(PREV_DIR) cluster

argocd: ## instala o Argo CD dentro do kind (fixado em $(ARGOCD_VERSION))
	ARGOCD_VERSION=$(ARGOCD_VERSION) ARGOCD_POLL=$(ARGOCD_POLL) bash argocd/install.sh

project: ## AppProject `tbx` (escopo: só este repo, só o namespace tbx)
	sed "s#$(ORIGIN_URL)#$(REPO_URL)#" argocd/project.yaml | kubectl apply -f -

app: project ## Application `tbx-api` → o Argo passa a aplicar k8s-hpa-probes-self-healing/k8s
	sed "s#$(ORIGIN_URL)#$(REPO_URL)#" argocd/application.yaml | kubectl apply -f -
	@echo "==> o Argo vai criar o namespace tbx e subir a API sozinho. Acompanhe: make watch"

up: cluster argocd app ## tudo de uma vez (≈5 min): cluster → Argo → projeto → app

ui: ## abre a UI em http://localhost:$(ARGO_PORT) (usuário: admin — senha: make password)
	@echo "http://localhost:$(ARGO_PORT)   (admin / make password)   Ctrl-C para parar"
	kubectl -n argocd port-forward svc/argocd-server $(ARGO_PORT):80

password: ## senha inicial do admin
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

refresh: ## pede ao Argo para olhar o Git AGORA (em vez de esperar o próximo poll)
	kubectl -n argocd annotate application tbx-api argocd.argoproj.io/refresh=normal --overwrite

status: ## Application + pods, uma tela
	@kubectl -n argocd get application tbx-api -o custom-columns='APP:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,REVISION:.status.sync.revision' 2>/dev/null || true
	@echo; kubectl -n tbx get deploy,po,hpa -o wide 2>/dev/null || echo "(namespace tbx ainda não existe — o Argo cria no 1º sync)"

watch: ## Application em -w (deixe num terminal durante a gravação)
	kubectl -n argocd get application tbx-api -w -o custom-columns='SYNC:.status.sync.status,HEALTH:.status.health.status,REVISION:.status.sync.revision,IMAGE:.status.summary.images[0]'

version-loop: ## curl a cada 300 ms imprimindo a version — prova o rollout sem erro
	bash scripts/version-loop.sh

diff: ## o que o Git diz vs. o que está no cluster (precisa do CLI argocd logado; opcional)
	argocd app diff tbx-api || echo "sem CLI argocd: use a UI (make ui) → App → App Diff"

down: ## destrói tudo (cluster inteiro — Argo, app, namespace)
	kind delete cluster --name $(KIND_CLUSTER)
