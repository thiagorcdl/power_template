#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-master}"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [ "$BRANCH" = "$BASE_BRANCH" ]; then
  echo "[gemini-review] on $BASE_BRANCH; skipping."
  exit 0
fi

mkdir -p .reviews

DIFF="$(git diff "$BASE_BRANCH"...HEAD)"
if [ -z "$DIFF" ]; then
  echo "[gemini-review] no diff vs $BASE_BRANCH; skipping."
  exit 0
fi

{
  cat .ai/prompts/gemini_review.txt
  echo
  echo "DIFF:"
  echo "$DIFF"
} | cn --config .ai/cn.gemini.yaml -p > ".reviews/gemini-${BRANCH}-$(date +%Y%m%d-%H%M%S).md"

echo "[gemini-review] wrote review to .reviews/"

# Optional gating: block push on P0 findings unless explicitly overridden
LATEST_REVIEW="$(ls -t .reviews/gemini-${BRANCH}-*.md | head -n 1 || true)"
if [ -n "${LATEST_REVIEW}" ] && grep -q "^P0" "${LATEST_REVIEW}"; then
  echo "[gemini-review] P0 findings detected; blocking push." >&2
  echo "Set ALLOW_P0=1 to override for this push." >&2
  if [ "${ALLOW_P0:-0}" != "1" ]; then
    exit 1
  fi
fi

