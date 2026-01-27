# Domain-Specific Agents

This document describes the domain-specific agents available in the Power Template framework.

## Agent Architecture

The Power Template uses a multi-agent system where each agent has specialized responsibilities and is configured with appropriate models from OpenRouter or other providers.

## Available Agents

### 1. Planner Agent

**Purpose**: Creates technical design documents and execution plans.

**Model**: GLM4.5 Air (primary) → Gemini2.0 (fallback)

**Responsibilities**:
- Analyze project requirements and constraints
- Propose architecture options
- Create technical design documents
- Generate detailed execution plans with task breakdown
- Identify dependencies between tasks
- Assign priorities to tasks
- Define initial subsystem versions during project initialization
- Recommend version increments based on architectural changes

**When Used**:
- During project initialization (init-project skill)
- When creating or updating technical design
- When generating execution plans
- When re-planning due to changed requirements

**Configuration**:
```yaml
agent: planner
model: z-ai/glm-4.5-air:free
fallback: google/gemini-2.0-flash-exp:free
role: [planning, design]
temperature: 0.3
```

---

### 2. Builder Agent

**Purpose**: Implements features, fixes issues, writes tests, and applies fixes.

**Model**: GLM4.5 Air (primary) → Gemini2.0 (fallback)

**Responsibilities**:
- Write production code following best practices
- Write comprehensive tests
- Fix bugs and issues identified in reviews
- Refactor code for maintainability
- Update documentation
- Apply fixes from review findings
- Follow Stack Evolution rules
- Attempt to self-unblock 3 times before asking for human intervention
- Track and update subsystem versions based on changes made:
  - Increment patch version (a.b.➕c) for bug fixes and small improvements
  - Increment minor version (a.➕b.c) for new features
  - Recommend major version (➕a.b.c) increments for breaking changes

**When Used**:
- During execute-plan skill
- When auto-fixing review findings
- During manual implementation requests
- When updating stack configuration

**Configuration**:
```yaml
agent: builder
model: z-ai/glm-4.5-air:free
fallback: google/gemini-2.0-flash-exp:free
role: [building, implementation, testing]
temperature: 0.5
```

---

### 3. Web Searcher Agent

**Purpose**: Finds documentation, examples, and best practices.

**Model**: Gemini

**Responsibilities**:
- Search for current documentation
- Find code examples
- Research best practices
- Discover new tools and libraries
- Compare alternative solutions

**When Used**:
- When planner needs research
- When builder needs implementation examples
- During skill evolution

**Configuration**:
```yaml
agent: web_searcher
model: google/gemini-2.0-flash-exp:free
role: [research, documentation]
temperature: 0.4
tools: [web_search, webfetch]
```

---

## Agent Interactions

### Planning Phase
1. **Planner Agent** analyzes requirements → **Web Searcher Agent** researches options → **Planner Agent** creates design

### Implementation Phase
1. **Planner Agent** creates execution plan → **Builder Agent** implements tasks

### Feature Branch Review Phase (Local)
1. **Builder Agent** completes work → Pre-push hook runs → Code quality checks performed locally → **Builder Agent** auto-fixes findings

### Code Review Phase (Remote)
1. Developer creates PR from feature to main → **Gemini Code Assist** (GitHub App) reviews PR when triggered with "/gemini review" → Developer addresses feedback as needed

---

## Agent Model Configuration

### OpenRouter Models

**GLM4.5 Air** (Primary Builder/Planner)
```yaml
provider: openrouter
model: z-ai/glm-4.5-air:free
api_key_env: OPENROUTER_API_KEY
priority: 1
max_tokens: 4000
temperature: 0.5
```

**Gemini2.0** (Fallback Builder/Planner)
```yaml
provider: openrouter
model: google/gemini-2.0-flash-exp:free
api_key_env: OPENROUTER_API_KEY
priority: 2
max_tokens: 4000
temperature: 0.5
```

### Gemini Models

