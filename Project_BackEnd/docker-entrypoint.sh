#!/bin/sh
set -e

if [ -n "$GOOGLE_CREDENTIALS_JSON_B64" ]; then
    mkdir -p "$(dirname "$GOOGLE_CREDENTIALS_PATH")"
    echo "$GOOGLE_CREDENTIALS_JSON_B64" | base64 -d > "$GOOGLE_CREDENTIALS_PATH"
fi

alembic upgrade head
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"
