---
name: execute-plan
description: Execute tasks from execution plan with feature branch workflow and PR creation
license: MIT
---

# execute-plan Skill

## Purpose
Execute tasks defined in the execution plan using feature branches and pull requests.

## When to Use
- After technical design is approved
- When ready to start implementation
- After manual updates to execution plan

## Workflow

### Phase 1: Load and Validate Plan

#### 1.1 Read Execution Plan
Load `docs/execution-plan.md` and parse:
- Task list with IDs, titles, descriptions, priorities
- Milestones and their tasks
- Acceptance criteria

#### 1.2 Verify Plan Structure
Validate that plan contains:
- At least one task
- All tasks have IDs, titles, descriptions
- Dependencies are valid (no circular dependencies)
- Acceptance criteria are defined

#### 1.3 Check GitHub Issues
Verify that GitHub issues exist for each task
- Issue numbers correspond to task IDs
- Issues have proper labels
- Issues are linked correctly

### Phase 2: Prepare for Execution

#### 2.1 Check Execution Mode
Ask user for execution preference:
```bash
Execution mode:
  1) Sequential (one task at a time, safer)
  2) Parallel (faster, for independent tasks)
  3) Interactive (ask before each task)

Select mode [1/2/3]:
```

#### 2.2 Prepare Branch Management
Ensure master is up to date:
```bash
git checkout master
git pull origin master
```

### Phase 3: Execute Tasks (Feature Branch Workflow)

#### 3.1 For Each Task

##### A. Create Feature Branch (One per Task)
IMPORTANT: Create a separate feature branch for EACH task to enable pull requests and incremental reviews:

```bash
# Ensure we start from master for each new task
git checkout master
git pull origin master

# Create feature branch for this specific task
git checkout -b feature/task-$TASK_ID
```

**Benefits of separate feature branches per task**:
- Each task gets its own pull request
- Enables parallel development of tasks
- Easier code reviews
- Cleaner git history
- Reduces merge conflicts

**Branch naming conventions**:
- `feature/task-$TASK_ID` - For individual tasks
- `feature/$TASK_ID-$SHORT_DESCRIPTION` - For descriptive names
- `feature/$MILESTONE` - For milestone-based work

##### B. Read Task Details
- Read from execution plan
- Read from GitHub issue
- Understand acceptance criteria

##### C. Implement Task
Use Builder Agent to implement:
1. Analyze requirements
2. Read current subsystem versions from their respective project directories
3. Implement code changes
4. Determine version increment based on changes:
   - Patch version (a.b.➕c) for bug fixes and small improvements
   - Minor version (a.➕b.c) for new features
   - Major version (➕a.b.c) for breaking changes (recommend to user)
5. Write appropriate tests
6. Update documentation if needed
7. Update subsystem versions:
   - Update version file in each subsystem directory (e.g., `package.json`, `pyproject.toml`, `version.json`)
   - Update `docs/versions.md` with version changes
   - Record task ID and commit SHA in commit message

##### D. Run Linting
```bash
./scripts/lint.sh
```

If linting fails:
- Builder Agent fixes issues
- Re-run linting
- Repeat until passes

##### E. Run Tests
```bash
./scripts/test.sh
```

If tests fail:
- Builder Agent fixes issues
- Re-run tests
- Repeat until passes

##### F. Verify Acceptance Criteria
Check each criterion:
- [ ] Criterion 1 met
- [ ] Criterion 2 met
- [ ] Criterion 3 met
- [ ] Subsystem versions updated correctly

Verify version updates:
- Check version files in subsystem directories were updated
- Check `docs/versions.md` was synchronized
- Verify version increment matches changes made
- Ensure version files are committed with changes

If any criterion not met:
- Builder Agent addresses missing items
- Re-verify

##### G. Commit Changes (Incremental)
Make incremental commits as work progresses:

