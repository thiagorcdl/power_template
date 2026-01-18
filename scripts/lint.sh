#!/usr/bin/env bash
set -euo pipefail

echo "[lint] running..."

# Load stack configuration
STACK_FILE=".opencode/config/stack.json"
if [ -f "$STACK_FILE" ]; then
  LANGUAGES=$(jq -r '.languages[]' "$STACK_FILE" 2>/dev/null || echo "")
else
  LANGUAGES=""
fi

# TypeScript
if echo "$LANGUAGES" | grep -q "typescript"; then
  if [ -f "package.json" ] && (grep -q '"typescript"' package.json || [ -f "tsconfig.json" ]); then
    echo "[lint] running TypeScript linting..."
    
    # ESLint
    if command -v npx >/dev/null 2>&1; then
      npx eslint . --ext .ts,.tsx 2>/dev/null || echo "[lint] TypeScript linting not configured"
    fi
    
    # TypeScript compiler
    if command -v npx >/dev/null 2>&1; then
      npx tsc --noEmit 2>/dev/null || echo "[lint] TypeScript type checking not configured"
    fi
  fi
fi

# JavaScript
if echo "$LANGUAGES" | grep -q "javascript"; then
  if [ -f "package.json" ]; then
    echo "[lint] running JavaScript linting..."
    
    if command -v npx >/dev/null 2>&1; then
      npx eslint . 2>/dev/null || echo "[lint] JavaScript linting not configured"
    fi
  fi
fi

# Python
if echo "$LANGUAGES" | grep -q "python"; then
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "[lint] running Python linting..."
    
    # ruff check
    if command -v ruff >/dev/null 2>&1; then
      ruff check . || { echo "[lint] Python linting failed"; exit 1; }
    else
      echo "[lint] ruff not installed. Install with: pip install ruff"
      exit 1
    fi
    
    # ruff format
    if command -v ruff >/dev/null 2>&1; then
      ruff format --check . || { echo "[lint] Python formatting check failed"; exit 1; }
    fi
    
    # mypy
    if command -v mypy >/dev/null 2>&1; then
      mypy . || echo "[lint] mypy not configured"
    fi
  fi
fi

# Go
if echo "$LANGUAGES" | grep -q "go"; then
  if [ -f "go.mod" ]; then
    echo "[lint] running Go linting..."
    
    # gofmt
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w . || echo "[lint] gofmt not configured"
    fi
    
    # go vet
    if command -v go >/dev/null 2>&1; then
      go vet ./... || echo "[lint] go vet not configured"
    fi
    
    # golangci-lint
    if command -v golangci-lint >/dev/null 2>&1; then
      golangci-lint run || echo "[lint] golangci-lint not configured"
    fi
  fi
fi

# Rust
if echo "$LANGUAGES" | grep -q "rust"; then
  if [ -f "Cargo.toml" ]; then
    echo "[lint] running Rust linting..."
    
    # cargo clippy
    if command -v cargo >/dev/null 2>&1; then
      cargo clippy -- -D warnings || echo "[lint] cargo clippy not configured"
    fi
    
    # cargo fmt
    if command -v cargo >/dev/null 2>&1; then
      cargo fmt -- --check || echo "[lint] cargo fmt not configured"
    fi
  fi
fi

# Fallback: scaffold if no stack detected
if [ -z "$LANGUAGES" ]; then
  echo "[lint] no linter configured. Update scripts/lint.sh for this project's stack."
  echo "Run /detect-stack to auto-detect stack, or run /update-stack-config to configure manually."
  exit 1
fi

echo "[lint] all checks passed"