**Gemini 2.0 Flash** (Web Searcher)
```yaml
provider: gemini
model: google/gemini-2.0-flash-exp:free
api_key_env: GEMINI_API_KEY
max_tokens: 3000
temperature: 0.3
```

---

## Handling Dependent Tasks

When working on a task that depends on another task with an open PR:

1. **Check for Code Review Comments**
   - Look for comments on the dependent PR
   - Ignore the first comment from gemini-code-assist that starts with "Summary of Changes"
   - Look for the comment from gemini-code-assist starting with "Code Review"

2. **Review Findings**
   - **If no critical issues found**: Merge the PR, update the current branch, and proceed with development
   - **If critical changes requested**: Switch back to the PR's branch, fix the issue, update the PR, and merge (no need for re-review)
   - **If non-critical issues found**: Create GitHub issues with matching priority, merge the PR, and proceed with development

3. **GitHub Issue Creation for Low Priority Items**
   - For low priority findings, create GitHub issues:
     - Title: "Low Priority Issue: [description]"
     - Body: Include file location, priority, description, fix suggestion, and PR link
     - Link to the original PR for reference

## Adding New Agents

To add a new specialized agent:

1. Create a new agent definition file in `.opencode/agents/[agent-name].md`
2. Define the agent's purpose, model, responsibilities, and when it's used
3. Update this AGENTS.md file with the new agent's documentation
4. Configure the agent in `.git/opencode` if it needs model configuration
5. Create skills that utilize the new agent

---

## Subsystem Version Tracking

All agents MUST track versions of project subsystems using semantic versioning (a.b.c).

**IMPORTANT**: Version files are stored in project directories, not in `.operational/`, making them versioned and visible to contributors and running software.

### Version File Locations

Each subsystem stores its version in its own directory:

#### Common Patterns

**Frontend (JavaScript/TypeScript)**
```
frontend/
├── package.json          # version in "version" field
├── VERSION.md            # Human-readable version history
└── src/
```

**Backend (Node.js/Python/Java/etc.)**
```
backend/
├── package.json          # or pyproject.toml, pom.xml, etc.
├── VERSION.md            # Human-readable version history
└── src/
```

**API**
```
api/
├── version.json          # API version metadata
├── openapi.yaml          # or swagger.json (version in info.version)
└── endpoints/
```

**Database**
```
migrations/
├── version.json          # Schema version tracking
└── 20260101_initial_schema.sql
```

**Infrastructure**
```
terraform/ or ansible/
├── version.json          # Infrastructure version
└── modules/
```

### Central Version Tracking

A centralized `docs/versions.md` tracks all subsystem versions for easy reference. This file should be created in the project's `docs/` directory during project initialization.

```markdown
# Subsystem Versions

## Frontend
- **Current Version**: 1.0.0
- **Location**: `frontend/package.json`
- **Last Updated**: 2026-01-25
- **Last Change**: Initial version

## Backend
- **Current Version**: 1.0.0
- **Location**: `backend/package.json`
- **Last Updated**: 2026-01-25
- **Last Change**: Initial version

[...]
```

### Default Subsystems

The system tracks these subsystems by default:
1. **Frontend** - UI components, user-facing code
2. **Backend** - Server-side logic, services
3. **API** - API contracts, endpoints, schemas
4. **Database** - Database schema, migrations
5. **Infrastructure** - DevOps, CI/CD, deployment

### Semantic Versioning Rules

#### Major Version (a) - Breaking Changes
- Breaking API contract changes
- Removing deprecated features
- Significant architectural changes
- Database migrations requiring data migration

#### Minor Version (b) - New Features
- Adding new features
- New API endpoints
- New database tables/columns (backwards compatible)
- New UI components

#### Patch Version (c) - Bug Fixes
- Bug fixes
- Small improvements
- Documentation updates
- Performance optimizations
- Refactoring without behavior changes

### Version Update Workflow

