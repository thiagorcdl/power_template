# Skills

This document describes the available skills in the Power Template framework.

## Skills Overview

Skills are reusable workflows that leverage domain-specific agents to accomplish common development tasks. Each skill is defined in `.opencode/skills/` and can be invoked via opencode commands.

---

## Available Skills

### 1. init-project

**Purpose**: Initialize a new project with complete planning and setup workflow.

**When to Use**:
- Starting a new project from scratch
- Setting up a fork of the power_template for a new codebase

**Workflow**:

#### Phase 1: Setup
- **Create `.operational/` directory** with `todo-checklist.md` containing all phases
- Check for required API keys:
  - `OPENROUTER_API_KEY` (for GLM4.7 and Qwen3)
  - `GEMINI_API_KEY` (for web searching)
  - `GITHUB_TOKEN` (for repo creation and issue management)
- If missing, guide user to set them in environment
- Verify GitHub authentication with `gh auth status`
- Update `todo-checklist.md` to mark Phase 1 complete

#### Phase 2: Planning
- **Create `.operational/project-objective.md`** with:
  - Original project description from user
  - All user requirements (functional, non-functional)
  - All constraints (latency, scale, cost, security, compliance)
  - All user preferences (languages, frameworks, databases, deployment)
  - All clarifying questions and user answers
- Ask user for:
  - Project goal (what problem are you solving?)
  - Requirements (functional and non-functional)
  - Constraints (latency, scale, cost, security, compliance)
  - Preferences (languages, frameworks, databases, deployment)
- Use **Web Searcher Agent** to research best practices for the requirements
- Use **Planner Agent** to propose 2-3 architecture options
- User selects architecture or provides feedback for iteration
- Update `todo-checklist.md` to mark Phase 2 complete

#### Phase 3: Technical Design
- Use **Planner Agent** to generate technical design document
- Document saved to: `docs/technical-design.md`
- Includes:
  - Project overview
  - Architecture diagrams
  - Data model
  - API design
  - Security considerations
  - Deployment strategy
  - Monitoring and observability
- Update `todo-checklist.md` to mark Phase 3 complete

#### Phase 4: Execution Planning
- Use **Planner Agent** to generate execution plan
- Document saved to: `docs/execution-plan.md`
- Includes:
  - Task list with priorities (P0, P1, P2)
  - Dependencies between tasks
  - Milestones
  - Estimated effort
- Update `todo-checklist.md` to mark Phase 4 complete

#### Phase 5: GitHub Setup (Semi-automated)
- Generate proposed repository name based on project
- Propose visibility (private by default)
- Ask user for confirmation:
  - Repository name
  - Visibility (private/public)
  - Description
- Create GitHub repo via `gh repo create`
- Configure remote
- Push initial commit with template files
- Update `todo-checklist.md` to mark Phase 5 complete

#### Phase 6: Issue Creation
- Parse execution plan
- Create GitHub issues for each task
- Each issue includes:
  - Task description
  - Acceptance criteria
  - Dependencies (linked issues)
  - Priority label
  - Detailed implementation instructions
- Update `todo-checklist.md` to mark Phase 6 complete and skill complete

**Usage**:
```
/init-project
```

**Required Environment Variables**:
- `OPENROUTER_API_KEY`
- `GEMINI_API_KEY`
- `GITHUB_TOKEN`

**Optional**:
- `GITHUB_USER` (defaults to authenticated user)
- `GITHUB_ORG` (if creating under an organization)

---

### 2. execute-plan

**Purpose**: Execute the tasks defined in the execution plan.

**When to Use**:
- After technical design is approved
- When ready to start implementation
- After manual updates to execution plan

**Workflow**:

1. **Load Operational State**
   - Read `.operational/project-objective.md` to understand project context
   - Read `.operational/todo-checklist.md` to see current progress
   - If interrupted, resume from last incomplete task

2. **Load Plan**
   - Read `docs/execution-plan.md`
   - Parse tasks, priorities, and dependencies
   - Verify GitHub issues exist for tasks

