# Code Quality Guidelines

## Purpose
This document outlines the code quality standards and practices for the project. Code review is handled by the Gemini Code Assist GitHub app, not by internal agents.

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

## Code Review Process

### Using Gemini Code Assist
1. Create a pull request from your feature branch to `main`
2. Comment `/gemini review` on the PR to trigger the review
3. Address all feedback provided by Gemini Code Assist
4. Merge the PR once all critical, high priority and medium priority issues are resolved

### Review Criteria
Gemini Code Assist will review for:
- Security vulnerabilities
- Code correctness and logic errors
- Performance issues
- Architectural concerns
- Testing coverage
- Documentation completeness
- Code style and conventions

### Addressing Feedback
- **Critical Issues (P0)**: Must be fixed before merging
- **Important Issues (P1)**: Should be fixed before merging
- **Minor Issues (P2)**: Can be addressed in future iterations

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

## Commit Guidelines

### Commit Message Format
```
type(scope): description

[optional body]

Closes #ISSUE_NUMBER
```

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test-related changes
- `chore`: Build or process changes

### Best Practices
- Write clear, descriptive commit messages
- Keep commits focused on single changes
- Reference related issues in commit messages
- Avoid large, monolithic commits

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

## Troubleshooting

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