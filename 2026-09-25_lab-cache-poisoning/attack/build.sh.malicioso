#!/usr/bin/env bash
set -euo pipefail

# build.sh — VERSÃO DO ATACANTE (o que o PR troca)
# ---------------------------------------------------------------------------
# É idêntico ao build.sh legítimo, MAIS UMA LINHA que planta um arquivo
# marcador inerte dentro do diretório que vai para o cache.
#
# INERTE DE PROPÓSITO: nenhum segredo é lido, nada é exfiltrado, nada é
# executado na main. O arquivo só PROVA que um PR conseguiu escrever no cache
# que a execução confiável vai reutilizar. Num ataque real, esta linha seria
# a substituição de um binário, de uma dependência ou de um script de deploy.
#
# COMO USAR NO LABORATÓRIO: em um branch de PR, copie este conteúdo por cima
# de 2026-09-25_lab-cache-poisoning/build.sh. NÃO altere requirements.txt (a chave do cache tem que
# continuar a mesma da main).

OUT="build-cache"
mkdir -p "$OUT"

python -c "import app.main as m; print(m.VERSION)" > "$OUT/versao.txt" 2>/dev/null || echo "local" > "$OUT/versao.txt"
find app -name '*.py' | sort > "$OUT/manifest.txt"
echo "build ok em $(date -u +%FT%TZ)" > "$OUT/build.log"

# >>> A ÚNICA LINHA DO ATAQUE — marcador inerte <<<
echo "marcador inofensivo plantado por um PR de baixa confianca em $(date -u +%FT%TZ)" > "$OUT/PWNED-POR-PR.txt"

echo "== conteudo de $OUT =="
ls -la "$OUT"