3. **Execution Mode**
   - Ask user: Execute sequentially or in parallel?
   - **Sequential**: Execute tasks one at a time in dependency order
   - **Parallel**: Execute independent tasks concurrently

4. **Task Execution**
   For each task:
   - Create TODO item in `.operational/todo-checklist.md`
   - Use **Builder Agent** to implement the task
   - Follow instructions from GitHub issue
   - Write appropriate tests
   - Run `./scripts/lint.sh`
   - Run `./scripts/test.sh`
   - Fix any issues that arise
   - Create commit with descriptive message
   - Update GitHub issue status
   - Mark TODO item complete in `todo-checklist.md`

5. **Progress Tracking**
   - Mark completed issues
   - Update progress in execution plan
   - Report status to user
   - Update `todo-checklist.md` with next actions

6. **Completion**
   - When all tasks complete, verify:
   - All tests pass
   - All lint checks pass
   - All GitHub issues closed
   - Mark skill complete in `todo-checklist.md`

**Usage**:
```
/execute-plan
```

**Options**:
- `--sequential`: Force sequential execution
- `--parallel`: Enable parallel execution
- `--from-task`: Start from specific task
- `--until-task`: Stop at specific task

---

### 3. fix-review-issues

**Purpose**: Automatically fix issues identified during code review.

**When to Use**:
- During pre-push hook (automatic)
- Manually after receiving review feedback
- Before creating PR

**Workflow**:

1. **Load Operational State**
   - Read `.operational/project-objective.md` for context
   - Create or update `.operational/todo-checklist.md` with review findings

2. **Load Review Findings**
   - Read review findings file or parse from input
   - Parse findings by severity (P0, P1, P2)
   - Sort by severity (P0 first)
   - Add findings as TODO items in `todo-checklist.md`

3. **Fix Each Finding**
   For each finding:
   - Mark finding as "in progress" in `todo-checklist.md`
   - Identify file and line number
   - Parse the issue description
   - Use **Builder Agent** to generate fix
   - Apply fix to code
   - Run `./scripts/lint.sh`
   - Run `./scripts/test.sh`
   - If tests fail, iterate on fix
   - Mark finding as "completed" in `todo-checklist.md`

4. **Verification**
   - After fixing all findings
   - Re-run review to verify fixes
   - Report remaining issues (if any)
   - Update `todo-checklist.md` with verification results

5. **Commit**
   - Stage all fixes
   - Create commit: "fix: address review findings"
   - Fixes are part of the same commit, not separate
   - Update `todo-checklist.md` to mark skill complete

**Usage**:
```
/fix-review-issues [review-file]
```

**Arguments**:
- `review-file`: Path to review findings file (optional, defaults to latest)

**Environment Variables**:
- `ALLOW_P0=1`: Override P0 blocking behavior

---

### 4. update-stack-config

**Purpose**: Update lint and test configurations based on detected stack.

**When to Use**:
- After adding new language/framework to project
- After stack detection identifies new components
- Manual override when auto-detection is incorrect

**Workflow**:

1. **Detect Stack**
   - Run `detect-stack` skill
   - Get list of detected languages/frameworks
   - Check for manual override in `.opencode/config/stack.json`

2. **Load Configuration**
   - Load `.opencode/config/lint-test-commands.json`
   - Get commands for detected stack
   - Merge with existing configuration

3. **Update Scripts**
   - Update `scripts/lint.sh` with appropriate lint commands
   - Update `scripts/test.sh` with appropriate test commands
   - Ensure scripts:
     - Exit non-zero on failure
     - Are deterministic
     - Work in CI

4. **Update CI**
   - Update `.github/workflows/ci.yml`
   - Add toolchain installation steps
   - Ensure CI runs `./scripts/check.sh`

5. **Verify**
   - Run `./scripts/lint.sh` (may fail if no code exists yet)
   - Run `./scripts/test.sh` (may fail if no tests exist yet)
   - Confirm scripts are executable

6. **Commit**
   - Stage updated files
   - Create commit: "chore: update stack configuration for [languages/frameworks]"

