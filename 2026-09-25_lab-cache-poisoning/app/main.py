import os

from fastapi import FastAPI

app = FastAPI()

# A pipeline injeta o hash do commit aqui (mesmo padrão do vídeo Docker + GitHub Actions).
VERSION = os.getenv("APP_VERSION", "local")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/")
def root():
    return {"service": "tbx-api", "version": VERSION}
