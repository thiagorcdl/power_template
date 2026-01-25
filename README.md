# Power Template

A framework-agnostic AI-assisted software development template that uses:

- **opencode** as the AI assistant framework
- **OpenRouter** with **GLM-4.7** (primary) and **Gemini2.0** (fallback) for planning and building
- **Gemini** for web searching and code reviews
- **Bugbot** for PR reviews targeting `master` branch
- Domain-specific agents for specialized tasks
- Git hooks for automated quality checks
- **GitFlow branching**: `master` (production), `development` (staging), `feature/*` (work)

This repo is meant to be used as a **GitHub Template Repository**.

---

## What This Template Enforces

- **GitFlow branching model** with `master`, `development`, and `feature/*` branches
- **Commit-time linting** (pre-commit hook runs `./scripts/lint.sh`)
- **Push-time tests + review** on feature branches (pre-push runs `./scripts/test.sh` and automated review with auto-fix)
- **CI parity**: GitHub Actions runs `./scripts/check.sh`
- **Gemini review** on merge to `development` (via GitHub Actions)
- **Bugbot review** on merge to `master` (via Cursor integration)
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

#### Configure Cursor's Bugbot

1. Go to https://cursor.com/bugbot
2. Sign in with your Cursor account
3. Click "Get Bugbot" or "Install Bugbot"
4. Select your GitHub repositories where you want to use Bugbot
5. Grant Bugbot the necessary permissions:
   - Read pull requests
   - Create pull request reviews
   - Post comments on pull requests
6. Configure Bugbot settings:
   - Set to run on all PRs to `master` branch
   - Enable automatic triggering on PR creation/update
7. Test the installation by opening a PR to `master` (Bugbot should review it)

#### Configure Google's Gemini Code Reviewer

1. Go to GitHub Marketplace: https://github.com/marketplace/actions/gemini-ai-code-reviewer
2. Click "Use latest version"
3. Select your GitHub repository
4. Add the required GitHub Action secrets:
   ```bash
   gh secret set GEMINI_API_KEY -b "your-gemini-api-key"
   ```
5. The workflow `.github/workflows/gemini-review.yml` will be added automatically
6. Configure the workflow to trigger on PRs targeting `development` branch:
   ```yaml
   on:
     pull_request:
       branches: [development]
   ```

**Note**: If you prefer using a different Gemini code reviewer, check the GitHub Marketplace for options like:
- `gemini-ai-code-reviewer` (truongnh1992)
- `code-review-by-gemini-ai`

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
| **Reviewer** | Reviews code changes, identifies issues | Gemini 2.0 Flash |
| **Web Searcher** | Finds documentation, examples, best practices | Gemini 2.0 Flash |
| **Code Reviewer** | Reviews PRs to master | Bugbot |

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

This template uses a GitFlow branching model:

| Branch | Purpose | Review Triggered |
|--------|---------|------------------|
| `master` | Production-ready code | Bugbot (via Cursor) |
| `development` | Integration/staging branch | Gemini (via GitHub Actions) |
| `feature/*` | Feature development branches | None (pre-push hook) |

### Creating a Feature Branch

```bash
git checkout development
git pull origin development
git checkout -b feature/my-change
```

**Note**: Always branch from `development`, not `master`.

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
2. Get diff from development
3. Request review from Reviewer agent (Gemini)
4. **Automatically fix findings** using Builder agent
5. Commit fixes to the same commit (amend)
6. Block push if P0 issues remain (unless `ALLOW_P0=1`)

**Override P0 blocking** (if needed):
```bash
ALLOW_P0=1 git push
```

### Merging Feature to Development

```bash
gh pr create --base development --title "My feature" --body "Description"
```

**Workflow when merging to `development`**:
1. Create PR from feature branch to `development`
2. Wait for **Gemini code review** (GitHub Action triggers automatically)
3. Review will complete within 10 minutes
4. **If issues are found**:
   - Fix the issues locally
   - Push fixes to the same branch
   - Gemini will review the updated PR automatically
   - No need to re-trigger Gemini manually
5. **If Gemini fails** (usage limits, errors, unresponsive):
   - The assistant may merge after 10 minutes if no review is received
6. Merge the PR to `development`

### Merging Development to Master

```bash
gh pr create --base master --head development --title "Release vX.X.X" --body "Release notes"
```

**Workflow when merging to `master`**:
1. Create PR from `development` to `master`
2. Wait for **Bugbot review** (Cursor integration triggers automatically)
3. Review will complete within 10 minutes
4. **If issues are found**:
   - Fix the issues in the `development` branch
   - Push fixes to `development`
   - The PR will update automatically
   - Bugbot will review the updated PR
5. **If Bugbot fails** (usage limits, errors, unresponsive):
   - The assistant may merge after 10 minutes if no review is received
6. Merge the PR to `master`

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
│       └── gemini-review.yml         # Gemini review on PR to development
├── .githooks/
│   ├── pre-commit                    # Lint on commit
│   └── pre-push                     # Test + review on push
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
| `ALLOW_P0` | Override P0 blocking on push | `0` |
| `BOOTSTRAP` | Skip hooks during initial setup | `0` |
| `BASE_BRANCH` | Base branch for diffing | `development` |

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
- Gets diff from base branch
- Requests review from Reviewer agent (Gemini)
- **Automatically fixes findings** using Builder agent
- Amends commit with fixes
- Blocks push if P0 issues remain (unless overridden)

---

## Code Quality Workflow

### 1. Two-Model System
- **Builder Agent** (GLM-4.5 Air): Writes code and implements features
- **Reviewer Agent** (Gemini): Reviews code during pre-push and via GitHub Actions
- **Code Reviewer Agent** (Bugbot): Reviews PRs from development to master

### 2. Auto-Fix on Push
Review findings are automatically fixed:
- P0, P1, P2 findings are all addressed
- Fixes are applied to the same commit (amend)
- No separate fix commit is created
- Push only blocks if P0 issues can't be fixed

### 3. Defense in Depth
- Feature branch: Local Gemini review with auto-fix during pre-push
- PR to development: Remote Gemini review via GitHub Actions
- PR to master: Bugbot review for final production check
- CI: Runs all checks in parallel

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
