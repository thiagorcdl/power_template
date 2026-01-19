#!/usr/bin/env bash
set -euo pipefail

echo "[check] running..."

if [ -f "scripts/lint.sh" ]; then
  ./scripts/lint.sh
fi

if [ -f "scripts/test.sh" ]; then
  ./scripts/test.sh
fi

echo "[check] all checks passed"
