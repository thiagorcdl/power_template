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

### Review Phase
1. **Builder Agent** completes work → **Reviewer Agent** reviews changes → **Builder Agent** auto-fixes findings

### PR Review Phase
1. Developer creates PR to master → **Code Reviewer Agent** (Bugbot) reviews PR

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
