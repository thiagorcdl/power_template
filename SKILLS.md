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
- Check for required API keys:
  - `OPENROUTER_API_KEY` (for GLM4.7 and Qwen3)
  - `GEMINI_API_KEY` (for web searching)
  - `GITHUB_TOKEN` (for repo creation and issue management)
- If missing, guide user to set them in environment
- Verify GitHub authentication with `gh auth status`

#### Phase 2: Planning
- Ask user for:
  - Project goal (what problem are you solving?)
  - Requirements (functional and non-functional)
  - Constraints (latency, scale, cost, security, compliance)
  - Preferences (languages, frameworks, databases, deployment)
- Use **Web Searcher Agent** to research best practices for the requirements
- Use **Planner Agent** to propose 2-3 architecture options
- User selects architecture or provides feedback for iteration

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

#### Phase 4: Execution Planning
- Use **Planner Agent** to generate execution plan
- Document saved to: `docs/execution-plan.md`
- Includes:
  - Task list with priorities (P0, P1, P2)
  - Dependencies between tasks
  - Milestones
  - Estimated effort

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

#### Phase 6: Issue Creation
- Parse execution plan
- Create GitHub issues for each task
- Each issue includes:
  - Task description
  - Acceptance criteria
  - Dependencies (linked issues)
  - Priority label
  - Detailed implementation instructions

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

1. **Load Plan**
   - Read `docs/execution-plan.md`
   - Parse tasks, priorities, and dependencies
   - Verify GitHub issues exist for tasks

2. **Execution Mode**
   - Ask user: Execute sequentially or in parallel?
   - **Sequential**: Execute tasks one at a time in dependency order
   - **Parallel**: Execute independent tasks concurrently

3. **Task Execution**
   For each task:
   - Use **Builder Agent** to implement the task
   - Follow instructions from GitHub issue
   - Write appropriate tests
   - Run `./scripts/lint.sh`
   - Run `./scripts/test.sh`
   - Fix any issues that arise
   - Create commit with descriptive message
   - Update GitHub issue status

4. **Progress Tracking**
   - Mark completed issues
   - Update progress in execution plan
   - Report status to user

5. **Completion**
   - When all tasks complete, verify:
   - All tests pass
   - All lint checks pass
   - All GitHub issues closed

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

1. **Load Review Findings**
   - Read review findings file or parse from input
   - Parse findings by severity (P0, P1, P2)
   - Sort by severity (P0 first)

2. **Fix Each Finding**
   For each finding:
   - Identify file and line number
   - Parse the issue description
   - Use **Builder Agent** to generate fix
   - Apply fix to code
   - Run `./scripts/lint.sh`
   - Run `./scripts/test.sh`
   - If tests fail, iterate on fix

3. **Verification**
   - After fixing all findings
   - Re-run review to verify fixes
   - Report remaining issues (if any)

4. **Commit**
   - Stage all fixes
   - Create commit: "fix: address review findings"
   - Fixes are part of the same commit, not separate

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
