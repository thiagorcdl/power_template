# Power Template

A framework-agnostic project template that approximates a “guardrails + agent” workflow (in the spirit of Claude Code + claudekit) using:

- **Continue** (IDE + CLI) as the agent interface
- **Ollama Cloud** model **GLM-4.7** (`glm-4.7:cloud`) for implementation
- **Gemini** as a second model for **feature-branch reviews**
- **Cursor Bugbot** for PR-only reviews **into `master`**
- Deterministic enforcement via **git hooks**, `scripts/lint.sh`, `scripts/test.sh`, and CI

This repo is meant to be used as a **GitHub Template Repository**.

---

## What this template enforces

- **Commit-time linting** (pre-commit hook runs `./scripts/lint.sh`)
- **Push-time tests + Gemini review** on feature branches (pre-push runs `./scripts/test.sh` and `./scripts/gemini_review.sh`)
- **CI parity**: GitHub Actions runs `./scripts/check.sh`
- **Bugbot only on PRs targeting `master`** (workflow posts `bugbot run` comment)

**Important:** `scripts/lint.sh` and `scripts/test.sh` are *scaffolds* until you decide the stack. You are expected to use the AI assistant to populate them once you choose languages/frameworks.

---

## 1) Install on Debian-based Linux (one-time per machine)

### 1.1 Base packages

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates gnupg build-essential
```

### 1.2 GitHub CLI (`gh`)

```bash
type -p curl >/dev/null || sudo apt-get install -y curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

sudo apt-get update
sudo apt-get install -y gh
```

Authenticate:

```bash
gh auth login
```

### 1.3 Node.js LTS (pin: v24.13.0)

This template expects Node 24 LTS for `cn` and `rules-cli`. Use `nvm` so you can pin versions cleanly:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Restart your shell, then:
nvm install 24.13.0
nvm use 24.13.0
node -v
npm -v
```

### 1.4 Continue

Install Continue CLI:

```bash
npm i -g @continuedev/cli
cn --help
```

### 1.5 rules-cli

```bash
npm i -g rules-cli
rules --help
```

### 1.6 Ollama + Ollama Cloud sign-in

Install Ollama:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Sign in (required for cloud models):

```bash
ollama signin
```

Pull GLM-4.7 cloud model:

```bash
ollama pull glm-4.7:cloud
```

### 1.7 Gemini API key

Export your key (put this in `~/.bashrc` or `~/.zshrc` if you want it persistent):

```bash
export GEMINI_API_KEY="YOUR_KEY_HERE"
```

---

## 2) Configure Continue models (one-time per machine)

Create/update:

- `~/.continue/config.yaml`

```yaml
name: power_template - local config
version: 0.0.1
schema: v1

models:
  - name: GLM-4.7 Builder (Ollama Cloud)
    provider: ollama
    model: glm-4.7:cloud
    roles: [chat, edit, apply]
    defaultCompletionOptions:
      maxTokens: 3000

  - name: Gemini Reviewer
    provider: gemini
    model: gemini-2.0-flash
    apiKey: ${GEMINI_API_KEY}
    roles: [chat, edit]
```

Sanity check (optional):

```bash
ollama run glm-4.7:cloud "Say hello"
```

---

## 3) Create a new project repo from this template (recommended workflow)

This creates the GitHub repo AND clones it locally:

```bash
gh repo create my-new-project \
  --template thiagorcdl/power_template \
  --private \
  --clone

cd my-new-project
```

If you prefer public:

```bash
gh repo create my-new-project --template thiagorcdl/power_template --public --clone
cd my-new-project
```

### 3.1 Ensure hooks are enabled (required)

