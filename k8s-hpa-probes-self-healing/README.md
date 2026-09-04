# Laboratório — Kubernetes na prática: HPA, probes e self-healing (TBX Tech)

Repositório do vídeo **"Kubernetes na prática: HPA, probes e self-healing"** — canal [@ToolboxTechnology](https://www.youtube.com/@ToolboxTechnology). Continuação direta de **"Docker + GitHub Actions: pipeline de produção"** (a imagem é a mesma que a pipeline publicou no GHCR) e de **"Kubernetes do zero em 2026"** (o cluster é o mesmo desenho: 1 control-plane + 2 workers no kind).

Objetivo: pegar a API que já está em produção numa VM e colocar ela num cluster que **se cura sozinho** (probes + Deployment + PDB), **cresce sozinho** (HPA com metrics-server) e **faz rollout sem derrubar nada** — e provar cada coisa quebrando de propósito.

## Pré-requisitos

- Docker, `kubectl` e `kind` (os mesmos do "Kubernetes do zero")
- A imagem `ghcr.io/toolbox-playground/youtube-serie-cicd:sha-…` publicada pela pipeline do vídeo anterior (aba **Packages** do repositório). Se o pacote estiver **privado**, o kind não consegue puxar: torne-o público ou crie um `imagePullSecret` no namespace `tbx`.
- ~8 GB de RAM livre

## Ordem do vídeo

```bash
make cluster          # kind + metrics-server (+ patch --kubelet-insecure-tls, só laboratório)
make deploy           # namespace (PSA restricted) + Deployment + Service + PDB + HPA + gerador de carga (0 réplicas)
curl localhost:8080/  # {"service":"tbx-api","version":"sha-…"} — a mesma imagem da pipeline

# Self-healing em 3 níveis (em outro terminal: make watch)
make chaos-container  # kill 1 dentro do container -> kubelet reinicia (RESTARTS 1, mesmo pod)
make chaos-pod        # apaga o pod -> ReplicaSet cria outro
make chaos-node       # drena um worker -> pods remarcados no outro nó, PDB segura 1 Ready
make uncordon

# HPA
make load             # 3 pods de busybox em loop contra o Service
kubectl -n tbx get hpa -w   # TARGETS sobe de ~2% para 300%+, REPLICAS 2 -> 4 -> 6
make unload           # após 60 s (stabilizationWindow deste lab; padrão do k8s = 300 s) desce de 1 em 1

# Rollout sem downtime + rollback
kubectl -n tbx set image deploy/tbx-api api=ghcr.io/toolbox-playground/youtube-serie-cicd:sha-OUTRA
kubectl -n tbx rollout status deploy/tbx-api   # maxSurge 1 / maxUnavailable 0: nunca menos de 2 Ready
make rollback

make destroy
```

## As 7 decisões deste manifesto (todas comentadas no YAML)

1. `replicas` é o **mínimo** desejado — o HPA manda a partir daqui.
2. `RollingUpdate` com `maxSurge: 1` e `maxUnavailable: 0` — só derruba o velho depois que o novo passou no readiness.
3. `topologySpreadConstraints` — réplicas em nós diferentes, senão "2 réplicas" é 1 ponto de falha.
4. `resources.requests` — base do scheduler **e** do HPA. **Sem limite de CPU** (throttling) e **com limite de memória** (OOM é local; nó sem memória é global).
5. Três probes, três perguntas: `startupProbe` (terminou de subir?), `readinessProbe` (recebe tráfego agora?), `livenessProbe` (travou de vez?). Liveness **nunca** checa dependência (banco, fila) — é o erro que derruba tudo junto.
6. `PodDisruptionBudget` `minAvailable: 1` — drain e upgrade de nó respeitam.
7. HPA `autoscaling/v2` em `averageUtilization: 50` do request, com `behavior` explícito — o padrão de 300 s de estabilização na descida existe por um motivo (flapping).

## O que quebra na primeira rodada

- **HPA mostra `<unknown>`** — metrics-server sem o patch `--kubelet-insecure-tls` (só kind) ou ainda sem a 1ª coleta (~30 s). `kubectl top pods -n tbx` tem que responder antes do HPA.
- **`ImagePullBackOff`** — pacote privado no GHCR ou tag `sha-xxxxxxx` não trocada.
- **Pod não sobe e `describe` fala de `PodSecurity`** — o namespace exige `restricted`; qualquer container sem `seccompProfile`/`drop: ALL`/`runAsNonRoot` é recusado. É de propósito.
- **`curl localhost:8080` vazio** — cluster criado sem o `extraPortMappings` (cluster antigo do vídeo de 14/ago). `kind delete cluster --name tbx` e `make cluster` de novo — ou `kubectl -n tbx port-forward svc/tbx-api 8080:80`.
- **HPA não desce** — está esperando o `stabilizationWindowSeconds`. Em produção isso é feature, não bug.

## Fontes

- Kubernetes docs — [Probes](https://kubernetes.io/docs/concepts/workloads/pods/probes/) · [Horizontal Pod Autoscaling](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/) · [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)
- Kubernetes v1.37 (26/ago/2026): [Metrics API estável](https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/) · [HPA scale-to-zero em beta](https://kubernetes.io/blog/2026/09/02/kubernetes-v1-37-hpa-scale-to-zero-beta/)
- [metrics-server](https://github.com/kubernetes-sigs/metrics-server) (README: `--kubelet-insecure-tls` é para teste)
- Datadog — [State of Containers and Serverless 2025](https://www.datadoghq.com/state-of-containers-and-serverless/)
- PostHog — [post-mortem 29/set/2025](https://posthog.com/handbook/company/post-mortems/2025-09-29-flags-is-down) (probes mal configuradas mantiveram pods em crash loop recebendo tráfego por 45 min)
