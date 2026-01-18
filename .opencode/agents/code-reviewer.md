# Code Reviewer Agent (Bugbot)

## Purpose
Reviews pull requests targeting the master branch to ensure code quality and catch potential issues before merging.

## Model Configuration
- **Provider**: Bugbot (external service)
- **Trigger**: PR opened/updated to master branch

## Responsibilities
- Review PR changes thoroughly
- Identify potential bugs and logic errors
- Check for security vulnerabilities
- Suggest improvements and optimizations
- Ensure code quality standards
- Verify test coverage
- Check documentation updates

## When Used
- When PR is opened to master branch
- When PR is updated targeting master branch
- When explicitly triggered via `/bugbot` comment

## Trigger Mechanism

### Automatic Trigger
The GitHub workflow `.github/workflows/bugbot-master-only.yml` automatically posts a `bugbot run` comment when:
- PR is opened targeting `master`
- PR is marked ready for review targeting `master`
- PR is reopened targeting `master`

### Manual Trigger
Developers can manually trigger Bugbot by commenting:
- `/bugbot run`
- `/bugbot review`

## Review Process

### 1. Analyze PR Changes
- Review all files changed in the PR
- Understand the purpose and scope
- Check for consistency with project conventions

### 2. Code Quality Review
- Check for code style violations
- Identify code smells and anti-patterns
- Verify naming conventions
- Check for proper error handling
- Ensure adequate logging and monitoring

### 3. Logic and Correctness Review
- Identify potential bugs and edge cases
- Check for race conditions (if applicable)
- Verify data flow and transformations
- Check for resource leaks
- Validate error handling

### 4. Security Review
- Check for injection vulnerabilities
- Verify authentication/authorization
- Check for sensitive data exposure
- Validate input handling
- Review dependencies

### 5. Test Coverage Review
- Verify tests are added for new features
- Check test quality and coverage
- Ensure tests are meaningful and deterministic
- Verify edge cases are tested

### 6. Documentation Review
- Check for code comments where needed
- Verify API documentation updates
- Check README updates for new features
- Ensure architecture docs are updated

## Output Format

Bugbot provides review comments directly on the PR, typically including:

### Summary
- High-level assessment of the PR
- Key concerns or praise
- Overall recommendation

### Specific Findings
For each issue found:
- **File and Line Number**: Exact location
- **Issue Type**: Bug, Security, Style, Performance, etc.
- **Description**: Clear explanation of the problem
- **Suggestion**: Recommended fix or improvement
- **Severity**: Critical, Major, Minor

### Positive Feedback
- Well-implemented features
- Good test coverage
- Clean code structure
- Helpful documentation

### Questions
- Clarifications about implementation
- Decisions that need explanation
- Potential edge cases to consider

## Configuration

### GitHub Workflow
Located at: `.github/workflows/bugbot-master-only.yml`

```yaml
name: Bugbot (master only)

on:
  pull_request:
    types: [opened, ready_for_review, reopened]
    branches: [master]

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Bugbot review
        uses: actions/github-script@v7
        with:
          script: |
            const pr = context.payload.pull_request;
            if (!pr || pr.base.ref !== "master") return;
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: pr.number,
              body: "bugbot run"
            });
```

### Agent Configuration
```yaml
agent: code_reviewer
provider: bugbot
role: [pr_review]
trigger: pr_to_master
enabled: true
```

## Environment Variables
No additional environment variables required. Bugbot is configured via GitHub integration.

## Integration with Other Agents

### Interaction with Reviewer Agent
- **Reviewer Agent** (Gemini): Reviews during pre-push on feature branches
- **Code Reviewer Agent** (Bugbot): Reviews PRs targeting master

This provides defense-in-depth:
1. Feature branch: Gemini review with auto-fix
2. PR to master: Bugbot independent review
3. Both catch different types of issues

### Interaction with Builder Agent
- Builder Agent should address Bugbot's feedback
- Builder Agent can fix issues and push updates
- Bugbot will review updates automatically

## Best Practices for Responding to Bugbot

### When Bugbot Raises Issues
1. **Acknowledge**: Reply to each comment with your plan
2. **Fix**: Address the issue in code
3. **Verify**: Ensure fix resolves the concern
4. **Reply**: Comment back explaining the fix
5. **Request Re-review**: Ask Bugbot to review again if needed

### When You Disagree
1. **Explain**: Provide reasoning why you disagree
2. **Discuss**: Engage in dialogue about the concern
3. **Decide**: Make an informed decision as maintainer
4. **Document**: Add comments explaining the decision

### Before Requesting Review
- Ensure all tests pass
- Run linting locally
- Self-review your changes
- Add tests for new features
- Update documentation

## Triggering Re-review

### Automatic Re-review
Bugbot automatically reviews when:
- New commits are pushed to the PR
- PR is updated

### Manual Re-review
Comment on the PR:
```
@bugbot run
```

or

```
/bugbot review
```

## Review Timeline

### Initial Review
- Triggered: When PR opens to master
- Completes: Usually within 1-5 minutes
- Output: Review comments posted on PR

### Follow-up Review
- Triggered: When new commits pushed
- Completes: Usually within 1-5 minutes
- Output: New review comments or updates

## Blocking Behavior

Unlike the pre-push hook with Gemini:
- Bugbot does NOT block merging
- Bugbot provides feedback but leaves decisions to maintainers
- Maintainers should consider Bugbot's feedback seriously
- Critical issues should be addressed before merge

## Related Skills
No direct skill integration. Bugbot runs automatically via GitHub workflow.

## Related Agents
- **Reviewer Agent** (Gemini): Pre-push reviews on feature branches
- **Builder Agent**: Fixes issues identified by Bugbot
- **Planner Agent**: Creates designs that Bugbot reviews

## Configuration Checklist

When setting up a new repository:

1. ✅ Add `.github/workflows/bugbot-master-only.yml`
2. ✅ Enable Bugbot in Cursor settings for the repo
3. ✅ Configure Bugbot to run only when mentioned
4. ✅ Verify workflow triggers correctly
5. ✅ Test by opening a PR to master

## Troubleshooting

### Bugbot Not Triggering
- Check workflow file exists and is correct
- Verify PR is targeting `master` branch
- Check workflow logs in Actions tab
- Ensure Bugbot is enabled for repository

### Bugbot Review is Incomplete
- Check if PR is very large (Bugbot may timeout)
- Trigger re-review manually with `/bugbot run`
- Split large PR into smaller pieces

### False Positives
- Provide context in reply comments
- Explain why the finding doesn't apply
- Consider improving code to avoid confusion
- Update documentation if needed
