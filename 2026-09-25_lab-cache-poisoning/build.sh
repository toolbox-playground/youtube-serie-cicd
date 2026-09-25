#!/usr/bin/env bash
set -euo pipefail

# build.sh — LEGÍTIMO
# Este passo gera um diretório (build-cache/) cujo resultado é CACHEADO e
# reutilizado por builds seguintes — inclusive pela branch main.
#
# Em um projeto real: aqui você baixaria dependências, compilaria assets,
# geraria artefatos de build. Neste laboratório, ele produz um diretório
# determinístico a partir do código, para o vídeo ficar curto.
#
# O ponto do laboratório NÃO é o que este script faz — é que a main CONFIA
# no conteúdo de build-cache/ sem verificar quem o escreveu.

OUT="build-cache"
mkdir -p "$OUT"

python -c "import app.main as m; print(m.VERSION)" > "$OUT/versao.txt" 2>/dev/null || echo "local" > "$OUT/versao.txt"
find app -name '*.py' | sort > "$OUT/manifest.txt"
echo "build ok em $(date -u +%FT%TZ)" > "$OUT/build.log"

echo "== conteudo de $OUT =="
ls -la "$OUT"
