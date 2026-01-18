---
name: update-stack-config
description: Update lint and test configurations based on detected or specified project stack
license: MIT
---

# update-stack-config Skill

## Purpose
Update lint and test configurations based on detected or specified project stack.

## When to Use
- After adding new language/framework to project
- After stack detection identifies new components
- Manual override when auto-detection is incorrect
- When project stack evolves

## Workflow

### Phase 1: Detect Stack

#### 1.1 Run Stack Detection
Call `/skill detect-stack` to identify current stack:
- Languages in use
- Frameworks in use
- Package managers
- Build tools

#### 1.2 Load Manual Override
Check `.opencode/config/stack.json` for manual overrides:
```json
{
  "languages": ["typescript", "python"],
  "frameworks": ["React", "FastAPI"],
  "manual_override": true
}
```

#### 1.3 Merge Stack Information
- Start with auto-detected stack
- Apply manual overrides if present
- Create final stack configuration

### Phase 2: Load Configuration Templates

#### 2.1 Load Default Commands
Load from `.opencode/config/lint-test-commands.json`:
```json
{
  "lint": {
    "typescript": {
      "commands": [
        "eslint . --ext .ts,.tsx",
        "tsc --noEmit"
      ],
      "install": [
        "npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin typescript"
      ]
    },
    "python": {
      "commands": [
        "ruff check .",
        "ruff format --check .",
        "mypy ."
      ],
      "install": [
        "pip install ruff mypy"
      ]
    }
  },
  "test": {
    "typescript": {
      "commands": [
        "npm test"
      ],
      "install": [
        "npm install --save-dev jest @types/jest ts-jest"
      ]
    },
    "python": {
      "commands": [
        "pytest -q"
      ],
      "install": [
        "pip install pytest pytest-cov"
      ]
    }
  }
}
```

### Phase 3: Generate Scripts

#### 3.1 Generate lint.sh
Create `scripts/lint.sh` with commands for detected languages:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[lint] running..."

# TypeScript
if [ -f "package.json" ] && grep -q '"typescript"' package.json || [ -f "tsconfig.json" ]; then
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

# Python
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

# Go
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

# Rust
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

# Fallback: scaffold if no stack detected
if [ -z "$LANGUAGES" ]; then
  echo "[lint] no linter configured. Update scripts/lint.sh for this project's stack."
  echo "Run /skill detect-stack to auto-detect stack, or run /skill update-stack-config to configure manually."
  exit 1
fi

echo "[lint] all checks passed"
```

#### 3.2 Generate test.sh
Create `scripts/test.sh` with commands for detected languages:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[test] running..."

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

# Fallback: scaffold if no stack detected
if [ -z "$LANGUAGES" ]; then
  echo "[test] no test runner configured. Update scripts/test.sh for this project's stack."
  echo "Run /skill detect-stack to auto-detect stack, or run /skill update-stack-config to configure manually."
  exit 1
fi

echo "[test] all tests passed"
```

### Phase 4: Update CI

