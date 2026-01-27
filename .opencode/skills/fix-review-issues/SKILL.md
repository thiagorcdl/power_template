---
name: fix-review-issues
description: Automatically fix issues identified during code review by parsing findings and applying fixes
license: MIT
---

# fix-review-issues Skill

## Purpose
Automatically fix issues identified during code review by parsing findings from Gemini Code Assist and applying fixes.

## When to Use
- Manually after receiving review feedback from Gemini Code Assist
- Before updating PR with fixes
- After commenting "/gemini review" and getting feedback

## Workflow

### Phase 1: Load Review Findings

#### 1.1 Identify Review Source
Determine source of review findings:
- **PR Review**: Review findings from Gemini Code Assist on GitHub PR
- **Manual**: Specified review file
- **Inline**: Review findings provided as input

#### 1.2 Fetch PR Comments
Get comments from the GitHub PR:
```bash
gh pr view $PR_NUMBER --json comments --jq '.comments[].body'
```

#### 1.3 Parse Review Comments
Process comments to extract findings:
1. **Ignore the first comment** from gemini-code-assist that starts with "Summary of Changes" (that's just Gemini claiming it will review)
2. **Look for comment** from gemini-code-assist starting with "Code Review"
3. **Extract findings** from the "Code Review" comment

#### 1.4 Classify Findings by Priority
Categorize findings based on priority:
- **Security**: All security-related issues
- **Critical**: Critical issues that must be fixed
- **High Priority**: High priority issues
- **Medium Priority**: Medium priority issues  
- **Low Priority**: Low priority issues (create GitHub issues for these)

```json
{
  "summary": "3-6 bullet points",
  "security_findings": [
    {
      "file": "src/auth.ts",
      "line": 42,
      "description": "Missing input validation",
      "priority": "Critical",
      "fix": "Add validation function"
    }
  ],
  "critical_findings": [
    {
      "file": "src/user.ts", 
      "line": 15,
      "description": "Null pointer dereference",
      "priority": "Critical",
      "fix": "Add null check"
    }
  ],
  "high_priority_findings": [
    {
      "file": "src/api.ts",
      "line": 78,
      "description": "Resource leak",
      "priority": "High",
      "fix": "Close resource in finally block"
    }
  ],
  "medium_priority_findings": [
    {
      "file": "src/utils.ts",
      "line": 23,
      "description": "Inefficient algorithm",
      "priority": "Medium", 
      "fix": "Use more efficient data structure"
    }
  ],
  "low_priority_findings": [
    {
      "file": "src/docs.ts",
      "line": 12,
      "description": "Missing documentation",
      "priority": "Low",
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

#### 2.2 Sort by Priority
- Security findings first
- Critical findings second
- High priority findings third
- Medium priority findings fourth
- Low priority findings fifth (create GitHub issues)
- Missing tests last

### Phase 3: Fix Findings

#### 3.1 For Each Finding (Security, Critical, High, Medium Priority)

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

#### 3.2 Handle Low Priority Findings
For each low priority finding:
- Create GitHub issue with matching priority
- Link to the PR
- Skip fixing (create issue instead)

#### 3.3 Create GitHub Issues
```bash
for finding in "${low_priority_findings[@]}"; do
  gh issue create \
    --title "Low Priority Issue: ${finding['description']}" \
    --body "Found in PR #$PR_NUMBER

**File**: ${finding['file']}:${finding['line']}
**Priority**: ${finding['priority']}
**Description**: ${finding['description']}
**Fix**: ${finding['fix']}

Link to PR: #$PR_NUMBER"
done
```

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

### Findings Processed
✓ Security: 3/3 findings fixed
✓ Critical: 2/2 findings fixed
✓ High Priority: 4/4 findings fixed
✓ Medium Priority: 1/1 finding fixed
✓ Low Priority: 3/3 issues created as GitHub issues
✓ Missing Tests: 2/2 tests added

### Details

**Security-001: Missing input validation (src/auth.ts:42)**
- Fixed: Added validation function
- Verified: Linting and tests passing

**Security-002: SQL injection vulnerability (src/db.ts:78)**
- Fixed: Parameterized query
- Verified: Linting and tests passing

**Critical-001: Null pointer dereference (src/user.ts:15)**
- Fixed: Added null check
- Verified: Linting and tests passing

**Critical-002: Missing error handling (src/api.ts:120)**
- Fixed: Added try-catch block
- Verified: Linting and tests passing

**High Priority-001: Resource leak (src/api.ts:45)**
- Fixed: Close resource in finally block
- Verified: Linting and tests passing

**Medium Priority-001: Inefficient algorithm (src/utils.ts:23)**
- Fixed: Use more efficient data structure
- Verified: Linting and tests passing

**Low Priority Issues Created:**
✓ Issue #123: Missing documentation (src/docs.ts:12)
✓ Issue #124: Code style improvement (src/style.ts:67)
✓ Issue #125: Performance optimization (src/perf.ts:89)

**Missing Tests:**
✓ Test for error path in login function
✓ Test for edge case in user creation

### GitHub Issues Created
3 low priority issues created:
- #123: Missing documentation
- #124: Code style improvement  
- #125: Performance optimization

### Verification
✓ All security, critical, high, and medium priority findings fixed
✓ Low priority issues tracked as GitHub issues
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

### Phase 7: Update PR and Re-trigger Review

#### 7.1 Push Changes
```bash
git push origin feature/branch-name
```

#### 7.2 Update PR
If PR exists, push changes to update it:
```bash
# The PR will update automatically when changes are pushed
```

#### 7.3 Re-trigger Review
Comment on the PR to trigger another review:
```bash
gh pr comment $PR_NUMBER --body "/gemini review"
```

#### 7.4 Handle Critical Issues
For findings that couldn't be auto-fixed:
- If critical: Address manually before merging
- If non-critical: Create GitHub issue with matching priority and merge PR

## Usage

```bash
/skill fix-review-issues
```

### With Specific Review File

```bash
/skill fix-review-issues .reviews/gemini-pr-123-20260118-134500.md
```

### Dry Run (Show What Would Be Fixed)

```bash
/skill fix-review-issues --dry-run
```

## Required Environment Variables
None required (uses configuration from .git/opencode)

## Optional Environment Variables

- `REVIEW_FILE`: Path to review findings file (optional)
- `MAX_FIX_ATTEMPTS`: Maximum attempts per finding (default: 3)
- `PR_NUMBER`: GitHub PR number (optional, will auto-detect)

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
Error: Review file not found: .reviews/gemini-pr-123-20260118-134500.md
```

### Invalid Review Format
```
Error: Invalid review format. Expected:
  ## Summary
  ## Findings (may include severity levels)
  ## Missing Tests (if applicable)
```

### Cannot Auto-Fix
```
Warning: Issue cannot be fixed automatically
  Reason: Requires manual review or context
  Location: src/auth.ts:42
  
Please fix this manually and comment "/gemini review" again.
```

### Fix Failed Repeatedly
```
Error: Failed to fix issue after 3 attempts
  Last error: [error message]
  
Please fix this manually and comment "/gemini review" again.
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

1. ✅ All findings loaded and parsed successfully from PR comments
2. ✅ Security, Critical, High, and Medium priority findings fixed
3. ✅ Low priority findings converted to GitHub issues with matching priority
4. ✅ Missing tests added (optional but recommended)
5. ✅ All lint checks pass after fixes
6. ✅ All tests pass after fixes
7. ✅ PR updated with fixes
8. ✅ "/gemini review" re-triggered for updated review
9. ✅ GitHub issues created for low priority findings with proper links

## Example Session

```bash
$ /skill fix-review-issues

[Load Findings]
✓ Fetched PR comments from PR #123
✓ Identified "Code Review" comment from Gemini Code Assist
✓ Parsed 10 findings from review

[Analyze Findings]
Security: 2 findings (critical)
Critical: 2 findings (critical)
High Priority: 4 findings (high)
Medium Priority: 1 finding (medium)
Low Priority: 1 finding (low)
Missing Tests: 2 tests

[Fixing Findings]

Fixing Security-001: Missing input validation (src/auth.ts:42)
  Understanding issue...
  Generating fix...
  Applying fix...
  Running linting... ✓
  Running tests... ✓
  ✓ Fixed

Fixing Critical-001: Null pointer dereference (src/user.ts:15)
  Understanding issue...
  Generating fix...
  Applying fix...
  Running linting... ✓
  Running tests... ✓
  ✓ Fixed

[... continuing through security, critical, high, and medium findings ...]

[Creating GitHub Issues]
Created issue #126: Low Priority Issue: Missing documentation (src/docs.ts:12)
  - Priority: Low
  - Location: src/docs.ts:12
  - Description: Missing documentation
  - Link to PR: #123

[Verification]
Pushing changes to PR #123...
✓ PR updated with fixes

[Re-trigger Review]
Commenting "/gemini review" on PR #123...
✓ Review re-triggered

[Summary]
✓ Security, Critical, High, and Medium priority findings fixed (9 total)
✓ Low priority findings converted to GitHub issues (1 issue)
✓ 2 missing tests added
✓ All lint checks passing
✓ All tests passing
✓ PR updated and review re-triggered

Ready to proceed with development!
```

## Troubleshooting

### "Cannot find line number in file"
- File may have changed since review
- Try re-running review with "/gemini review"
- Fix manually with correct line number

### "Fix broke existing functionality"
- Review fix manually
- Adjust to preserve existing behavior
- Add tests to prevent regression
- Comment "/gemini review" to verify fix

### "Too many findings to fix"
- Consider fixing in batches
- Address critical findings first
- Can push with minor findings if acceptable
- Create GitHub issues for non-critical items

### "PR not found"
- Check if PR exists and is accessible
- Verify you're working on correct branch
- Create PR if it doesn't exist

### "No code review comment found"
- Check if "/gemini review" was commented on PR
- Verify Gemini Code Assist is installed for the repo
- Check PR comments for the "Code Review" comment from Gemini

### "Multiple code review comments"
- Use the most recent "Code Review" comment
- Ignore summary-only comments
- Process findings from the latest substantive review