The template stores hooks under `.githooks/`. Activate them:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/* scripts/*.sh
```

---

## 4) First-time project setup (the “stack decision” step)

### 4.1 System design discussion in Continue (GLM-4.7 Builder)

Open the repo in VS Code:

```bash
cn --config ~/.continue/config.yaml
```

In Continue chat, start with a design prompt. Example:

> We are building: (brief problem statement).  
> Constraints: (latency, scale, cost, security, data).  
> Please propose 2–3 architectures, pick one, define boundaries, data model, failure modes, security, and an initial implementation plan.

### 4.2 Lock the stack and tooling (your decision)

Once you decide on a stack, ask the assistant to crate an implementation plan, and to apply the template’s “Stack Evolution” rule. Example prompt:

> We chose: TypeScript + Node + Express + Postgres + Vitest.  
> Start implementing a minimum skeleton of the project, ensuring components are added incrementally and make sure to follow **Stack Evolution** rule.

### 4.3 Verify the scripts are now real (not scaffolds)

After the assistant updates scripts, you should be able to run:

```bash
./scripts/lint.sh
./scripts/test.sh
./scripts/check.sh
```

If any still prints “no linter configured” or “no test runner configured”, the stack-evolution step wasn’t completed.

---

## 5) Day-to-day usage

### 5.1 Create a feature branch

```bash
git checkout -b feature/my-change
```

### 5.2 Implement with GLM-4.7 (Continue)

Use Continue to:
- generate code
- refactor
- add tests
- update docs/ADR when needed

### 5.3 Commit (lint runs automatically)

```bash
git add -A
git commit -m "Implement X"
```

If lint fails, the commit is blocked—fix lint and retry.

### 5.4 Push (tests + Gemini review runs on feature branches)

```bash
git push -u origin feature/my-change
```

- If tests fail: push is blocked
- Gemini review output is written under `.reviews/`

If Gemini flags a P0 and gating is enabled, push may be blocked until resolved (or overridden if your repo allows).

### 5.5 PR into `master` triggers Bugbot

Open a PR from your feature branch into `master`. The workflow will comment `bugbot run` automatically, and Bugbot will review the PR.

---

## 6) Bugbot setup (per-project repo)

1) In Cursor settings, connect GitHub and enable Bugbot for the repo  
2) Configure Bugbot to **run only when mentioned** (so it won’t comment everywhere)  
3) Ensure this repo’s workflow `.github/workflows/bugbot-master-only.yml` exists (it posts `bugbot run` only for PRs targeting `master`)

### Important GitHub auth note (workflow push failures)

If you push over HTTPS using a token without `workflow` scope, GitHub can reject updates to `.github/workflows/*`.

Recommended solution: use SSH for your remote:

```bash
git remote set-url origin git@github.com:YOUR_GITHUB_USER/my-new-project.git
```

---

## 7) GLM-4.7 + Gemini “two-model” philosophy

- **GLM-4.7** (builder) writes code and implements the plan  
- **Gemini** (reviewer) checks diffs on feature branches and highlights:
  - security risks
  - correctness issues
  - missing tests
  - architecture regressions
- **Bugbot** reviews PRs into `master` as an additional independent layer  

This is defense-in-depth: implement with one model, review with another, then review again at merge time.

---

## 8) Template maintenance notes

- Rules are managed with `rules-cli`. If you add new rule packs:

```bash
rules add <pack>
rules render continue
git add -A
git commit -m "Add rules for <pack>"
```

- Always keep CI in sync with local scripts. CI must run `./scripts/check.sh`.

---

## 9) Minimal example walkthrough

1) Create repo from template:

```bash
gh repo create demo-service --template thiagorcdl/power_template --private --clone
cd demo-service
git config core.hooksPath .githooks
chmod +x .githooks/* scripts/*.sh
code .
```

2) In Continue:
- discuss architecture
- decide stack (e.g., Python + FastAPI + Postgres + pytest + ruff)
- ask assistant to apply Stack Evolution

3) Verify:

```bash
./scripts/check.sh
```

4) Feature branch work:

```bash
git checkout -b feature/hello
# implement + tests
git add -A
git commit -m "Add hello endpoint"
git push -u origin feature/hello
```

5) PR into master --> Bugbot runs.