**Usage**:
```
/update-stack-config
```

**Options**:
- `--force`: Override existing configuration without confirmation
- `--dry-run`: Show changes without applying

---

### 5. detect-stack

**Purpose**: Detect the programming languages and frameworks used in the project.

**When to Use**:
- During project initialization
- After adding new dependencies
- Before updating stack configuration

**Workflow**:

1. **Scan Project Files**
   - Look for package manager files:
     - `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` → Node.js/TypeScript
     - `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile` → Python
     - `go.mod`, `go.sum` → Go
     - `Cargo.toml`, `Cargo.lock` → Rust
     - `pom.xml`, `build.gradle`, `build.gradle.kts` → Java/Kotlin
     - `Gemfile`, `Gemfile.lock` → Ruby
     - `composer.json`, `composer.lock` → PHP
     - `mix.exs` → Elixir
     - `pubspec.yaml` → Dart/Flutter
     - `project.clj` → Clojure
     - `shard.yml` → Crystal
     - `build.sbt` → Scala

2. **Analyze Dependencies**
   - Parse package files to detect frameworks:
     - `react`, `vue`, `angular`, `svelte` → Frontend frameworks
     - `express`, `fastify`, `nest` → Backend frameworks (Node)
     - `django`, `flask`, `fastapi` → Backend frameworks (Python)
     - `gin`, `echo`, `fiber` → Backend frameworks (Go)
     - `actix-web`, `axum`, `rocket` → Backend frameworks (Rust)
     - `spring-boot` → Backend frameworks (Java)

3. **Check Configuration Files**
   - Look for framework-specific configs:
     - `next.config.js`, `nuxt.config.js` → Meta-frameworks
     - `vite.config.js`, `webpack.config.js` → Build tools
     - `tsconfig.json` → TypeScript
     - `.eslintrc`, `.prettierrc` → JavaScript tooling

4. **Generate Stack Report**
   - Create `.opencode/config/stack.json`
   - Format:
   ```json
   {
     "languages": ["typescript", "python"],
     "frameworks": ["react", "fastapi"],
     "package_managers": ["npm", "pip"],
     "build_tools": ["vite", "pytest"],
     "detected_at": "2026-01-18T13:45:00Z",
     "manual_override": false
   }
   ```

5. **Output Summary**
   - Display detected stack to user
   - Ask for confirmation
   - Offer manual override option

**Usage**:
```
/detect-stack
```

**Options**:
- `--override <json>`: Provide manual stack configuration
- `--append <json>`: Append to detected stack

---

## Skill Development

### Creating a New Skill

1. Create skill file: `.opencode/skills/[skill-name].md`
2. Define skill purpose and when to use
3. Document workflow steps
4. Specify required and optional parameters
5. Define environment variables needed
6. List required agents

### Skill File Template

```markdown
### [skill-name]

**Purpose**: [What the skill does]

**When to Use**:
- [Use case 1]
- [Use case 2]

**Workflow**:
1. [Step 1]
2. [Step 2]

**Usage**:
```
/[skill-name] [options]
```

**Required Agents**:
- [agent-name]

**Environment Variables**:
- `VAR_NAME`: Description

**Options**:
- `--option`: Description
```

---

## Skill Best Practices

- Each skill should have a single, well-defined purpose
- Skills should be idempotent (safe to run multiple times)
- Skills should handle errors gracefully
- Skills should provide clear feedback to users
- Skills should respect environment variables for configuration
- Skills should use appropriate agents for each task
- Skills should be documented with examples
- **CRITICAL**: Skills MUST maintain operational state in `.operational/` directory for recovery from interruptions

---

## Operational State Management

### Overview

All skills MUST maintain operational state to enable recovery from directory renames, system restarts, or other interruptions. The `.operational/` directory contains:

```
.operational/
├── project-objective.md    # Project goal, requirements, and user answers
├── todo-checklist.md       # TODO items with status tracking
└── session-history.md      # Optional: session context
```

### Responsibilities for All Skills

