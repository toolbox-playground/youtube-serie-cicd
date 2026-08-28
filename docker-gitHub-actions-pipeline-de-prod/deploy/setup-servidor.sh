#!/usr/bin/env bash
# Preparação ÚNICA do servidor (Ubuntu 22.04/24.04). Roda uma vez, como root ou com sudo.
# Depois disso, quem toca no servidor é a pipeline.
set -euo pipefail

APP_DIR=/opt/tbx-api
DEPLOY_USER=deploy

# 1) Docker Engine + Compose plugin (script oficial)
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

# 2) Usuário exclusivo para a pipeline: sem sudo, só no grupo docker
if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$DEPLOY_USER"
fi
usermod -aG docker "$DEPLOY_USER"

# 3) Diretório da aplicação: compose + .env
mkdir -p "$APP_DIR"
cp docker-compose.yml "$APP_DIR/docker-compose.yml"
[ -f "$APP_DIR/.env" ] || cp .env.example "$APP_DIR/.env"
chown -R "$DEPLOY_USER":"$DEPLOY_USER" "$APP_DIR"

# 4) Chave SSH da pipeline (gerar no SEU computador: ssh-keygen -t ed25519 -f pipeline_key -N "")
#    Cole a pública em /home/deploy/.ssh/authorized_keys; a privada vira o secret SSH_KEY no GitHub.
install -d -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh"
touch "/home/$DEPLOY_USER/.ssh/authorized_keys"
chmod 600 "/home/$DEPLOY_USER/.ssh/authorized_keys"
chown "$DEPLOY_USER":"$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh/authorized_keys"

echo "OK. Agora: cole a chave pública em /home/$DEPLOY_USER/.ssh/authorized_keys"
echo "e ajuste a imagem em $APP_DIR/docker-compose.yml (ghcr.io/usuario/repo)."
