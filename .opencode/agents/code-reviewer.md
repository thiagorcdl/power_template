# Code Reviewer Agent (Gemini Code Assist)

## Purpose
Reviews pull requests targeting the main branch using the official Gemini Code Assist GitHub app to ensure code quality and catch potential issues before production deployment.

## Model Configuration
- **Provider**: Gemini Code Assist (Google's official GitHub App)
- **Trigger**: PR comment with "/gemini review" command

## Responsibilities
- Review PR changes thoroughly
- Identify potential bugs and logic errors
- Check for security vulnerabilities
- Suggest improvements and optimizations
- Ensure code quality standards
- Verify test coverage
- Check documentation updates

## When Used
- When PR is opened from feature branches to `main`
- When explicitly triggered via comment "/gemini review"
- After any PR updates (new commits pushed)

## Trigger Mechanism

### Automatic Trigger
The code review is triggered by commenting "/gemini review" on the PR.

### Manual Trigger
Developers can manually trigger Gemini Code Assist by commenting on the PR:
- `/gemini review`

## Setup Requirements

### 1. Repository Setup
The GitHub repository must exist before configuring Gemini Code Assist:
1. Create the repository on GitHub
2. Initialize the repository locally
3. Configure the repository structure

### 2. Gemini Code Assist Configuration
1. Visit https://github.com/apps/gemini-code-assist
2. Install the Gemini Code Assist app to your GitHub organization or personal account
3. Select the repository you want to use it with
4. Grant necessary permissions:
   - Read pull requests
   - Create pull request reviews
   - Post comments on pull requests

### 3. Agent Configuration
```yaml
agent: code_reviewer
provider: gemini_code_assist
role: [pr_review]
trigger: pr_comment
enabled: true
```

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

Gemini Code Assist provides review comments directly on the PR, typically including:

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

## Integration with Other Agents

### Interaction with Reviewer Agent (Gemini)
- **Code Quality Checks**: Local linting and testing during development
- **Code Reviewer Agent** (Gemini Code Assist): Reviews PRs from feature branches to `main` via manual comment trigger

This provides defense-in-depth:
1. Feature branch: Local Gemini review with auto-fix (pre-push hook)
2. Development PR: Remote Gemini review via GitHub Actions
3. Main PR: Gemini Code Assist review via manual comment trigger
4. Each layer catches different types of issues

### Interaction with Builder Agent
- Builder Agent should address Gemini Code Assist's feedback
- Builder Agent can fix issues and push updates
- Updated PR can be re-triggered for additional review

## Best Practices for Responding to Gemini Code Assist

### When Gemini Code Assist Raises Issues
1. **Acknowledge**: Reply to each comment with your plan
2. **Fix**: Address the issue in code
3. **Verify**: Ensure fix resolves the concern
4. **Reply**: Comment back explaining the fix
5. **Update PR**: Push fixes to feature branch to update the PR
6. **Re-trigger**: Comment "/gemini review" for updated review

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

### Manual Re-review
Comment on the PR:
```
/gemini review
```

## Review Timeline

### Initial Review
- Triggered: When "/gemini review" is commented
- Completes: Usually within 5-15 minutes
- Output: Review comments posted on PR

### Follow-up Review
- Triggered: When "/gemini review" is commented again after updates
- Completes: Usually within 5-15 minutes
- Output: New review comments or updates

## Merging Workflow (Feature Branch to Main)

1. Create PR from feature branch to `main`
2. Comment "/gemini review" on the PR
3. Wait for Gemini Code Assist review (up to 15 minutes)
4. **If issues are found**:
   - Fix issues in feature branch
   - Push fixes to feature branch
   - PR updates automatically
   - Comment "/gemini review" again for updated review
   - No need to manually re-trigger (just use the comment)
5. **If Gemini Code Assist fails** (usage limits, errors, unresponsive):
   - After 15 minutes, assistant may proceed with merge if review cannot be obtained
6. Merge PR to `main`

## Blocking Behavior

- Gemini Code Assist provides feedback but does NOT enforce blocking
- Maintainers should consider Gemini Code Assist's feedback seriously
- Critical issues should be addressed before merge
- The template relies on developer discipline to review and address findings

## Related Skills
No direct skill integration. Gemini Code Assist runs via GitHub App when manually triggered.

## Related Agents
- **Builder Agent**: Implements fixes based on review feedback
- **Builder Agent**: Fixes issues identified by Gemini Code Assist
- **Planner Agent**: Creates designs that Gemini Code Assist reviews

## Configuration Checklist

When setting up a new repository:

1. ✅ Create GitHub repository
2. ✅ Install Gemini Code Assist from https://github.com/apps/gemini-code-assist
3. ✅ Grant Gemini Code Assist permissions to your GitHub repository
4. ✅ Test by opening a PR from a feature branch to `main`
5. ✅ Comment "/gemini review" and verify reviews are posting correctly

## Troubleshooting

### Gemini Code Assist Not Triggering
- Verify Gemini Code Assist is installed for the repository
- Check GitHub App permissions in repository settings
- Verify the comment is exactly "/gemini review"
- Check if Gemini Code Assist service is operational

### Gemini Code Assist Review is Incomplete
- Check if PR is very large (may timeout)
- Trigger re-review manually with "/gemini review"
- Split large PR into smaller pieces

### False Positives
- Provide context in reply comments
- Explain why the finding doesn't apply
- Consider improving code to avoid confusion
- Update documentation if needed

## Documentation Reference

For more information about Gemini Code Assist, see:
- Official GitHub App: https://github.com/apps/gemini-code-assist
- Documentation: https://developers.google.com/gemini-code-assist/docs/review-github-code