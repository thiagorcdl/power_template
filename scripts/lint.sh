#!/usr/bin/env bash
set -euo pipefail

echo "[lint] running..."

# Scaffold: the assistant must update this when the project stack is chosen.
# Examples (pick based on stack):
# - Node/TS: npm run lint && npm run typecheck
# - Python: ruff check . && ruff format --check . && mypy .
# - Go: gofmt -w . && go vet ./... && golangci-lint run
echo "[lint] no linter configured. Update scripts/lint.sh for this project's stack."
exit 1