#### 1. Planner Agent (Project Initialization)
- Identifies subsystems from technical design
- Determines appropriate version file location for each subsystem:
  - JavaScript/TypeScript: Use `package.json` version field
  - Python: Use `pyproject.toml` or `__version__.py`
  - Java: Use `pom.xml` or `build.gradle`
  - Go: Use module version or create `version.go`
  - API: Use `openapi.yaml` info.version field
  - Database: Create `migrations/version.json`
  - Infrastructure: Create `terraform/version.json` or similar
- Creates `docs/versions.md` with all subsystems tracked
- Initializes all subsystems to version 1.0.0

#### 2. Builder Agent (During Implementation)
- Reads current subsystem versions from their respective locations
- Updates version after completing changes:
  - Analyze impact of changes
  - Determine appropriate version increment (major/minor/patch)
  - Update version file in subsystem directory
  - Update `docs/versions.md` for visibility
  - Record task ID and commit SHA in commit message
- Follows language-specific conventions:
  - JavaScript/TypeScript: Update `package.json` version field
  - Python: Update `pyproject.toml` version
  - Java: Update `pom.xml` version
  - etc.

#### 3. Reviewer Agent (During Review)
- Checks if version was updated appropriately for changes made
- Verifies version increment matches impact of changes
- Flags if breaking changes should trigger major version bump
- Ensures version files are committed with code changes

### Version File Formats by Subsystem Type

#### Frontend/Backend (JavaScript/TypeScript - package.json)
```json
{
  "name": "my-app",
  "version": "1.1.0",
  "description": "My application",
  "scripts": { ... },
  "dependencies": { ... }
}
```

#### API (OpenAPI/Swagger)
```yaml
openapi: 3.0.0
info:
  title: My API
  version: "1.2.0"
  description: API description
paths:
  # ...
```

#### Database Migrations (version.json)
```json
{
  "schema_version": "1.0.1",
  "last_migration": "20260125_add_user_preferences",
  "history": [
    {
      "version": "1.0.1",
      "migration": "20260125_add_user_preferences",
      "change": "Added user preferences table",
      "timestamp": "2026-01-25T12:00:00Z",
      "task_id": "TASK-005",
      "commit": "abc123"
    }
  ]
}
```

#### Infrastructure (version.json)
```json
{
  "infrastructure_version": "1.0.0",
  "last_updated": "2026-01-25T12:00:00Z",
  "last_change": "Added CI/CD pipeline",
  "history": [
    {
      "version": "1.0.0",
      "change": "Initial infrastructure setup",
      "timestamp": "2026-01-25T12:00:00Z"
    }
  ]
}
```

### Version Increment Decision Tree

```
Is this a breaking change?
├─ YES → Increment MAJOR (a.b.c → a+1.0.0)
└─ NO → Does this add new functionality?
    ├─ YES → Increment MINOR (a.b.c → a.b+1.0)
    └─ NO → Is this a bug fix or small improvement?
        ├─ YES → Increment PATCH (a.b.c → a.b.c+1)
        └─ NO → No version increment needed
```

### Best Practices for Version Tracking

1. **Store version in project directory** - Version files must be in the actual subsystem directory, not `.operational/`
2. **Use language-specific conventions** - JavaScript uses `package.json`, Python uses `pyproject.toml`, etc.
3. **Maintain central overview** - Keep `docs/versions.md` updated for visibility
4. **Commit versions with code** - Version changes should be committed with the code that triggers them
5. **Be specific in change descriptions** - Describe exactly what changed to justify the version increment
6. **Link to task/commit** - Always include task ID and commit SHA in commit messages
7. **Review version consistency** - Ensure version increment matches the scope of changes
8. **Document breaking changes** - For major version bumps, clearly document what changed
9. **Make versions machine-readable** - Software should be able to read version files
10. **Keep history in docs** - Maintain version change history in `docs/versions.md`

### Customizing Subsystems

Projects can customize subsystems by:
1. Adding new subsystems to `docs/versions.md`
2. Creating appropriate version files in subsystem directories
3. Updating project structure to include new subsystems