#### 4.1 Update GitHub Workflow
Modify `.github/workflows/ci.yml` to install toolchains:

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # TypeScript/JavaScript
      - name: Setup Node
        if: hashFiles('package.json') != ''
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install npm dependencies
        if: hashFiles('package.json') != ''
        run: npm ci

      # Python
      - name: Setup Python
        if: hashFiles('requirements.txt') != '' || hashFiles('pyproject.toml') != ''
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install Python dependencies
        if: hashFiles('requirements.txt') != '' || hashFiles('pyproject.toml') != ''
        run: |
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          if [ -f pyproject.toml ]; then pip install .; fi

      # Go
      - name: Setup Go
        if: hashFiles('go.mod') != ''
        uses: actions/setup-go@v5
        with:
          go-version: '1.21'
          cache: true

      - name: Install Go tools
        if: hashFiles('go.mod') != ''
        run: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

      # Rust
      - name: Setup Rust
        if: hashFiles('Cargo.toml') != ''
        uses: actions-rs/toolchain@v1
        with:
          profile: minimal
          toolchain: stable
          override: true
          components: clippy

      - name: Run checks
        run: |
          chmod +x scripts/*.sh
          ./scripts/check.sh
```

### Phase 5: Verification

#### 5.1 Verify Scripts
```bash
chmod +x scripts/lint.sh scripts/test.sh
```

#### 5.2 Check Syntax
```bash
bash -n scripts/lint.sh
bash -n scripts/test.sh
```

#### 5.3 Test Scripts (if possible)
```bash
# May fail if no code exists yet, but should have valid commands
./scripts/lint.sh || true
./scripts/test.sh || true
```

### Phase 6: Commit Changes

#### 6.1 Stage Files
```bash
git add scripts/lint.sh scripts/test.sh .github/workflows/ci.yml
```

#### 6.2 Create Commit
```bash
git commit -m "chore: update stack configuration for [languages/frameworks]"
```

## Usage

```bash
/skill update-stack-config
```

### Options

```bash
/skill update-stack-config --force
```
Override existing configuration without confirmation

```bash
/skill update-stack-config --dry-run
```
Show changes without applying them

```bash
/skill update-stack-config --only-lint
```
Only update lint.sh

```bash
/skill update-stack-config --only-test
```
Only update test.sh

```bash
/skill update-stack-config --only-ci
```
Only update CI workflow

## Required Environment Variables
None required

## Optional Environment Variables

- `FORCE_UPDATE`: Set to "1" to force update without confirmation
- `DRY_RUN`: Set to "1" to show changes without applying
- `SKIP_CI_UPDATE`: Set to "1" to skip CI workflow update

## Required Agents

- `builder`: Generates scripts and updates configuration

## Error Handling

### No Stack Detected
```
Warning: No stack detected
Configuration will use default (empty) scripts
Consider manually specifying stack in .opencode/config/stack.json or add package manager files
```

### Language Not Supported
```
Warning: Language 'erlang' is not supported
Defaulting to no-op for erlang linting/testing

Consider manually adding commands to scripts
```

### Script Generation Failed
```
Error: Failed to generate scripts/lint.sh
Reason: [error message]

Please manually create the script or check configuration
```

### CI Update Failed
```
Error: Failed to update .github/workflows/ci.yml
Reason: [error message]

Please manually update the CI workflow
```

## Success Criteria

1. ✅ Stack detected or loaded from config
2. ✅ lint.sh generated with appropriate commands
3. ✅ test.sh generated with appropriate commands
4. ✅ CI workflow updated with toolchain installation
5. ✅ Scripts are executable
6. ✅ Scripts have valid syntax
7. ✅ Changes committed

## Example Session

```bash
$ /skill update-stack-config

[Detect Stack]
Detected:
  Languages: TypeScript, Python
  Frameworks: React, FastAPI
  Package managers: npm, pip

[Load Configuration]
✓ Loaded lint-test-commands.json

[Generate Scripts]
Generating scripts/lint.sh...
  ✓ TypeScript commands added
  ✓ Python commands added

Generating scripts/test.sh...
  ✓ TypeScript commands added
  ✓ Python commands added

[Update CI]
Updating .github/workflows/ci.yml...
  ✓ Node.js setup added
  ✓ Python setup added
  ✓ Dependency installation added

[Verification]
✓ Scripts are executable
✓ Scripts have valid syntax

[Summary]
Updated stack configuration:
  Languages: TypeScript, Python
  Frameworks: React, FastAPI
  
Files modified:
  ✓ scripts/lint.sh
  ✓ scripts/test.sh
  ✓ .github/workflows/ci.yml

Commit changes? [yes/no/edit]:
> yes

✓ Committed: chore: update stack configuration for typescript, python

Configuration updated successfully!
Next steps:
  - Run ./scripts/lint.sh to verify linting works
  - Run ./scripts/test.sh to verify tests work
  - Check CI workflow runs successfully
```

## Troubleshooting

### "No linting tool installed"
Install required tool:
```bash
# TypeScript
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Python
pip install ruff mypy

# Go
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Rust
rustup component add clippy
```

### "Scripts have syntax errors"
Check scripts manually:
```bash
bash -n scripts/lint.sh
bash -n scripts/test.sh
```

### "CI workflow invalid"
Validate YAML:
```bash
yamllint .github/workflows/ci.yml
```

### "Language detection incorrect"
Set manual override in `.opencode/config/stack.json`:
```json
{
  "languages": ["typescript"],
  "frameworks": ["react"],
  "manual_override": true
}
```

## Customization

### Custom Lint/Test Commands
Add custom commands to `.opencode/config/lint-test-commands.json`:
```json
{
  "lint": {
    "custom_language": {
      "commands": ["custom-lint-tool ."],
      "install": ["install-custom-tool"]
    }
  },
  "test": {
    "custom_language": {
      "commands": ["custom-test-tool"],
      "install": ["install-custom-tool"]
    }
  }
}
```

### Custom CI Steps
Add custom steps to CI workflow for specific needs:
- Database setup
- Environment variables
- Secret management
- Caching strategies

### Framework-Specific Commands
Add framework-specific linting/testing:
```json
{
  "test": {
    "typescript": {
      "commands": ["npm test"],
      "frameworks": {
        "next": ["npm run test:e2e"],
        "nestjs": ["npm run test:e2e"]
      }
    }
  }
}
```