```bash
# Stage completed work
git add -A

# Create commit with descriptive message following conventional commits
git commit -m "feat: [TASK-$ID] $TASK_TITLE

$COMMIT_BODY"
```

**Commit message format**:
```
feat: [TASK-001] Implement user authentication

- Add login endpoint
- Add JWT token generation
- Add password hashing

Closes #$ISSUE_NUMBER

Changes:
- Added: src/api/auth.ts
- Added: src/models/user.ts
- Modified: src/services/auth-service.ts
- Tests: Added tests for auth module
- Versions: Updated api/openapi.yaml to 1.1.0, backend/package.json to 1.1.0
```

**Incremental commit strategy**:
- Commit after logical units of work
- Don't wait until entire task is complete
- Makes debugging and reviews easier
- Reduces merge conflict risk

##### H. Push to Remote (For Pull Request)
```bash
git push -u origin feature/task-$TASK_ID
```

##### I. Create Pull Request
After task is complete and pushed:

```bash
gh pr create --base master \
  --title "[TASK-$ID] $TASK_TITLE" \
  --body "$(cat <<'EOF'
## Summary
[1-2 sentence description]

## Implementation Details
[Detailed description of what was implemented]

## Changes
- [List of key changes]
- [New files]
- [Modified files]

## Version Updates
- [Subsystem 1]: a.b.c → new.a.b.c (reason)
- [Subsystem 2]: a.b.c → new.a.b.c (reason)

## Task Completion
- Addresses: #$ISSUE_NUMBER
- Implements: [requirements from task]

## Testing
- [Describe what was tested]
- [Test results]

## Checklist
- [x] All acceptance criteria met
- [x] Tests added and passing
- [x] Code follows project conventions
- [x] Documentation updated
- [x] Linting passes
- [ ] Code reviewed (pending PR review)

## Notes
[Any additional notes or context]
EOF
)"
```

**PR creation strategy**:
- Create PR immediately after task completion
- Use task ID in PR title for clarity
- Link to GitHub issue
- Include implementation details and testing info
- Add checklist for acceptance criteria

**Benefits of immediate PR creation**:
- Enables immediate review feedback
- Faster iteration cycle
- Prevents feature branch drift
- Clearer audit trail

##### J. Update GitHub Issue
- Close issue with PR reference:
```bash
gh issue close $ISSUE_NUMBER --comment "Implemented in #PR_NUMBER"
```

### Phase 4: Progress Tracking

#### 4.1 Track Completed Tasks
Maintain list of completed tasks:
- Task ID
- Feature branch name
- Pull request number
- Completion time
- Commit SHA

#### 4.2 Report Status
After each task completion:
```bash
[Task Completion]

Task: TASK-001 - $TASK_TITLE
Branch: feature/task-TASK-001
PR: #PR_NUMBER
Status: ✅ Completed

[Progress]
Completed: 1/12 tasks (8%)
In Progress: None
Remaining: 11 tasks

[Next]
Next task: TASK-002 - $NEXT_TASK_TITLE
Ready to start? [Y/n]
```

### Phase 5: All Tasks Completion

#### 5.1 Verify All Tasks Complete
- Check all tasks in execution plan are completed
- Verify all GitHub issues are closed
- Ensure all pull requests are created
- All PRs are either merged or review-ready

#### 5.2 Create Summary PR (Optional)
After all tasks complete, create summary PR:
```bash
gh pr create --base master \
  --title "Complete implementation of [milestone/project]" \
  --body "$(cat <<'EOF'
## Summary
[3-6 bullet points describing overall implementation]

## Tasks Completed
- [List of all completed tasks]
- Links to individual PRs: #1, #2, #3

## Changes
[Summary of overall changes]

## Architecture
[Brief description of implemented architecture]

## Testing
[Overall testing approach and results]

## Migration Notes
[Any migration notes if applicable]

## Checklist
- [x] All execution plan tasks completed
- [x] All pull requests created
- [x] All PRs reviewed
- [x] Ready for merge to master
EOF
)"
```

