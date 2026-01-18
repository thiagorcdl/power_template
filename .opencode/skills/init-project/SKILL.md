---
name: init-project
description: Full project initialization workflow from API key setup to GitHub repo creation and issue creation
license: MIT
---

# init-project Skill

## Purpose
Initialize a new project with complete planning and setup workflow.

## When to Use
- Starting a new project from scratch
- Setting up a fork of the power_template for a new codebase
- When you want a complete, AI-assisted project initialization

## Workflow

### Phase 1: Setup and Verification

#### 1.1 Check Environment Variables
Verify required environment variables are set:

```bash
echo $OPENROUTER_API_KEY
echo $GEMINI_API_KEY
echo $GITHUB_TOKEN
```

If any are missing, guide the user to set them:

```bash
# Set in ~/.bashrc or ~/.zshrc for persistence
export OPENROUTER_API_KEY="your-key-here"
export GEMINI_API_KEY="your-key-here"
export GITHUB_TOKEN="your-token-here"
```

#### 1.2 Verify GitHub Authentication
```bash
gh auth status
```

If not authenticated:
```bash
gh auth login
```

### Phase 2: Project Planning

#### 2.1 Gather Requirements
Ask user for:
- Project goal (what problem are you solving?)
- Requirements (functional and non-functional)
- Constraints (latency, scale, cost, security)
- Preferences (languages, frameworks, databases, deployment)

#### 2.2 Create Technical Design
Use Planner Agent to create `docs/technical-design.md` with:
- Project overview
- Architecture
- Data model
- API design
- Security considerations
- Deployment strategy

#### 2.3 Create Execution Plan
Use Planner Agent to create `docs/execution-plan.md` with:
- Task list with priorities
- Dependencies
- Milestones
- Acceptance criteria

### Phase 3: GitHub Setup (Semi-Automated)

#### 3.1 Propose Repository Configuration
Generate proposed repository configuration:
- Repository name (based on project)
- Description
- Visibility (private by default)
- Topics

#### 3.2 Get User Confirmation
Ask user to:
- Confirm proposed configuration
- Or modify as needed

#### 3.3 Create Repository
```bash
gh repo create $REPO_NAME \
  --description "$DESCRIPTION" \
  --$VISIBILITY \
  --topics "$TOPICS"
```

#### 3.4 Create GitHub Issues
Parse execution plan and create issues:
- One issue per task
- Include detailed instructions
- Add dependencies between issues

### Phase 4: Initialize Project Documentation

#### 4.1 Create Project-Specific README
Use Builder Agent to create a new `README.md` for the project:
- Project name and description
- Quick start instructions
- Features overview
- Installation guide
- Usage examples
- Development instructions
- Contributing guidelines
- License information

Replace the template README with project-specific content.

#### 4.2 Commit Initial Setup
Commit the initial setup:
```bash
git add -A
git commit -m "chore: initialize project with [project-name]"
```

#### 4.3 Push to Remote
```bash
git push -u origin master
```

## Usage

```bash
/skill init-project
```

Or with shorter command:
```bash
/init
```

## Required Environment Variables
- `OPENROUTER_API_KEY` - For GLM4.7 and Qwen3 models
- `GEMINI_API_KEY` - For web searching and documentation
- `GITHUB_TOKEN` - For repository creation and issue management

## Required Agents
- `planner` - Creates technical design and execution plan
- `web_searcher` - Researches best practices and options

## Configuration
This skill uses the configuration from `.git/opencode`:
- Model providers (OpenRouter, Gemini)
- Agent configurations
- Skill-specific settings
