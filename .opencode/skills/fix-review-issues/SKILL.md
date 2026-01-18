---
name: fix-review-issues
description: Automatically fix issues identified during code review by parsing findings and applying fixes
license: MIT
---

# fix-review-issues Skill

## Purpose
Automatically fix issues identified during code review by parsing findings and applying fixes.

## When to Use
- During pre-push hook (automatic)
- Manually after receiving review feedback
- Before creating PR
- After running manual review

## Workflow

### Phase 1: Load Review Findings

#### 1.1 Identify Review Source
Determine source of review findings:
- **Automatic**: Latest review from pre-push hook
- **Manual**: Specified review file
- **Inline**: Review findings provided as input

#### 1.2 Load Findings
Parse review findings into structured format:

```json
{
  "summary": "3-6 bullet points",
  "p0_findings": [
    {
      "file": "src/auth.ts",
      "line": 42,
      "description": "Missing input validation",
      "why_risky": "Allows injection attacks",
      "fix": "Add validation function"
    }
  ],
  "p1_findings": [
    {
      "file": "src/user.ts",
      "line": 15,
      "description": "Unused import",
      "why_risky": "Code bloat",
      "fix": "Remove unused import"
    }
  ],
  "p2_findings": [
    {
      "file": "src/api.ts",
      "line": 78,
      "description": "Missing comment",
      "why_risky": "Reduced readability",
      "fix": "Add JSDoc comment"
    }
  ],
  "missing_tests": [
    "Test for error path in login function",
    "Test for edge case in user creation"
  ]
}
```

### Phase 2: Validate Findings

#### 2.1 Check Files Exist
For each finding:
- Verify file exists
- Verify line number is valid
- Warn if file or line not found

#### 2.2 Sort by Severity
- P0 findings first (critical)
- P1 findings second (important)
- P2 findings third (minor)
- Missing tests last

### Phase 3: Fix Findings

#### 3.1 For Each Finding

##### A. Understand Issue
- Read code at specified location
- Understand the context
- Identify the root cause

##### B. Generate Fix
Use Builder Agent to generate fix:
- Apply minimal fix recommended in finding
- Ensure fix doesn't introduce new issues
- Consider similar issues in codebase

##### C. Apply Fix
- Modify code at specified location
- Make minimal, targeted changes
- Preserve existing functionality

##### D. Verify Fix
Run linting:
```bash
./scripts/lint.sh
```

If linting fails:
- Adjust fix to address lint issues
- Re-run linting
- Repeat until passes

##### E. Test Fix
Run tests:
```bash
./scripts/test.sh
```

If tests fail:
- Analyze test failures
- Adjust fix to pass tests
- Re-run tests
- Repeat until passes

##### F. Document Fix (if significant)
- Add comment explaining change
- Update related documentation
- Note in commit message

### Phase 4: Add Missing Tests

#### 4.1 For Each Missing Test
- Identify what test should cover
- Use Builder Agent to write test
- Ensure test is comprehensive
- Test passes before moving on

### Phase 5: Verification

#### 5.1 Re-run Review
After fixing all findings:
- Run review again on modified code
- Check if all findings are resolved
- Identify any new findings

#### 5.2 Report Results
Generate report of fixes applied:

```markdown
## Review Fix Summary

### Findings Fixed
✓ P0: 3/3 findings fixed
✓ P1: 5/5 findings fixed
✓ P2: 2/2 findings fixed
✓ Missing Tests: 2/2 tests added

### Details

**P0-001: Missing input validation (src/auth.ts:42)**
- Fixed: Added validation function
- Verified: Linting and tests passing

**P0-002: SQL injection vulnerability (src/db.ts:78)**
- Fixed: Parameterized query
- Verified: Linting and tests passing

**P0-003: Missing error handling (src/api.ts:120)**
- Fixed: Added try-catch block
- Verified: Linting and tests passing

**P1-001: Unused import (src/user.ts:15)**
- Fixed: Removed unused import
- Verified: Linting passing

**P1-002: Inconsistent naming (src/auth.ts:56)**
- Fixed: Renamed to follow convention
- Verified: Linting passing

**P2-001: Missing comment (src/api.ts:78)**
- Fixed: Added JSDoc comment
- Verified: Linting passing

**Missing Tests:**
✓ Test for error path in login function
✓ Test for edge case in user creation

### Verification
✓ All findings resolved
✓ No new findings introduced
✓ All lint checks passing
✓ All tests passing
```

### Phase 6: Commit Changes

#### 6.1 Stage Changes
```bash
git add -A
```

#### 6.2 Create Commit
```bash
git commit --amend --no-edit
```

**Important**: Fixes are part of the same commit, not a new commit.

This is "auto-fix in same commit" behavior:
- Review findings are detected before commit is finalized
- Fixes are applied to same changeset
- Commit is amended to include fixes
- No separate fix commit is created

