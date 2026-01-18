---
name: detect-stack
description: Auto-detect programming languages, frameworks, and tools used in the project
license: MIT
---

# detect-stack Skill

## Purpose
Detect programming languages, frameworks, and tools used in the project.

## When to Use
- During project initialization
- After adding new dependencies
- Before updating stack configuration
- When project stack evolves

## Workflow

### Phase 1: Scan Project Files

#### 1.1 Search for Package Manager Files
Scan project root for these files:

```bash
# Node.js/TypeScript
package.json
package-lock.json
yarn.lock
pnpm-lock.yaml
tsconfig.json

# Python
requirements.txt
requirements-dev.txt
pyproject.toml
setup.py
setup.cfg
Pipfile
poetry.lock

# Go
go.mod
go.sum

# Rust
Cargo.toml
Cargo.lock

# Java/Kotlin
pom.xml
build.gradle
build.gradle.kts
settings.gradle

# Ruby
Gemfile
Gemfile.lock

# PHP
composer.json
composer.lock

# Elixir
mix.exs
mix.lock

# Dart/Flutter
pubspec.yaml
pubspec.lock

# Clojure
project.clj
build.boot

# Crystal
shard.yml
shard.lock

# Scala
build.sbt

# Swift
Package.swift
Package.resolved

# C/C++
CMakeLists.txt
Makefile
configure.ac

# Haskell
package.yaml
*.cabal
stack.yaml
```

#### 1.2 Analyze Found Files
For each file found, extract information:

**package.json (Node.js/TypeScript)**
```bash
# Detect TypeScript
if grep -q '"typescript"' package.json || grep -q '"@types/'" package.json; then
  echo "typescript"
fi

# Detect frameworks
dependencies=$(cat package.json | grep -A 100 '"dependencies"' | grep -E '"(react|vue|angular|next|express|fastify|nest|@nestjs/core)"' | sed 's/.*"\([^"]*\)".*/\1/')
```

**requirements.txt / pyproject.toml (Python)**
```bash
# Detect Python
echo "python"

# Detect frameworks
if grep -qE "(django|flask|fastapi|tornado)" requirements.txt 2>/dev/null; then
  grep -E "(django|flask|fastapi|tornado)" requirements.txt | sed 's/==.*//' | head -1
fi

if grep -qE "(django|flask|fastapi|tornado)" pyproject.toml 2>/dev/null; then
  grep -E "(django|flask|fastapi|tornado)" pyproject.toml | sed 's/.*"\([^"]*\)".*/\1/'
fi
```

**go.mod (Go)**
```bash
# Detect Go
echo "go"

# Detect frameworks
if grep -qE "(gin|echo|fiber|go-chi|grpc)" go.mod; then
  grep -E "(gin|echo|fiber|go-chi|grpc)" go.mod | sed 's/.*\t//' | head -1
fi
```

**Cargo.toml (Rust)**
```bash
# Detect Rust
echo "rust"

# Detect frameworks
if grep -qE "(actix|axum|rocket|tokio)" Cargo.toml; then
  grep -E "(actix|axum|rocket|tokio)" Cargo.toml | sed 's/.* = "\([^"]*\)".*/\1/'
fi
```

### Phase 2: Detect Languages

#### 2.1 Map Files to Languages
Create language map:

```json
{
  "package.json": ["javascript", "typescript"],
  "tsconfig.json": ["typescript"],
  "requirements.txt": ["python"],
  "pyproject.toml": ["python"],
  "setup.py": ["python"],
  "go.mod": ["go"],
  "Cargo.toml": ["rust"],
  "pom.xml": ["java"],
  "build.gradle": ["java", "kotlin"],
  "Gemfile": ["ruby"],
  "composer.json": ["php"],
  "mix.exs": ["elixir"],
  "pubspec.yaml": ["dart"],
  "project.clj": ["clojure"],
  "shard.yml": ["crystal"],
  "build.sbt": ["scala"]
}
```

#### 2.2 Scan Source Files
Also check for source files:
- `.ts` → TypeScript
- `.tsx` → TypeScript React
- `.js` → JavaScript
- `.jsx` → JavaScript React
- `.py` → Python
- `.go` → Go
- `.rs` → Rust
- `.java` → Java
- `.kt` → Kotlin
- `.rb` → Ruby
- `.php` → PHP
- `.ex` → Elixir
- `.dart` → Dart
- `.clj` → Clojure
- `.cr` → Crystal
- `.scala` → Scala

