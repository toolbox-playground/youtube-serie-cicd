import os

from fastapi import FastAPI

# APP_VERSION chega da pipeline (build-arg -> ENV). Em dev, fica "dev".
APP_VERSION = os.getenv("APP_VERSION", "dev")

app = FastAPI(title="tbx-api", version=APP_VERSION)


@app.get("/")
def root() -> dict:
    return {"service": "tbx-api", "version": APP_VERSION}


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
