# Power Template

A framework-agnostic AI-assisted software development template that uses:

- **opencode** as the AI assistant framework
- **OpenRouter** with **GLM-4.7** (primary) and **Gemini2.0** (fallback) for planning and building
- **Gemini** for web searching and documentation
- **Gemini Code Assist** for PR reviews targeting `main` branch
- Domain-specific agents for specialized tasks
- Git hooks for automated quality checks
- **Branching**: `main` (production), `feature/*` (work)

This repo is meant to be used as a **GitHub Template Repository**.

---

## What This Template Enforces

- **Branching model** with `main` and `feature/*` branches
- **Commit-time linting** (pre-commit hook runs `./scripts/lint.sh`)
- **Push-time tests** on feature branches (pre-push runs `./scripts/test.sh`)
- **CI parity**: GitHub Actions runs `./scripts/check.sh`
- **Gemini Code Assist review** on PRs to `main` (via GitHub App)
- **Stack detection**: Automatically detects languages/frameworks and configures lint/test accordingly

**Important**: `scripts/lint.sh` and `scripts/test.sh` are **dynamic** based on detected stack. The template automatically configures appropriate commands for your chosen stack.

---

## Quick Start

### 1. Install Prerequisites

#### GitHub CLI (`gh`)
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

sudo apt-get update
sudo apt-get install -y gh