### Phase 7: Handle Remaining Issues

#### 7.1 If P0 Issues Remain
Check if P0 blocking is enabled:
```bash
if [ "${BLOCK_ON_P0:-1}" = "1" ]; then
  echo "P0 findings remain and cannot be fixed automatically"
  echo "Set ALLOW_P0=1 to override for this push"
  exit 1
fi
```

#### 7.2 Provide Manual Fix Guidance
For findings that couldn't be auto-fixed:
- Explain why it couldn't be auto-fixed
- Provide manual fix instructions
- Ask user to address manually

## Usage

```bash
/skill fix-review-issues
```

### With Specific Review File

```bash
/skill fix-review-issues .reviews/gemini-feature-branch-20260118-134500.md
```

### Override P0 Blocking

```bash
ALLOW_P0=1 /skill fix-review-issues
```

### Dry Run (Show What Would Be Fixed)

```bash
/skill fix-review-issues --dry-run
```

## Required Environment Variables
None required (uses configuration from .git/opencode)

## Optional Environment Variables

- `ALLOW_P0`: Set to "1" to override P0 blocking
- `BLOCK_ON_P0`: Set to "0" to disable P0 blocking
- `REVIEW_FILE`: Path to review findings file (optional)
- `MAX_FIX_ATTEMPTS`: Maximum attempts per finding (default: 3)

## Required Agents

- `builder`: Generates and applies fixes

## Review Format Expected

The skill expects review findings in this format:

```markdown
## Summary
- Bullet point 1
- Bullet point 2
- Bullet point 3

## P0 Findings (Critical)
- [file:line] Description
  - Why risky
  - Minimal fix

## P1 Findings (Important)
- [file:line] Description
  - Why risky
  - Minimal fix

## P2 Findings (Minor)
- [file:line] Description
  - Why risky
  - Minimal fix

## Missing Tests
- Test case 1
- Test case 2
```

## Error Handling

### File Not Found
```
Error: Review file not found: .reviews/gemini-feature-branch-20260118-134500.md
```

### Invalid Review Format
```
Error: Invalid review format. Expected:
  ## P0 Findings (Critical)
  ## P1 Findings (Important)
  ## P2 Findings (Minor)
  ## Missing Tests
```

### Cannot Auto-Fix
```
Warning: P0-001 cannot be fixed automatically
  Reason: Requires manual security review
  Location: src/auth.ts:42
  
Please fix this manually before pushing.
```

### Fix Failed Repeatedly
```
Error: Failed to fix P0-002 after 3 attempts
  Last error: [error message]
  
Please fix this manually.
```

### Linting Failed After Fix
```
Error: Fix introduced linting issues
  File: src/auth.ts:45
  Issue: [lint error]
  
Please adjust fix to address linting issues.
```

### Tests Failed After Fix
```
Error: Fix broke existing tests
  Failed tests: [test names]
  
Please adjust fix to pass tests.
```

## Success Criteria

1. ✅ All findings loaded and parsed successfully
2. ✅ P0 findings fixed (or guidance provided for manual fixes)
3. ✅ P1 findings fixed (or guidance provided for manual fixes)
4. ✅ P2 findings fixed (optional, can be skipped)
5. ✅ Missing tests added (optional but recommended)
6. ✅ All lint checks pass after fixes
7. ✅ All tests pass after fixes
8. ✅ Changes committed to same commit (not new commit)

## Example Session

```bash
$ /skill fix-review-issues

[Load Findings]
✓ Loaded 8 findings from review

[Analyze Findings]
P0: 3 findings (critical)
P1: 4 findings (important)
P2: 1 finding (minor)
Missing Tests: 2 tests

[Fixing Findings]

Fixing P0-001: Missing input validation (src/auth.ts:42)
  Understanding issue...
  Generating fix...
  Applying fix...
  Running linting... ✓
  Running tests... ✓
  ✓ Fixed

Fixing P0-002: SQL injection vulnerability (src/db.ts:78)
  Understanding issue...
  Generating fix...
  Applying fix...
  Running linting... ✓
  Running tests... ✓
  ✓ Fixed

[... continuing through all findings ...]

[Verification]
Re-running review...
✓ No new findings introduced

[Commit]
Staging changes...
Amending commit...
✓ Changes committed to same commit

[Summary]
✓ All 8 findings fixed
✓ 2 missing tests added
✓ All lint checks passing
✓ All tests passing

Ready to push!
```

## Troubleshooting

### "Cannot find line number in file"
- File may have changed since review
- Try re-running review
- Fix manually with correct line number

### "Fix broke existing functionality"
- Review fix manually
- Adjust to preserve existing behavior
- Add tests to prevent regression

### "Too many findings to fix"
- Consider fixing in batches
- Address P0 findings first
- Can push with P1/P2 findings if acceptable

### "Circular dependency introduced"
- Review changes
- Refactor to remove circular dependency
- Consider design changes