1. **Always read** `.operational/project-objective.md` and `.operational/todo-checklist.md` before taking action
2. **Always update** these files after completing tasks or receiving user input
3. **Create** `.operational/` directory if it doesn't exist
4. **Never lose** user requirements or project context

### Skill-Specific Requirements

#### init-project
- **Phase 1**: Create `.operational/todo-checklist.md` with all phases as TODO items
- **Phase 2**: Create `.operational/project-objective.md` with:
  - Original project description
  - All user requirements
  - All clarifying questions and answers
- **Throughout**: Update todo-checklist.md as each phase completes
- **Recovery**: If interrupted, read both files to resume from last completed phase

#### execute-plan
- **Start**: Read `.operational/project-objective.md` to understand project context
- **Start**: Read `.operational/todo-checklist.md` to see current progress
- **Task execution**: For each task, create TODO items in checklist and mark complete when done
- **Throughout**: Update todo-checklist.md after each task completes
- **Recovery**: If interrupted, read both files to resume from last incomplete task

#### fix-review-issues
- **Start**: Read `.operational/project-objective.md` for context
- **Start**: Create `.operational/todo-checklist.md` with review findings as TODO items
- **Throughout**: Mark findings as fixed as progress continues
- **Recovery**: If interrupted, read files to resume from last unfixed finding

#### update-stack-config
- **Start**: Read `.operational/project-objective.md` (if exists) for context
- **During**: Update todo-checklist.md with progress
- **After**: Commit changes and update checklist

#### detect-stack
- **Start**: Read `.operational/project-objective.md` (if exists) for context
- **After**: Create/update `.opencode/config/stack.json` and update todo-checklist.md

### Recovery Protocol

**When resuming after interruption:**

1. Read `.operational/project-objective.md` to understand project context
2. Read `.operational/todo-checklist.md` to see current state
3. Report to user: "I've reviewed the operational state. Here's where we left off..."
4. Ask: "Do you want to continue from here, or would you like to make any changes?"

**When starting any skill:**

1. Check if `.operational/` exists
2. If yes, read both files to understand context
3. Update files with new workflow context
4. If no, create initial files

### File Format Examples

**project-objective.md**:
```markdown
# Project Objective

## Project Description
[Original project description from user]

## User Requirements

### Functional Requirements
- [Requirement 1]
- [Requirement 2]

### Non-Functional Requirements
- [Performance requirements]
- [Scale requirements]

### Constraints
- [Budget/cost constraints]
- [Technology constraints]

### Preferences
- [Languages/frameworks]
- [Database preferences]

## Clarifying Questions & Answers

### Q: [Question]
**A:** [User response]
```

**todo-checklist.md**:
```markdown
# Operational TODO Checklist

## Current Session: [Timestamp]
- Skill: [skill-name]
- Agent: [agent-name]
- Phase: [phase-name]

## Completed Tasks
- [x] [Task description] (completed at [timestamp])
- [x] [Task description] (completed at [timestamp])

## In Progress
- [ ] [Task description] (started at [timestamp])
  - Subtask: [detail]

## Pending Tasks
- [ ] [Task description] (priority: high/medium/low)

## Blocked/Issues
- [ ] [Blocker description] (since [timestamp])

## Next Actions
1. [Next immediate action]
2. [Follow-up action]
```

---

## Skill Interactions

Skills can call other skills:

- `init-project` calls `detect-stack` to auto-detect project stack
- `fix-review-issues` may call `update-stack-config` if new dependencies are added
- `execute-plan` may call `fix-review-issues` after each task completion

Skills use agents:

- Most planning skills use **Planner Agent**
- Implementation skills use **Builder Agent**
- Review skills use **Reviewer Agent**
- Research skills use **Web Searcher Agent**

---

## Skill Configuration

Skills can be configured via:

1. **Environment Variables**: Runtime configuration
2. **Config Files**: `.opencode/config/*.json`
3. **Command Line Options**: Per-invocation configuration
4. **Interactive Prompts**: User input during execution

Configuration priority (highest to lowest):
1. Command line options
2. Environment variables
3. Config files
4. Interactive defaults
