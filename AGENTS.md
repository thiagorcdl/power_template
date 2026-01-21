# Domain-Specific Agents

This document describes the domain-specific agents available in the Power Template framework.

## Agent Architecture

The Power Template uses a multi-agent system where each agent has specialized responsibilities and is configured with appropriate models from OpenRouter or other providers.

## Available Agents

### 1. Planner Agent

**Purpose**: Creates technical design documents and execution plans.

**Model**: GLM4.7 (primary) → Qwen3 (fallback)

**Responsibilities**:
- Analyze project requirements and constraints
- Propose architecture options
- Create technical design documents
- Generate detailed execution plans with task breakdown
- Identify dependencies between tasks
- Assign priorities to tasks

**When Used**:
- During project initialization (init-project skill)
- When creating or updating technical design
- When generating execution plans
- When re-planning due to changed requirements

**Configuration**:
```yaml
agent: planner
model: glm-4.7
fallback: qwen3
role: [planning, design]
temperature: 0.3
```

---

### 2. Builder Agent

**Purpose**: Implements features, fixes issues, writes tests, and applies fixes.

**Model**: GLM4.7 (primary) → Qwen3 (fallback)

**Responsibilities**:
- Write production code following best practices
- Write comprehensive tests
- Fix bugs and issues identified in reviews
- Refactor code for maintainability
- Update documentation
- Apply fixes from review findings
- Follow Stack Evolution rules
- Attempt to self-unblock 3 times before asking for human intervention

**When Used**:
- During execute-plan skill
- When auto-fixing review findings
- During manual implementation requests
- When updating stack configuration

**Configuration**:
```yaml
agent: builder
model: glm-4.7
fallback: qwen3
role: [building, implementation, testing]
temperature: 0.5
```

---

### 3. Reviewer Agent

**Purpose**: Reviews code changes and identifies potential issues.

**Model**: Gemini

**Responsibilities**:
- Review code diffs for security issues
- Identify correctness problems
- Check for missing tests
- Detect architecture regressions
- Classify findings by severity (P0, P1, P2)
- Provide specific fix recommendations

**When Used**:
- During pre-push hook
- During code review requests
- Before merging to master

**Configuration**:
```yaml
agent: reviewer
model: gemini-2.5-pro
role: [reviewing, quality assurance]
temperature: 0.2
focus: [security, correctness, testing, architecture]
```

**Review Findings Format**:
```markdown
## Summary
- 3-6 bullet points

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
- Specific test cases to add
```

---

### 4. Web Searcher Agent

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
- When reviewer needs to verify patterns
- During skill evolution

**Configuration**:
```yaml
agent: web_searcher
model: gemini-2.5-pro
role: [research, documentation]
temperature: 0.4
tools: [web_search, webfetch]
```

---

### 5. Code Reviewer Agent

**Purpose**: Reviews pull requests against the master branch.

**Model**: Bugbot

**Responsibilities**:
- Review PR changes
- Identify potential bugs
- Suggest improvements
- Check for security issues
- Ensure code quality standards

**When Used**:
- When PR is opened to master
- When PR is updated targeting master
- When explicitly triggered via comment

**Configuration**:
```yaml
agent: code_reviewer
provider: bugbot
role: [pr_review]
trigger: pr_to_master
```

---

## Agent Interactions

### Planning Phase
1. **Planner Agent** analyzes requirements → **Web Searcher Agent** researches options → **Planner Agent** creates design

### Implementation Phase
1. **Planner Agent** creates execution plan → **Builder Agent** implements tasks

### Feature Branch Review Phase (Local)
1. **Builder Agent** completes work → Pre-push hook runs → **Reviewer Agent** (Gemini) reviews changes → **Builder Agent** auto-fixes findings

### Development PR Review Phase (Remote)
1. Developer creates PR from feature to development → **Reviewer Agent** (Gemini, via GitHub Actions) reviews PR → Developer fixes issues if found

### Master PR Review Phase (Remote)
1. Developer creates PR from development to master → **Code Reviewer Agent** (Bugbot, via Cursor) reviews PR → Developer fixes issues if found

---

## Agent Model Configuration

### OpenRouter Models

**GLM4.7** (Primary Builder/Planner)
```yaml
provider: openrouter
model: glm-4.7
api_key_env: OPENROUTER_API_KEY
priority: 1
max_tokens: 4000
temperature: 0.5
```

**Qwen3** (Fallback Builder/Planner)
```yaml
provider: openrouter
model: qwen3
api_key_env: OPENROUTER_API_KEY
priority: 2
max_tokens: 4000
temperature: 0.5
```

### Gemini Models

**Gemini 2.5 Pro** (Reviewer/Web Searcher)
```yaml
provider: gemini
model: gemini-2.5-pro
api_key_env: GEMINI_API_KEY
max_tokens: 3000
temperature: 0.3
```

---

## Adding New Agents

To add a new specialized agent:

1. Create a new agent definition file in `.opencode/agents/[agent-name].md`
2. Define the agent's purpose, model, responsibilities, and when it's used
3. Update this AGENTS.md file with the new agent's documentation
4. Configure the agent in `.git/opencode` if it needs model configuration
5. Create skills that utilize the new agent

---

## Agent Best Practices

- Each agent should have a single, well-defined purpose
- Agents should be configured with appropriate temperature for their task
- Fallback models should be specified for critical agents
- Reviewer agents should use lower temperature for consistency
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