gh auth login
```

#### jq (for JSON parsing)
```bash
sudo apt-get install -y jq
```

### 2. Set Required Environment Variables

You'll need API keys for the AI models:

```bash
# Add to ~/.bashrc or ~/.zshrc
export OPENROUTER_API_KEY="your-openrouter-key-here"
export GEMINI_API_KEY="your-gemini-key-here"
export GITHUB_TOKEN="your-github-token-here"
```

**Where to get API keys**:
- **OpenRouter**: https://openrouter.ai/keys
- **Gemini**: https://ai.google.dev/
- **GitHub Token**: https://github.com/settings/tokens (generate with `repo` scope)

### 3. Configure Code Reviewers

Before initializing your project, you need to configure the automated code reviewers.

#### Configure Google's Gemini Code Assist

1. Go to: https://github.com/apps/gemini-code-assist
2. Click "Use latest version"
3. Select your GitHub repository
4. Add the required GitHub Action secrets:
   ```bash
   gh secret set GEMINI_API_KEY -b "your-gemini-api-key"
   ```
5. The workflow `.github/workflows/gemini-review.yml` will be added automatically
6. Configure the workflow to trigger on PRs (legacy development branch setup):
   ```yaml
   on:
     pull_request:
       branches: [development]
   ```

### 4. Create a New Project

Create repo from template
```bash
gh repo create my-new-project --template thiagorcdl/power_template --private --clone
cd my-new-project
```

Enable git hooks
```bash
git config core.hooksPath .githooks
chmod +x .githooks/* scripts/*.sh
```

### 4. Initialize Your Project

Run opencode:

```bash
opencode
```

Run the initialization skill:

```bash
/init-project
```

This will walk you through:
1. ✅ Verifying API keys and GitHub authentication
2. ✅ Gathering project requirements and constraints
3. ✅ Creating technical design document (`docs/technical-design.md`)
4. ✅ Creating execution plan (`docs/execution-plan.md`)
5. ✅ Creating GitHub repository (semi-automated)
6. ✅ Creating GitHub issues for each task

### 5. Execute the Plan

```bash
/execute-plan
```

This will:
- Execute tasks from your execution plan
- Run linting and testing after each task
- Create commits automatically
- Update GitHub issues as tasks are completed

---

## Architecture

### Domain-Specific Agents

The template uses specialized agents for different tasks:

| Agent | Purpose | Model |
|--------|---------|-------|
| **Planner** | Creates technical designs and execution plans | GLM-4.7 (fallback: Gemini2.0) |
| **Builder** | Implements features, writes tests, fixes issues | GLM-4.7 (fallback: Gemini2.0) |
| **Web Searcher** | Finds documentation, examples, best practices | Gemini 2.0 Flash |

### Available Skills

| Skill | Description |
|-------|-------------|
| `/init-project` | Full project initialization workflow |
| `/execute-plan` | Execute tasks from execution plan |
| `/fix-review-issues` | Auto-fix review findings in same commit |
| `/update-stack-config` | Update lint/test based on detected stack |
| `/detect-stack` | Auto-detect languages/frameworks in use |

---

## Day-to-Day Usage

### GitFlow Branching Workflow

This template uses a simplified branching model:

| Branch | Purpose | Review Triggered |
|--------|---------|------------------|
| `main` | Production-ready code | Gemini Code Assist (via GitHub App) |
| `feature/*` | Feature development branches | None (pre-push hook) |

### Creating a Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/my-change
```

**Note**: Always branch from `main`.

### Implementing Changes

Use opencode to:
- Generate code
- Refactor
- Add tests
- Update documentation

The Builder agent (GLM-4.7) will:
1. Write clean, tested code
2. Run linting automatically
3. Run tests automatically
4. Follow Stack Evolution rules

### Committing

```bash
git add -A
git commit -m "Implement X"
```

If linting fails, commit is blocked—fix linting and retry.

### Pushing (Automated Review & Auto-Fix)

```bash
git push -u origin feature/my-change
```

The pre-push hook will:
1. Run tests
2. Run linting
3. Ensure code quality standards

**Note**: Code reviews are handled via Gemini Code Assist GitHub app after PR creation.

### Creating Pull Requests

```bash
gh pr create --base main --title "My feature" --body "Description"
```

**Workflow for PRs to `main`**:
1. Create PR from feature branch to `main`
2. Comment `/gemini review` on the PR to trigger Gemini Code Assist review
3. Review will complete within 5-15 minutes
4. **If issues are found**:
   - Use `/skill fix-review-issues` to automatically fix Security, Critical, High, and Medium priority issues
   - Low priority issues will be automatically converted to GitHub issues
   - Push fixes to update the PR
   - Comment `/gemini review` again for updated review
5. **If Gemini Code Assist fails** (usage limits, errors, unresponsive):
   - Address critical issues manually before merging
6. Merge the PR to `main` once all critical issues are resolved

---

## Stack Detection & Configuration

The template automatically detects your project stack and configures linting and testing accordingly.

### Auto-Detection

Detects languages/frameworks from:
- `package.json` / `tsconfig.json` → TypeScript/JavaScript
- `requirements.txt` / `pyproject.toml` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml` / `build.gradle` → Java/Kotlin
- `Gemfile` → Ruby
- `composer.json` → PHP

### Manual Override

Create `.opencode/config/stack.json`:

```json
{
  "languages": ["typescript", "python"],
  "frameworks": ["React", "FastAPI"],
  "manual_override": true
}
```

### Updating Configuration

After adding new dependencies or languages:

```bash
/detect-stack          # Re-detect stack
/update-stack-config    # Update lint/test scripts
```

---

## Files Structure

```
power_template/
├── .github/
│   └── workflows/
│       ├── ci.yml                    # CI pipeline
│       └── gemini-review.yml         # Gemini review on PR to development (legacy)
├── .githooks/
│   ├── pre-commit                    # Lint on commit
│   └── pre-push                     # Test on push
├── .git/
│   └── opencode                    # opencode configuration
├── .opencode/
│   ├── agents/                      # Agent definitions
│   ├── skills/                      # Skill definitions
│   ├── prompts/                     # Prompt templates
│   └── config/                     # Stack configuration
├── docs/
│   └── templates/                  # Document templates
├── scripts/
│   ├── check.sh                     # Run all checks
│   ├── lint.sh                     # Dynamic linting
│   └── test.sh                     # Dynamic testing
├── AGENTS.md                       # Agent documentation
├── SKILLS.md                       # Skill documentation
└── README.md                       # This file
```

---

## Environment Variables

### Required

| Variable | Purpose | Source |
|----------|---------|--------|
| `OPENROUTER_API_KEY` | Access GLM-4.7 and Gemini2.0 models | https://openrouter.ai/keys |
| `GEMINI_API_KEY` | Access Gemini for web search/reviews | https://ai.google.dev/ |
| `GITHUB_TOKEN` | Access GitHub API for repo/issues | https://github.com/settings/tokens |

### Optional

| Variable | Purpose | Default |
|----------|---------|----------|
| `BOOTSTRAP` | Skip hooks during initial setup | `0` |
| `BASE_BRANCH` | Base branch for diffing | `main` |

---

## Configuration Files

### `.git/opencode`
 Main opencode configuration with:
- Model configurations (GLM-4.5 Air, Gemini2.0, Gemini)
- Agent configurations
- Skill configurations
- Stack detection rules
- Default configuration is available in `opencode/default-config.json`

### `.opencode/config/stack.json`
Detected stack configuration:
```json
{
  "languages": ["typescript"],
  "frameworks": ["React"],
  "package_managers": ["npm"],
  "manual_override": false
}
```

### `.opencode/config/lint-test-commands.json`
Lint and test commands for each supported language.

### `.opencode/config/stack-detection.json`
Patterns for detecting languages and frameworks.

---

## Git Hooks

### Pre-Commit
- Runs `./scripts/lint.sh`
- Blocks commit if linting fails

### Pre-Push
- Runs `./scripts/test.sh`
- Ensures code quality before pushing
- No automatic review or auto-fix during pre-push

---

## Code Quality Workflow

### 1. Simplified Review Process
- **Builder Agent** (GLM-4.5 Air): Writes code and implements features
- **Gemini Code Assist**: Reviews PRs via GitHub App when triggered with "/gemini review"

### 2. Targeted Auto-Fix
Review findings are selectively fixed:
- Security, Critical, High, and Medium priority issues are automatically fixed
- Low priority issues are converted to GitHub issues
- Fixes are applied and PR is updated
- Review is re-triggered for verification

### 3. Clean Workflow
- Feature branch: Local development with linting and testing
- PR to main: Gemini Code Assist review on demand
- CI: Runs all checks in parallel
- Issues tracked in GitHub for low priority items

---

## Customizing for Your Stack

### Adding a New Language

1. Add to `.opencode/config/stack-detection.json`:
```json
{
  "language_files": [
    {
      "pattern": "yourfile.ext",
      "languages": ["your-language"],
      "package_manager": "your-manager"
    }
  ]
}
```

2. Add to `.opencode/config/lint-test-commands.json`:
```json
{
  "lint": {
    "your-language": {
      "commands": ["your-lint-command"],
      "install": ["install-command"]
    }
  },
  "test": {
    "your-language": {
      "commands": ["your-test-command"],
      "install": ["install-command"]
    }
  }
}
```

3. Update `scripts/lint.sh` and `scripts/test.sh` if needed

### Adding a New Agent

1. Create `.opencode/agents/your-agent.md`
2. Define purpose, model, responsibilities
3. Update `.git/opencode` configuration
4. Update `AGENTS.md` documentation

### Adding a New Skill

1. Create `.opencode/skills/your-skill.md`
2. Define workflow, usage, and configuration
3. Update `SKILLS.md` documentation

---

## Troubleshooting

### "OPENROUTER_API_KEY not found"
```bash
export OPENROUTER_API_KEY="your-key-here"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

### "GitHub authentication failed"
```bash
gh auth login
```

### "Pre-push hook blocked: P0 findings"
- Review the findings in `.reviews/`
- Fix issues manually if auto-fix failed
- Or override: `ALLOW_P0=1 git push`

### "No linter configured"
- Run `/detect-stack` to auto-detect
- Or manually run `/update-stack-config`

### "Scripts have syntax errors"
```bash
bash -n scripts/lint.sh
bash -n scripts/test.sh
```

---

## Best Practices

1. **Small Commits**: Work in small, reviewable steps
2. **Test Coverage**: Always write tests with code changes
3. **Follow Conventions**: Mimic existing code patterns
4. **Security First**: Never commit secrets, validate inputs
5. **Documentation**: Update docs when adding features
6. **Stack Evolution**: Follow stack evolution rules when adding new components

---

## Advanced Usage

### Parallel Execution
Execute tasks in parallel (for independent tasks):
```bash
/execute-plan --parallel
```

### Starting from Specific Task
```bash
/execute-plan --from-task TASK-005
```

### Dry Run
Show what would be executed:
```bash
/execute-plan --dry-run
```

### Manual Stack Configuration
```json
{
  "languages": ["typescript"],
  "frameworks": ["React", "Next.js"],
  "manual_override": true
}
```

---

## Contributing

This is a template repository. For improvements:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Push and create PR

---

## License

MIT License - feel free to use this template for your projects.

---

## Further info

- Check [AGENTS.md](AGENTS.md) for agent documentation
- Check [SKILLS.md](SKILLS.md) for skill documentation