#### 5.3 Report Final Status
```bash
[All Tasks Complete!]

✓ All 12 tasks completed successfully!
✓ 12 pull requests created
✓ All GitHub issues closed
✓ All tests passing
✓ All lint checks passing

[Summary]
Total tasks: 12
Total PRs: 12
Total time: 4h 23m

[Next Steps]
  1. Review individual PRs with team
  2. Address any review feedback
  3. Merge PRs to master when approved
  4. Close milestone in GitHub
```

## Usage

### Basic Execution
```bash
/skill execute-plan
```

### With Options
```bash
/skill execute-plan --sequential
```
Force sequential execution

```bash
/skill execute-plan --parallel
```
Enable parallel execution

```bash
/skill execute-plan --interactive
```
Interactive mode (ask before each task)

```bash
/skill execute-plan --from-task TASK-005
```
Start execution from specific task

```bash
/skill execute-plan --until-task TASK-010
```
Stop after completing specific task

```bash
/skill execute-plan --dry-run
```
Show what would be executed without making changes

## Required Environment Variables
None required (uses configuration from .git/opencode)

## Optional Environment Variables

- `MAX_PARALLEL_TASKS` - Maximum parallel tasks (default: 3)
- `TASK_TIMEOUT` - Timeout per task in milliseconds (default: 1800000 / 30min)
- `SKIP_LINT` - Skip linting (not recommended)
- `SKIP_TEST` - Skip testing (not recommended)
- `AUTO_CREATE_PR` - Automatically create PR after each task (default: true)
- `PR_MODE` - `immediate` or `batch` (default: `immediate`)

## Required Agents

- `builder` - Implements each task, writes tests, fixes issues

## Error Handling

### Plan File Not Found
```
Error: docs/execution-plan.md not found
Please run /skill init-project first or create an execution plan manually.
```

### Task Missing Issue
```
Warning: TASK-005 has no corresponding GitHub issue
Creating issue for TASK-005...
```

### Linting Failed
```
Linting failed for TASK-003
Fixing issues...
Retrying linting...
✓ Linting passed
```

### Tests Failed
```
Tests failed for TASK-004
Analyzing failures...
Fixing issues...
Retrying tests...
✓ Tests passed
```

### Task Timeout
```
Task TASK-006 timed out after 30 minutes
Options:
  1) Continue task (will restart from scratch)
  2) Skip task (will be marked as incomplete)
  3) Pause execution (resume later)

Select option [1/2/3]:
```

### Dependency Conflict
```
Circular dependency detected:
  TASK-007 → TASK-008 → TASK-007

This task cannot be executed. Please fix execution plan.
```

## Blocking and Self-Unblocking

### Self-Unblocking Strategy
Before asking for human intervention, the agent MUST attempt to unblock itself 3 times:

#### Attempt 1: Direct Fix
- Analyze the blocker independently
- Identify potential solutions using available tools
- Attempt the most straightforward fix
- Document the issue and attempted solution

#### Attempt 2: Alternative Approaches
- If first attempt failed, try alternative solutions
- Search codebase for similar patterns
- Use different tools or approaches
- Document why previous attempts failed

#### Attempt 3: Context Expansion
- If still blocked, expand search scope
- Use web search for documentation
- Look for similar issues in project history
- Consider refactoring approach

#### After 3 Attempts
Only after 3 documented failed attempts should the agent:
- Report the blocker to the user
- Summarize the 3 attempted solutions and why they failed
- Request specific guidance or intervention

### Blocker Documentation
For each unblocking attempt, document:
```markdown
Blocker: [Description]
Attempt 1: [Solution tried, outcome]
Attempt 2: [Alternative tried, outcome]
Attempt 3: [Expanded approach, outcome]
```

### Common Blockers and Self-Unblocking Strategies