Example custom subsystems:

```markdown
## Mobile App
- **Current Version**: 1.0.0
- **Location**: `mobile/Info.plist` (iOS) or `mobile/build.gradle` (Android)
- **Last Updated**: 2026-01-25
- **Last Change**: Initial version

## ML Model
- **Current Version**: 1.0.0
- **Location**: `models/classifier/version.json`
- **Last Updated**: 2026-01-25
- **Last Change**: Initial model training
```

---

## Agent Best Practices

- Each agent should have a single, well-defined purpose
- Agents should be configured with appropriate temperature for their task
- Fallback models should be specified for critical agents
- Builder agents should use moderate temperature for creativity
- Planner agents should use lower temperature for structured output

---

## Operational State Tracking

**CRITICAL**: All agents MUST maintain operational state to enable recovery from interruptions (directory renames, system restarts, etc.).

### Operational Directory Structure

```
.operational/
├── project-objective.md    # Overall project goal and user requirements
├── todo-checklist.md       # Current TODO items with status tracking
└── session-history.md      # Optional: session history for context
```

### Responsibilities for All Agents

1. **ALWAYS** maintain `.operational/` files during workflow execution
2. **ALWAYS** read `.operational/project-objective.md` and `.operational/todo-checklist.md` before taking any action
3. **ALWAYS** update these files after completing any task or receiving user input
4. **NEVER** lose user requirements or project context

### project-objective.md Format

```markdown
# Project Objective

## Project Description
[Original project goal from first question in init-project]

## User Requirements

### Functional Requirements
- [Requirement 1]
- [Requirement 2]

### Non-Functional Requirements
- [Latency/Performance]
- [Scale/Concurrency]
- [Security/Compliance]

### Constraints
- [Budget/Cost]
- [Technology constraints]
- [Timeline]

### Preferences
- [Languages/Frameworks]
- [Database preferences]
- [Deployment preferences]

## Clarifying Questions & Answers

### Q: [Question asked]
**A:** [User's response]

### Q: [Another question]
**A:** [User's response]

## Context Notes
[Any additional context that should be preserved]
```

### todo-checklist.md Format

```markdown
# Operational TODO Checklist

## Current Session: [Timestamp]
- Skill: [skill-name]
- Agent: [agent-name]
- Phase: [current-phase]

## Completed Tasks

- [x] [Task description] (completed at [timestamp])
- [x] [Task description] (completed at [timestamp])

## In Progress

- [ ] [Task description] (started at [timestamp])
  - Subtask: [detail]
  - Subtask: [detail]

## Pending Tasks

- [ ] [Task description] (priority: high/medium/low)
- [ ] [Task description] (priority: high/medium/low)

## Blocked/Issues

- [ ] [Description of blocker] (since [timestamp])

## Next Actions

1. [Next immediate action]
2. [Follow-up action]
```

### Recovery Protocol

**When resuming after interruption:**

1. **ALWAYS** read `.operational/project-objective.md` first to understand project context
2. **ALWAYS** read `.operational/todo-checklist.md` to see current state
3. Report to user: "I've reviewed the operational state. Here's where we left off..."
4. Ask user: "Do you want to continue from here, or would you like to make any changes?"

**When starting a new skill:**

1. Check if `.operational/` exists
2. If exists, read to understand context
3. Update files with new workflow context
4. If doesn't exist, create initial files with project objective and TODO checklist

### Skill-Specific Requirements

#### init-project
- Create `.operational/project-objective.md` after gathering requirements
- Create `.operational/todo-checklist.md` before Phase 1
- Update TODO checklist as each phase completes

#### execute-plan
- Read `.operational/project-objective.md` to understand goals
- Create task-specific TODO for each execution plan item
- Mark tasks complete as work progresses

#### fix-review-issues
- Read `.operational/project-objective.md` for context
- Create TODO items for each review finding
- Track fix progress in checklist

#### All skills
- Read operational files on startup
- Update after each meaningful action
- Preserve user input and decisions
