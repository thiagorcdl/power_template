#!/usr/bin/env bash
set -euo pipefail

echo "[test] running..."

# Scaffold: the assistant must update this when the project stack is chosen.
# Examples:
# - Node/TS: npm test
# - Python: pytest -q
# - Go: go test ./...
echo "[test] no test runner configured. Update scripts/test.sh for this project's stack."
exit 1

