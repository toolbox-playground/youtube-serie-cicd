# syntax=docker/dockerfile:1

# ---------- Estágio 1: builder ----------
# Aqui pode ter compilador, cache de pip, ferramenta de build. Nada disso vai pra produção.
FROM python:3.12-slim AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /build

# Dependências ANTES do código: mudou só o código, essa camada continua em cache.
COPY requirements.txt .
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install -r requirements.txt

# ---------- Estágio 2: runtime ----------
# Recomeça do zero: só o interpretador, a venv pronta e o código.
FROM python:3.12-slim AS runtime

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Patches de segurança do SO: a base slim atrasa atrás do Debian.
# Aplica os fixes disponíveis (ex: openssl) para o scan do Trivy passar limpo.
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Usuário sem privilégio. Container rodando como root é a falha nº 1 que a gente vê em auditoria.
RUN useradd --system --uid 10001 --create-home app

WORKDIR /srv
COPY --from=builder /opt/venv /opt/venv
COPY --chown=app:app app ./app

USER app
EXPOSE 8000

# O Docker (e o Compose) passam a saber se o app está VIVO, não só se o processo existe.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import sys, urllib.request; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).status == 200 else 1)"]

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
