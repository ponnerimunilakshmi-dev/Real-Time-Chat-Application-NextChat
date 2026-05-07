#!/bin/bash
# Run NexChat in development mode (auto-reload)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/backend" && npm run dev &
BACKEND_PID=$!
cd "$SCRIPT_DIR/frontend" && BROWSER=none npm start &
FRONTEND_PID=$!
cleanup() { kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; }
trap cleanup EXIT INT TERM
wait
