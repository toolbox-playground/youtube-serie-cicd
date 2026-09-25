# Passo a passo do laboratório (para gravar)

> Pré-requisito: um repositório **público** no GitHub (é onde as execution
> protections e o cenário de PR fazem sentido) e o código deste laboratório em
> `2026-09-25_lab-cache-poisoning/`. Os workflows executáveis ficam em
> `.github/workflows/` na raiz do repositório.

## Preparação (antes de gravar — não filmar)

1. Para a primeira etapa, deixe **01** e **02** em `.github/workflows/` e
   desative **03** e **04** temporariamente (por exemplo, mova os dois para
   `2026-09-25_lab-cache-poisoning/docs/`). Suba esse estado na `main`.
2. Faça **um push na main** para confirmar que o build 01 roda verde e diz
   "cache limpo — nada plantado".
3. **Depois desse push, limpe os caches** do repo em *Actions → Caches*.
   Aguarde a conclusão de todos os jobs da `main` antes de limpar. A chave
   `build-cache-...` precisa estar vazia quando o PR rodar.

## Demonstração do ataque (0:00–5:30 do vídeo)

4. Crie um branch e **abra um PR** que troca
   `2026-09-25_lab-cache-poisoning/build.sh` pelo conteúdo de
   `2026-09-25_lab-cache-poisoning/attack/build.sh.malicioso`.
   **Não toque em `requirements.txt`.** O PR não altera nenhum workflow.
5. O workflow **02 (`pull_request_target`)** dispara, roda o `build.sh` do PR e
   **grava** `build-cache/` (com `PWNED-POR-PR.txt`) na chave da main.
6. Faça um **push qualquer na main** (ou reexecute o 01). O build **01** dá
   *cache-hit*, restaura o diretório envenenado e **falha** com
   `::error CACHE ENVENENADO`, mostrando o arquivo plantado por um PR.

## Aplicar a correção (7:00 em diante)

7. Ative uma regra de **execution protections** que bloqueie
   `pull_request_target` (`docs/execution-protections.md`). Em setembro de
   2026 a regra padrão em repos públicos ainda está em modo *evaluate*; para
   bloquear de fato, a regra precisa estar em *enforce*.
8. Retire **01** e **02** de `.github/workflows/` e coloque **03** e **04** de
   volta ali. Faça commit na `main` (chaves `trusted-`/`pr-`, gatilho
   `pull_request`, `cache-mode: read`). Feche o PR antigo e abra um novo a
   partir da `main` corrigida, com a mesma alteração em `build.sh`.
9. Limpe os caches de novo e execute o novo PR e um push na `main`:
   - o PR usa a chave `pr-build-cache-...`, mas `cache-mode: read` impede a gravação;
   - a main restaura só `trusted-build-cache-...` — **íntegro**.

## Rollback / limpeza

- Apagar caches: *Actions → Caches*.
- Voltar ao estado inicial: `git restore 2026-09-25_lab-cache-poisoning/build.sh`
  no branch do PR.