### Phase 3: Detect Frameworks

#### 3.1 Analyze Dependencies
Parse dependencies to detect frameworks:

**JavaScript/TypeScript Frameworks**
```json
{
  "react": "React",
  "react-dom": "React",
  "next": "Next.js",
  "nuxt": "Nuxt",
  "vue": "Vue",
  "vue-router": "Vue",
  "angular": "Angular",
  "@angular/core": "Angular",
  "@angular/common": "Angular",
  "svelte": "Svelte",
  "svelte-kit": "SvelteKit",
  "express": "Express",
  "fastify": "Fastify",
  "nest": "NestJS",
  "@nestjs/core": "NestJS",
  "@nestjs/common": "NestJS",
  "koa": "Koa",
  "hapi": "Hapi"
}
```

**Python Frameworks**
```json
{
  "django": "Django",
  "djangorestframework": "Django REST Framework",
  "flask": "Flask",
  "fastapi": "FastAPI",
  "tornado": "Tornado",
  "aiohttp": "aiohttp",
  "quart": "Quart",
  "sanic": "Sanic",
  "starlette": "Starlette"
}
```

**Go Frameworks**
```json
{
  "github.com/gin-gonic/gin": "Gin",
  "github.com/labstack/echo/v4": "Echo",
  "github.com/gofiber/fiber/v2": "Fiber",
  "github.com/go-chi/chi/v5": "Chi",
  "google.golang.org/grpc": "gRPC",
  "github.com/gorilla/mux": "Mux"
}
```

**Rust Frameworks**
```json
{
  "actix-web": "Actix Web",
  "axum": "Axum",
  "rocket": "Rocket",
  "tokio": "Tokio",
  "warp": "Warp",
  "tide": "Tide"
}
```

### Phase 4: Detect Build Tools

#### 4.1 Build Tool Detection
```json
{
  "vite": "Vite",
  "webpack": "Webpack",
  "rollup": "Rollup",
  "parcel": "Parcel",
  "esbuild": "esbuild",
  "babel": "Babel",
  "tsc": "TypeScript Compiler",
  "pytest": "pytest",
  "jest": "Jest",
  "vitest": "Vitest",
  "mocha": "Mocha",
  "jasmine": "Jasmine",
  "go test": "Go Test",
  "cargo test": "Cargo Test",
  "gradle": "Gradle",
  "maven": "Maven"
}
```

### Phase 5: Generate Stack Report

#### 5.1 Create Stack Configuration
Save to `.opencode/config/stack.json`:

```json
{
  "languages": ["typescript", "python"],
  "frameworks": ["React", "FastAPI"],
  "package_managers": ["npm", "pip"],
  "build_tools": ["Vite", "pytest"],
  "test_frameworks": ["Vitest", "pytest"],
  "detected_at": "2026-01-18T13:45:00Z",
  "manual_override": false,
  "files_detected": [
    "package.json",
    "tsconfig.json",
    "requirements.txt",
    "pyproject.toml"
  ]
}
```

#### 5.2 Display Summary
```
Stack Detection Summary

Languages:
  ✓ TypeScript (from package.json, tsconfig.json)
  ✓ Python (from requirements.txt, pyproject.toml)

Frameworks:
  ✓ React (from package.json)
  ✓ FastAPI (from requirements.txt)

Package Managers:
  ✓ npm (from package.json)
  ✓ pip (from requirements.txt)

Build Tools:
  ✓ Vite (from package.json)
  ✓ pytest (from pyproject.toml)

Test Frameworks:
  ✓ Vitest (from package.json)
  ✓ pytest (from requirements.txt)

Configuration saved to: .opencode/config/stack.json
```

### Phase 6: Handle Manual Override

#### 6.1 Check for Override
Check if `.opencode/config/stack.json` exists and has `manual_override: true`

#### 6.2 Merge Detection with Override
```json
{
  "detected": {
    "languages": ["typescript", "python"],
    "frameworks": ["React", "FastAPI"]
  },
  "override": {
    "languages": ["typescript"],
    "frameworks": ["React"]
  },
  "merged": {
    "languages": ["typescript"],
    "frameworks": ["React"],
    "manual_override": true
  }
}
```

