---
name: Power Guardrails (Always)
---

Non-negotiable workflow rules:

- Work in small, reviewable steps. Prefer multiple small commits over one large commit.
- Never commit secrets. If a secret appears, stop and provide removal steps (rotate/revoke if necessary).
- When changing behavior, always add/adjust tests that would fail without the change.
- Prefer secure defaults: validate inputs, enforce authz boundaries, avoid logging sensitive data, avoid injection risks.
- After generating or modifying code, you MUST run:
  - ./scripts/lint.sh
  - ./scripts/test.sh
  Fix failures before finalizing the change.
- For significant design changes: create or update an ADR under docs/adr/.

