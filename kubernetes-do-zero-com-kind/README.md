# Laboratório — Kubernetes do zero em 2026 (TBX Tech)

Repositório do vídeo **"Kubernetes do zero em 2026: seu primeiro cluster na prática"** — canal [@ToolboxTechnology](https://www.youtube.com/@ToolboxTechnology).

Objetivo: subir um cluster de três nós na sua máquina, colocar uma aplicação no ar com as boas práticas que a maioria dos tutoriais pula, e **quebrar tudo de propósito** para aprender a diagnosticar.

## Pré-requisitos

- Docker instalado e rodando
- `kubectl` ([instalação](https://kubernetes.io/docs/tasks/tools/))
- `kind` ([instalação](https://kind.sigs.k8s.io/docs/user/quick-start/))
- ~8 GB de RAM livre

> Kubernetes **não** é requisito de vaga de entrada. Se você está começando em TI, veja antes o vídeo *"Roadmap DevOps 2026: do zero ao primeiro emprego"*.

## 1. Subir o cluster

```bash
kind create cluster --config kind.yaml
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -n kube-system     # control plane rodando na sua máquina
```

## 2. Subir a aplicação

```bash
kubectl apply -f k8s/
kubectl get deploy,rs,po -l app=tbx-web   # Deployment -> ReplicaSet -> Pod
kubectl get endpoints tbx-web             # o Service só roteia para pods Ready
kubectl port-forward svc/tbx-web 8080:80  # http://localhost:8080
```

`port-forward` é depuração. Não é jeito de expor aplicação.

## 3. Quebrar de propósito

**Quebra 1 — matar um pod.** O ReplicaSet recria sozinho: é o loop de reconciliação.

```bash
kubectl get pods -w          # em outro terminal
kubectl delete pod <nome-do-pod>
```

**Quebra 2 — imagem que não existe.** Troque a tag da imagem no `deployment.yaml` por algo inválido e aplique. O `apply` dá sucesso; a falha vem depois.

```bash
kubectl apply -f k8s/
kubectl get pods                          # ImagePullBackOff
kubectl describe pod <nome>               # seção Events, no fim
kubectl events --for pod/<nome>
kubectl rollout status deploy/tbx-web     # trava
kubectl rollout undo   deploy/tbx-web     # volta
```

**Quebra 3 — probe mentindo.** Troque o `path` da `readinessProbe` para `/nao-existe` e aplique.

```bash
kubectl get pods              # Running, mas READY 0/1
kubectl get endpoints tbx-web # vazio: o Service parou de mandar tráfego
```

## 4. Limpar

```bash
kind delete cluster --name tbx
```

## O método de diagnóstico (o que realmente importa)

`get` → onde dói · `describe` → **Events** · `logs` → o que a aplicação diz · `events` → a linha do tempo.

## O que mudou em 2026

O controller `kubernetes/ingress-nginx` foi **aposentado em março de 2026** — sem releases, sem correções de bug e sem patches de CVE ([comunicado oficial](https://www.kubernetes.io/blog/2026/01/29/ingress-nginx-statement/)). A **API Ingress continua existindo**; o caminho recomendado é o [Gateway API](https://gateway-api.sigs.k8s.io/), com a ferramenta [`ingress2gateway`](https://kubernetes.io/blog/2026/03/20/ingress2gateway-1-0-release) para migração. Qualquer tutorial que ainda mande instalar o ingress-nginx está desatualizado.

## Próximos passos sugeridos

Service e DNS interno → ConfigMap e Secret → volumes → Gateway API → Helm → cloud gerenciada (EKS/GKE/AKS).

---

Continue a trilha em [treinamentos.tbxtech.com.br](https://treinamentos.tbxtech.com.br) · [Discord da comunidade](https://discord.gg/dKPeKFsBE3)