#### 6.3 Ask for Confirmation
```
Detected stack: TypeScript, Python, React, FastAPI
Manual override: TypeScript, React

Which to use?
  1) Detected stack
  2) Manual override
  3) Merge both

Select option [1/2/3]:
```

## Usage

```bash
/skill detect-stack
```

### Options

```bash
/skill detect-stack --override '{"languages": ["typescript"], "frameworks": ["react"]}'
```
Provide manual stack configuration

```bash
/skill detect-stack --append '{"languages": ["rust"]}'
```
Append to detected stack

```bash
/skill detect-stack --json
```
Output JSON only

```bash
/skill detect-stack --force
```
Force re-detection (overwrite existing config)

## Required Environment Variables
None required

## Optional Environment Variables

- `STACK_OVERRIDE`: JSON string with manual override
- `STACK_APPEND`: JSON string with items to append
- `FORCE_DETECT`: Set to "1" to force re-detection
- `OUTPUT_FORMAT`: `json` or `text` (default: `text`)

## Required Agents

- `builder`: Analyzes project structure and files

## Error Handling

### No Files Found
```
Warning: No package manager files found
Stack cannot be auto-detected

Please manually configure stack in .opencode/config/stack.json or add package manager files
```

### Unsupported Language
```
Warning: Language 'erlang' detected but not supported
Adding to stack with default configuration

Consider manually adding lint/test commands to scripts
```

### Parse Error
```
Error: Failed to parse package.json
Reason: Invalid JSON

Please check file format or manually configure stack
```

## Success Criteria

1. ✅ Project files scanned successfully
2. ✅ Languages detected or loaded from override
3. ✅ Frameworks detected from dependencies
4. ✅ Build tools identified
5. ✅ Stack configuration saved
6. ✅ Summary displayed to user

## Example Session

```bash
$ /skill detect-stack

[Scan Project Files]
Searching for package manager files...
✓ Found: package.json
✓ Found: tsconfig.json
✓ Found: requirements.txt
✓ Found: pyproject.toml
✓ Found: go.mod

[Analyze Languages]
Detected:
  ✓ TypeScript (from package.json, tsconfig.json)
  ✓ Python (from requirements.txt, pyproject.toml)
  ✓ Go (from go.mod)

[Analyze Frameworks]
Analyzing package.json...
  ✓ React detected
  ✓ Next.js detected
  ✓ Vitest detected

Analyzing requirements.txt...
  ✓ FastAPI detected
  ✓ pytest detected

Analyzing go.mod...
  ✓ Gin detected

[Generate Stack Report]
Stack Detection Summary

Languages:
  ✓ TypeScript
  ✓ Python
  ✓ Go

Frameworks:
  ✓ React, Next.js
  ✓ FastAPI
  ✓ Gin

Package Managers:
  ✓ npm
  ✓ pip
  ✓ go

Build Tools:
  ✓ Vite
  ✓ pytest
  ✓ Go Test

Test Frameworks:
  ✓ Vitest
  ✓ pytest
  ✓ Go Test

Configuration saved to: .opencode/config/stack.json

[Confirmation]
Is this stack correct? [yes/no/edit]:
> yes

✓ Stack detection complete!

Next steps:
  - Run /skill update-stack-config to configure linting and testing
  - Review .opencode/config/stack.json
  - Manually edit stack.json if needed
```

## Troubleshooting

### "No languages detected"
- Check if package manager files exist
- Verify files are in project root
- Manually create `.opencode/config/stack.json`

### "Framework not detected"
- Framework might not be in dependencies
- Check if framework is a dev dependency
- Manually add to `.opencode/config/stack.json`

### "Multiple frameworks detected for same language"
- All detected frameworks are included
- Review and remove unused frameworks
- Manually edit `.opencode/config/stack.json`

### "Old stack in config"
- Run with `--force` to re-detect
- Or manually edit `.opencode/config/stack.json`

## Customization

### Custom Language Detection
Add custom language patterns:
```json
{
  "language_patterns": {
    ".erl": "erlang",
    "*.ex": "elixir"
  }
}
```

### Custom Framework Detection
Add custom framework patterns:
```json
{
  "framework_patterns": {
    "phoenix": "Phoenix Framework",
    "play": "Play Framework"
  }
}
```

### Custom File Mappings
Add custom file mappings:
```json
{
  "file_mappings": {
    "rebar.config": ["erlang"],
    "mix.exs": ["elixir"]
  }
}
```