**1. Unclear Requirements**
- Try to infer from context (task description, acceptance criteria, related code)
- Look at similar completed tasks
- Search for patterns in codebase
- Only ask if still unclear after 3 attempts

**2. Missing Dependencies**
- Check if dependency is already available in codebase
- Try alternative approaches without missing dependency
- Consider if dependency is truly necessary
- Only request dependency installation if essential and unworkable alternatives exhausted

**3. Test Failures**
- Run tests with verbose output to diagnose
- Check for flaky tests by re-running
- Look at test implementation for issues
- Only ask if failure reason is unknown after 3 attempts

**4. Lint Errors**
- Check if similar patterns exist in codebase (lint may be configured differently)
- Try alternative code style that achieves same result
- Check if there are exceptions configured in lint rules
- Only ask if error is unclear after 3 attempts

**5. Merge Conflicts**
- Attempt automatic resolution
- Check if both sides are equivalent
- Look at conflict resolution history in repo
- Only ask if conflict is truly ambiguous after 3 attempts

## Success Criteria

1. ✅ All tasks in execution plan are completed
2. ✅ All GitHub issues are closed
3. ✅ Pull requests created for each task
4. ✅ All tests pass
5. ✅ All lint checks pass
6. ✅ Code follows project conventions
7. ✅ Acceptance criteria met for each task
8. ✅ Documentation updated as needed
9. ✅ Feature branches created for each task
10. ✅ Pull requests linked to GitHub issues
11. ✅ Agent attempted to self-unblock 3 times before asking for human intervention
12. ✅ Subsystem versions updated correctly for each task
13. ✅ Version files updated in subsystem directories
14. ✅ `docs/versions.md` synchronized with project changes
15. ✅ Version increments match impact of changes made

## Feature Branch Strategy

### Branch Creation
Create a separate feature branch for EACH task:
```bash
git checkout master
git pull origin master
git checkout -b feature/task-$TASK_ID
```

### Branch Naming
- `feature/task-$TASK_ID` - Individual tasks
- `feature/task-$TASK_ID-$SHORT_DESC` - Descriptive
- `feature/$MILESTONE` - Milestone-based

### Benefits
1. **Independent Development**: Tasks can be worked on in parallel
2. **Isolated Reviews**: Each task gets its own PR and review
3. **Cleaner History**: No monolithic commits
4. **Faster Iteration**: Get feedback on individual features
5. **Reduced Conflicts**: Less chance of merge conflicts
6. **Better Tracking**: Clear audit trail per feature

### Commit Strategy
Make incremental commits:
```bash
# After completing logical unit
git add -A
git commit -m "feat: [TASK-$ID] unit of work"
```

Don't wait until task is complete.

### Pull Request Strategy
Create PR immediately after task completion:
```bash
git push -u origin feature/task-$TASK_ID
gh pr create --base master --title "[TASK-$ID] $TITLE"
```

### Issue Update Strategy
Close issue with PR reference:
```bash
gh issue close $ISSUE_NUMBER --comment "Implemented in #PR_NUMBER"
```

## Troubleshooting

### "Multiple branches for same task"
Delete duplicate branches and recreate:
```bash
git branch -D feature/task-$TASK_ID
git checkout master
git checkout -b feature/task-$TASK_ID
```

### "PR already exists"
Check existing PRs:
```bash
gh pr list --head feature/task-$TASK_ID
```

If PR exists, update it instead of creating new one:
```bash
gh pr edit $PR_NUMBER --body "Updated description"
```

### "Merge conflicts"
Resolve conflicts before creating PR:
```bash
git checkout master
git pull origin master
git checkout feature/task-$TASK_ID
git rebase master
# Resolve conflicts
git push origin feature/task-$TASK_ID
```

### "Issue not closing"
Manually close issue with correct PR reference:
```bash
gh issue close $ISSUE_NUMBER --comment "Implemented in #PR_NUMBER"
```
