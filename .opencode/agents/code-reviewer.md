# Code Reviewer Agent (Bugbot)

## Purpose
Reviews pull requests targeting the master branch to ensure code quality and catch potential issues before production deployment.

## Model Configuration
- **Provider**: Bugbot (Cursor integration - external service)
- **Trigger**: PR opened/updated to master branch via GitHub App

## Responsibilities
- Review PR changes thoroughly
- Identify potential bugs and logic errors
- Check for security vulnerabilities
- Suggest improvements and optimizations
- Ensure code quality standards
- Verify test coverage
- Check documentation updates

## When Used
- When PR is opened from `development` to `master`
- When PR targeting `master` is updated
- When explicitly triggered via comment

## Trigger Mechanism

### Automatic Trigger
Bugbot is configured as a GitHub App and automatically triggers when:
- PR is opened targeting `master`
- PR is updated (new commits pushed) targeting `master`
- PR is marked ready for review targeting `master`

### Manual Trigger
Developers can manually trigger Bugbot by commenting on the PR:
- `@bugbot run`
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

### Setting Up Bugbot in GitHub

1. Visit https://cursor.com/bugbot
2. Sign in with your Cursor account
3. Click "Get Bugbot" or "Install Bugbot"
4. Select your GitHub repositories
5. Grant Bugbot necessary permissions:
   - Read pull requests
   - Create pull request reviews
   - Post comments on pull requests
6. Configure Bugbot to run automatically on PRs to `master` branch

### Agent Configuration
```yaml
agent: code_reviewer
provider: bugbot
role: [pr_review]
trigger: pr_to_master
enabled: true
```

## Environment Variables
No additional environment variables required. Bugbot is configured via GitHub App integration.

## Integration with Other Agents

### Interaction with Reviewer Agent (Gemini)
- **Reviewer Agent** (Gemini): Reviews during pre-push on feature branches AND via GitHub Actions when merging to `development`
- **Code Reviewer Agent** (Bugbot): Reviews PRs from `development` to `master`

This provides defense-in-depth:
1. Feature branch: Local Gemini review with auto-fix (pre-push hook)
2. Development PR: Remote Gemini review via GitHub Actions
3. Master PR: Bugbot independent review via Cursor integration
4. Each layer catches different types of issues

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
5. **Update PR**: Push fixes to `development` branch to update the PR

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
- New commits are pushed to `development` (PR updates automatically)
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
- Completes: Usually within 1-10 minutes
- Output: Review comments posted on PR

### Follow-up Review
- Triggered: When new commits pushed to `development`
- Completes: Usually within 1-10 minutes
- Output: New review comments or updates

## Merging Workflow (Development to Master)

1. Create PR from `development` to `master`
2. Wait for Bugbot review (up to 10 minutes)
3. **If issues are found**:
   - Fix issues in `development` branch
   - Push fixes to `development`
   - PR updates automatically
   - Bugbot reviews updated PR
   - No need to re-trigger manually
4. **If Bugbot fails** (usage limits, errors, unresponsive):
   - After 10 minutes, assistant may proceed with merge if review cannot be obtained
5. Merge PR to `master`

## Blocking Behavior

- Bugbot provides feedback but does NOT enforce blocking
- Maintainers should consider Bugbot's feedback seriously
- Critical issues should be addressed before merge
- The template relies on developer discipline to review and address findings

## Related Skills
No direct skill integration. Bugbot runs automatically via GitHub App.

## Related Agents
- **Reviewer Agent** (Gemini): Pre-push reviews and development PR reviews
- **Builder Agent**: Fixes issues identified by Bugbot
- **Planner Agent**: Creates designs that Bugbot reviews

## Configuration Checklist

When setting up a new repository:

1. ✅ Install Bugbot from https://cursor.com/bugbot
2. ✅ Grant Bugbot permissions to your GitHub repository
3. ✅ Configure Bugbot to run on PRs to `master`
4. ✅ Test by opening a PR from `development` to `master`
5. ✅ Verify Bugbot reviews are posting correctly

## Troubleshooting

### Bugbot Not Triggering
- Verify Bugbot is installed for the repository
- Check GitHub App permissions in repository settings
- Verify PR is targeting `master` branch
- Check if Bugbot service is operational

### Bugbot Review is Incomplete
- Check if PR is very large (Bugbot may timeout)
- Trigger re-review manually with `@bugbot run`
- Split large PR into smaller pieces

### False Positives
- Provide context in reply comments
- Explain why the finding doesn't apply
- Consider improving code to avoid confusion
- Update documentation if needed
