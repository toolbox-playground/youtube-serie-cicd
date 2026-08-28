from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_returns_service_and_version():
    r = client.get("/")
    assert r.status_code == 200
    body = r.json()
    assert body["service"] == "tbx-api"
    assert "version" in body


def test_health_is_ok():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}
