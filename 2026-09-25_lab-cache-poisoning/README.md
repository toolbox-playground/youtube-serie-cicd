# Cache poisoning no GitHub Actions — laboratório controlado

Este repositório demonstra, **num ambiente controlado e com um arquivo
marcador inerte**, como um pull request de baixa confiança pode contaminar o
cache de build que a branch `main` reutiliza — e depois **bloqueia o ataque**
com as proteções que o GitHub liberou em setembro de 2026.

> Sem segredos, sem exfiltração, sem código malicioso de verdade. O "ataque" é
> um `echo` que escreve um `.txt` inofensivo. O objetivo é **defensivo**:
> entender a fronteira de confiança do cache e como fechá-la.

## O que está aqui

```
app/            API FastAPI mínima (/health e /)
tests/          2 testes (pytest)
build.sh        passo de build LEGÍTIMO — gera build-cache/ (o que é cacheado)
attack/         build.sh.malicioso (a versão do PR) + explicação do vetor
../.github/workflows/            workflows executáveis na raiz do repositório
  01-build-confiavel-VULNERAVEL.yml   push na main restaura o cache e confia nele
  02-pr-target-VULNERAVEL.yml         o vetor: pull_request_target + Pwn Request + chave compartilhada
  03-build-confiavel-CORRIGIDO.yml    chaves separadas por confiança (trusted-)
  04-pr-CORRIGIDO.yml                 pull_request + cache-mode: read + chave pr-
docs/
  passo-a-passo.md            roteiro de execução do laboratório
  execution-protections.md    a defesa que não é editável no PR
```

## O vetor (resumo)

`pull_request_target` roda no **contexto da base**, então o cache que ele grava
cai no **escopo da main**. Se esse workflow ainda faz **checkout + execução do
código do PR** (Pwn Request) e usa uma **chave de cache compartilhada** com a
main, um PR consegue plantar conteúdo que a execução confiável vai restaurar.

## A correção, em camadas (defesa em profundidade)

1. **Execution protections** (política de repo/org, GA em 17/set/2026) —
   desabilita `pull_request_target`. **Não é editável no PR.** É a parede.
2. **`pull_request` em vez de `_target`** — contexto do fork, cache no merge ref
   isolado.
3. **Separação de chaves por confiança** — `trusted-` (main) × `pr-` (PR). Não colidem.
4. **`cache-mode: read`** (novo, 10/set/2026) — eventos de baixa confiança só
   restauram. **Cinto, não parede** — o YAML é editável pelo autor do PR.
5. **`permissions:` mínimas + actions fixadas por SHA** — higiene de sempre.

O workflow 02 declara `cache-mode: write` e `allow-unsafe-pr-checkout: true`
de propósito: o GitHub hoje bloqueia esses dois passos perigosos por padrão.
Use o cenário vulnerável somente no repositório isolado do laboratório.
Os quatro arquivos ficam visíveis na raiz; antes da gravação, siga a ordem de
ativação e desativação em `docs/passo-a-passo.md`.

## `cache-mode` — os quatro modos

| Modo | Restaura | Grava | Uso |
|---|---|---|---|
| `read` | sim | não | PRs deste laboratório; padrão de `pull_request_target` |
| `write` | sim | sim | eventos confiáveis (push na main) — **default** deles |
| `write-only` | não | sim | jobs que só populam cache |
| `none` | não | não | jobs que não devem tocar o cache |

Definível no nível do **workflow** e do **job** (job tem precedência); a
permissão **não aumenta** ao atravessar reusable workflows.

## Reproduzir

Ver `docs/passo-a-passo.md`. Localmente dá para rodar só o app e os builds:

```bash
cd 2026-09-25_lab-cache-poisoning
python -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
pytest -q
bash build.sh && ls -la build-cache        # build limpo
cp build.sh build.sh.original
cp attack/build.sh.malicioso build.sh && bash build.sh && ls -la build-cache  # marcador aparece
mv build.sh.original build.sh                # restaurar o script legítimo
```

## Fontes

- GitHub Changelog — *Control GitHub Actions cache access with cache-mode* (10/set/2026)
- GitHub Changelog — *Workflow execution protections in GitHub Actions GA* (17/set/2026)
- GitHub Docs — *Dependency caching reference* (escopo de cache por branch/merge ref)
- GitHub CodeQL — *actions/actions-cache-poisoning-direct-cache*
- Adnan Khan — *The Monsters in Your Build Cache* (2024)
