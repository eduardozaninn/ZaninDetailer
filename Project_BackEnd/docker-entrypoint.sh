#!/bin/sh
set -e

if [ -n "$GOOGLE_CREDENTIALS_JSON" ]; then
    mkdir -p "$(dirname "$GOOGLE_CREDENTIALS_PATH")"
    printf '%s' "$GOOGLE_CREDENTIALS_JSON" > "$GOOGLE_CREDENTIALS_PATH"
fi

alembic upgrade head
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"
