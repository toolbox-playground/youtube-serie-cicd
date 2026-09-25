# O ataque, em uma frase

Um pull request **não altera nenhum workflow** e mesmo assim consegue colocar
um arquivo dentro do cache de build que a **branch main** reutiliza depois.

## Por que funciona (a fronteira de confiança)

| Peça | O que faz | Por que importa |
|---|---|---|
| `pull_request_target` | roda no **contexto da base (main)** | o cache gravado cai no **escopo da main**, não no merge ref isolado do PR |
| `checkout` do `head.sha` | traz o **código do PR** | o workflow (confiável) passa a **executar código de terceiro** — "Pwn Request" |
| `bash build.sh` | roda o script **do PR** | a linha maliciosa do PR escreve em `build-cache/` |
| `cache-mode: write` | libera gravação no contexto de `pull_request_target` | o padrão atual é somente leitura |
| `allow-unsafe-pr-checkout: true` | permite checkout do fork no `actions/checkout` atual | o checkout bloqueia esse uso por padrão |
| chave `build-cache-${{ hashFiles('2026-09-25_lab-cache-poisoning/requirements.txt') }}` | **mesma chave** da main | o atacante não muda `requirements.txt`, então a chave colide |

O atacante **não quebra** o isolamento por branch do GitHub. Ele usa um
workflow que, por configuração, **já roda do lado confiável da fronteira**.

## O detalhe honesto que a maioria dos tutoriais omite

O cache do GitHub Actions é **imutável por chave**: não dá para sobrescrever
uma entrada que já existe. Para o marcador do PR ser o que a main restaura, a
entrada precisa estar **vazia** quando o PR roda (o atacante grava primeiro),
ou o atacante **força a expulsão** da entrada legítima estourando o limite de
10 GB do repositório e regrava a chave. No laboratório a gente **limpa o cache
depois do primeiro push e antes do PR** para reproduzir de forma limpa em uma tomada — e o roteiro diz isso em
voz alta, porque esconder essa condição é o tipo de coisa que os comentários
detonam.

Fonte da técnica: Adnan Khan, "The Monsters in Your Build Cache" (2024) e a
query CodeQL `actions/actions-cache-poisoning-direct-cache` do próprio GitHub.
