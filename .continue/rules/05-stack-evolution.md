---
name: Stack Evolution (Rules + Scripts)
---

Whenever new stack components are introduced (language, framework, runtime, infra tooling), you MUST do all of the following:

1) Rules hygiene
- Check whether relevant rules already exist in `.continue/rules/` (rendered from `.rules/`).
- If missing, use rules-cli to add the missing rule packs, then re-render:
  - `rules add <pack>`
  - `rules render continue`
- Prefer rule sources:
  - `gh:continuedev/awesome-rules`
  - packs from rules.so / rules registry where appropriate.

2) Enforcement scripts
- Update `./scripts/lint.sh` and `./scripts/test.sh` to include the correct linting, formatting, typechecking, and test commands for the introduced components.
- The scripts must:
  - exit non-zero on failure
  - be deterministic and runnable in CI
  - avoid interactive prompts
- If new tooling is required (linters/test runners), add install steps to README and ensure CI installs them.

3) CI parity
- Ensure `.github/workflows/ci.yml` installs the necessary toolchains and runs `./scripts/check.sh`.
- CI must match local enforcement.

4) Commit checkpoint
- Make a small, named commit after rules/scripts changes.

