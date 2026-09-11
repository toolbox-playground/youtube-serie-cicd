#!/usr/bin/env bash
# Pré-flight: tudo o que quebra "na primeira rodada" deste vídeo, checado ANTES de gravar.
# Uso: bash scripts/preflight.sh <REPO_URL> <PASTA_DO_VIDEO_PASSADO>
set -uo pipefail

REPO_URL="${1:-https://github.com/toolbox-playground/youtube-serie-cicd.git}"
PREV_DIR="${2:-../k8s-hpa-probes-self-healing}"
MANIFEST="${PREV_DIR}/k8s/deployment.yaml"
REPO_SLUG="$(sed -E 's#https://github.com/##; s#\.git$##' <<<"${REPO_URL}")"
IMAGE="ghcr.io/${REPO_SLUG,,}"
fail=0
ok()   { printf '  \033[32m✔\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✘\033[0m %s\n' "$*"; fail=1; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }

echo "== ferramentas"
for t in docker kind kubectl yq gh curl jq; do
  command -v "$t" >/dev/null && ok "$t" || bad "$t não encontrado"
done
docker info >/dev/null 2>&1 && ok "docker daemon" || bad "docker daemon não responde"

echo "== vídeo passado (${PREV_DIR})"
[ -f "${PREV_DIR}/kind/kind-config.yaml" ] && ok "kind/kind-config.yaml" || bad "faltou ${PREV_DIR}/kind/kind-config.yaml"
[ -f "${MANIFEST}" ] && ok "k8s/deployment.yaml" || bad "faltou ${MANIFEST}"
grep -q '^cluster:' "${PREV_DIR}/Makefile" 2>/dev/null && ok "alvo 'make cluster' existe" || warn "sem alvo 'cluster' na Makefile do vídeo passado — ajuste PREV_DIR ou o alvo 'cluster' desta Makefile"
ls "${PREV_DIR}/k8s/"kustomization.y*ml >/dev/null 2>&1 && warn "há kustomization.yaml em k8s/ — a Application usa 'directory'; remova ou troque para source.kustomize" || true

echo "== manifesto: exatamente 1 linha de imagem, com tag sha- real"
n=$(grep -cE "image: ${IMAGE}:sha-[0-9a-fx]+" "${MANIFEST}" 2>/dev/null || echo 0)
[ "$n" = "1" ] && ok "1 linha 'image: ${IMAGE}:sha-…'" || bad "esperava 1 linha 'image: ${IMAGE}:sha-…' em ${MANIFEST}, achei ${n} (nome da imagem bate com o repo?)"
grep -qE "image: ${IMAGE}:sha-x+" "${MANIFEST}" 2>/dev/null && warn "tag ainda é o placeholder sha-xxxxxxx — o 1º run da pipeline troca; o Argo vai dar ImagePullBackOff até lá (esperado)"
tag=$(grep -oE "sha-[0-9a-f]{7}" "${MANIFEST}" | head -1)
[ -n "${tag}" ] && [ ${#tag} -eq 11 ] && ok "formato da tag: ${tag} (sha- + 7 hex, igual ao docker/metadata-action)" || true

echo "== repo e imagem públicos (senão o Argo/kind do espectador não leem)"
code=$(curl -s -o /dev/null -w '%{http_code}' "https://api.github.com/repos/${REPO_SLUG}")
[ "$code" = "200" ] && ok "repo público: ${REPO_SLUG}" || bad "repo ${REPO_SLUG} não é público (HTTP ${code})"
tok=$(curl -s "https://ghcr.io/token?scope=repository:${REPO_SLUG,,}:pull" | jq -r .token 2>/dev/null)
if [ -n "${tag:-}" ]; then
  code=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer ${tok}" \
        -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json, application/vnd.docker.distribution.manifest.list.v2+json" \
        "https://ghcr.io/v2/${REPO_SLUG,,}/manifests/${tag}")
  [ "$code" = "200" ] && ok "imagem pública: ${IMAGE}:${tag}" || bad "${IMAGE}:${tag} não é pública/não existe (HTTP ${code}) — Packages → Package settings → Change visibility"
fi

echo "== branch main: o bot consegue fazer push?"
code=$(gh api "repos/${REPO_SLUG}/branches/main/protection" -i 2>/dev/null | head -1 | grep -oE '[0-9]{3}' | head -1)
case "${code:-}" in
  404) ok "sem branch protection — push direto funciona" ;;
  200) warn "main protegida — o job bump-manifest vai falhar no push; ver pipeline/README.md item 3" ;;
  *)   warn "não consegui ler a proteção (gh auth?) — confira em Settings → Branches" ;;
esac

echo "== workflow"
wf=".github/workflows/docker-gitHub-actions-pipeline-de-prod.yml"
for base in . .. ../..; do [ -f "$base/$wf" ] && wf="$base/$wf" && break; done
if [ -f "$wf" ]; then
  grep -q 'bump-manifest:' "$wf" && ok "job bump-manifest já está no workflow" || warn "job bump-manifest ainda não colado em $wf"
  grep -q 'COPIE-O-SHA' "$wf" && bad "placeholder do SHA do checkout ainda no workflow" || true
  if grep -qE '^\s+paths(-ignore)?:' "$wf"; then ok "gatilho tem paths/paths-ignore — leia pipeline/README.md item 2"; else warn "gatilho sem paths: adicione paths-ignore para a pasta k8s (README item 2)"; fi
else
  warn "workflow não encontrado a partir daqui — rode da raiz do monorepo para checar"
fi

echo
[ $fail -eq 0 ] && echo "PRÉ-FLIGHT OK — pode gravar." || { echo "PRÉ-FLIGHT COM FALHAS — não grave ainda."; exit 1; }
