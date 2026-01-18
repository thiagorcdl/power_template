#!/usr/bin/env bash
set -euo pipefail

echo "[test] running..."

# Load stack configuration
STACK_FILE=".opencode/config/stack.json"
if [ -f "$STACK_FILE" ]; then
  LANGUAGES=$(jq -r '.languages[]' "$STACK_FILE" 2>/dev/null || echo "")
else
  LANGUAGES=""
fi

# TypeScript/JavaScript
if echo "$LANGUAGES" | grep -qE "^(typescript|javascript)$"; then
  if [ -f "package.json" ]; then
    echo "[test] running npm test..."
    
    if npm run test >/dev/null 2>&1 || [ -f "node_modules/.bin/jest" ] || [ -f "node_modules/.bin/vitest" ]; then
      npm test || { echo "[test] npm test failed"; exit 1; }
    else
      echo "[test] test runner not configured in package.json"
      exit 1
    fi
  fi
fi

# Python
if echo "$LANGUAGES" | grep -q "python"; then
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "[test] running pytest..."
    
    if command -v pytest >/dev/null 2>&1; then
      pytest -q || { echo "[test] pytest failed"; exit 1; }
    else
      echo "[test] pytest not installed. Install with: pip install pytest"
      exit 1
    fi
  fi
fi

# Go
if echo "$LANGUAGES" | grep -q "go"; then
  if [ -f "go.mod" ]; then
    echo "[test] running go test..."
    
    if command -v go >/dev/null 2>&1; then
      go test ./... || { echo "[test] go test failed"; exit 1; }
    fi
  fi
fi

# Rust
if echo "$LANGUAGES" | grep -q "rust"; then
  if [ -f "Cargo.toml" ]; then
    echo "[test] running cargo test..."
    
    if command -v cargo >/dev/null 2>&1; then
      cargo test || { echo "[test] cargo test failed"; exit 1; }
    fi
  fi
fi

# Java
if echo "$LANGUAGES" | grep -q "java"; then
  if [ -f "pom.xml" ]; then
    echo "[test] running mvn test..."
    
    if command -v mvn >/dev/null 2>&1; then
      mvn test || { echo "[test] mvn test failed"; exit 1; }
    fi
  elif [ -f "build.gradle" ]; then
    echo "[test] running gradle test..."
    
    if command -v gradle >/dev/null 2>&1; then
      gradle test || { echo "[test] gradle test failed"; exit 1; }
    fi
  fi
fi

# Ruby
if echo "$LANGUAGES" | grep -q "ruby"; then
  if [ -f "Gemfile" ]; then
    echo "[test] running rspec..."
    
    if bundle exec rspec >/dev/null 2>&1; then
      bundle exec rspec || { echo "[test] rspec failed"; exit 1; }
    else
      echo "[test] rspec not configured"
      exit 1
    fi
  fi
fi

# PHP
if echo "$LANGUAGES" | grep -q "php"; then
  if [ -f "composer.json" ]; then
    echo "[test] running phpunit..."
    
    if [ -f "vendor/bin/phpunit" ]; then
      vendor/bin/phpunit || { echo "[test] phpunit failed"; exit 1; }
    else
      echo "[test] phpunit not configured"
      exit 1
    fi
  fi
fi

# Fallback: scaffold if no stack detected
if [ -z "$LANGUAGES" ]; then
  echo "[test] no test runner configured. Update scripts/test.sh for this project's stack."
  echo "Run /detect-stack to auto-detect stack, or run /update-stack-config to configure manually."
  exit 1
fi

echo "[test] all tests passed"
