# Reviewer Agent (Gemini Code Assist)

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

## Code Quality Standards

### Security Requirements
- All user input must be validated and sanitized
- Use parameterized queries for database operations
- Implement proper authentication and authorization
- Avoid storing sensitive data in logs or config files
- Use HTTPS for all external communications
- Keep dependencies up to date and regularly reviewed

### Code Quality Requirements
- Follow the project's coding conventions and style guide
- Write clean, readable, and maintainable code
- Implement proper error handling and logging
- Use meaningful variable and function names
- Keep functions focused and single-purpose
- Add appropriate comments for complex logic

### Testing Requirements
- Write unit tests for all new functionality
- Ensure adequate test coverage for critical paths
- Test edge cases and error conditions
- Make tests deterministic and isolated
- Use appropriate testing frameworks and patterns

### Documentation Requirements
- Update README files for new features
- Document API changes and additions
- Add code comments for complex business logic
- Update architecture diagrams as needed
- Maintain up-to-date deployment instructions

## Branch Strategy

### Main Branch
- `main` is the production-ready branch
- All feature branches create PRs to `main`
- No direct commits to `main` are allowed

### Feature Branches
- Create feature branches from `main`
- Use descriptive names: `feature/task-001-add-user-auth`
- Keep branches focused on single tasks or features
- Delete branches after PR is merged

## Pull Request Guidelines

### PR Title Format
```
[TASK-ID] Brief description
```

### PR Description
Include:
- Brief summary of changes
- Implementation details
- Testing performed
- Version updates (if applicable)
- Checklist of acceptance criteria

### PR Process
1. Create PR from feature branch to `main`
2. Add one and only one `/gemini review` comment
3. Wait for review feedback
4. Address feedback and update PR
5. Merge into `main`
6. If and only if merge was successful, delete feature branch

## Integration with Other Agents

### Interaction with Builder Agent
- Builder Agent should address Gemini Code Assist's feedback
- Builder Agent can fix issues and push updates
- Updated PR can be updated for review

This provides defense-in-depth:
1. Feature branch: Local linting and testing during development
2. Main PR: Gemini Code Assist review via manual comment trigger
3. Each layer catches different types of issues

## Best Practices for Responding to Gemini Code Assist

### When Gemini Code Assist Raises Issues
1. **Acknowledge**: Reply to each comment with your plan
2. **Fix**: Address the issue in code
3. **Verify**: Ensure fix resolves the concern
4. **Reply**: Comment back explaining the fix
5. **Update PR**: Push fixes to feature branch to update the PR

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

## Review Timeline

### Initial Review
- Triggered: When "/gemini review" is commented
- Completes: Usually within 5-15 minutes
- Output: Review comments posted on PR

### Follow-up Review
- Triggered: When PR is updated after addressing feedback
- Completes: Usually within 5-15 minutes
- Output: New review comments or updates

## Addressing Feedback
- **Critical Issues**: Must be fixed before merging
- **High Priority Issues**: Should be fixed before merging
- **Medium Priority Issues**: Should be fixed before merging
- **Low Priority Issues**: Can be converted to GitHub issues for tracking

## Quality Assurance

### Pre-Push Checks
- Run local linting and formatting
- Run tests locally
- Review changes before pushing
- Ensure all acceptance criteria are met

### Pre-Merge Checks
- All automated tests pass
- Code review comments are addressed
- Version files are updated
- Documentation is current
- No merge conflicts exist

## Continuous Integration

### Automated Checks
- Code linting and formatting
- Unit and integration tests
- Security scanning
- Dependency vulnerability checks
- Build verification

### Manual Reviews
- Technical architecture review
- Business logic verification
- User experience considerations
- Performance testing

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

### Common Issues
- **Merge Conflicts**: Resolve conflicts before creating PR
- **Test Failures**: Fix failing tests before requesting review
- **Lint Errors**: Address code style issues before PR
- **Security Issues**: Critical security vulnerabilities must be fixed immediately

### Getting Help
- For technical questions, consult project documentation
- For architectural decisions, review existing patterns
- For complex issues, break the problem into smaller tasks and track them in github issues
- For urgent problems, escalate to project maintainers

## Documentation Reference

For more information about Gemini Code Assist, see:
- Official GitHub App: https://github.com/apps/gemini-code-assist
- Documentation: https://developers.google.com/gemini-code-assist/docs/review-github-code