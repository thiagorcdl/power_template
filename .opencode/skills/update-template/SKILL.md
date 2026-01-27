---
name: update-template
description: Sync agent and skill definitions from the original power_template repository
license: MIT
---

# update-template Skill

## Purpose
Sync agent and skill definitions from the original power_template repository to keep project template files up to date without losing project progress.

## When to Use
- When the power_template repository has been updated with new agent instructions
- When skill definitions have been improved in the template
- When you want to apply fixes or improvements to agent behaviors
- After a significant period of development when template may have evolved
- When starting work on a new feature and want to ensure agents have latest instructions

## Workflow

### Phase 1: Validate Project

#### 1.1 Verify Power Template Project
Check that the current directory is a valid power_template project:
- Check for `.opencode/` directory
- Verify `.opencode/agents/` exists
- Verify `.opencode/skills/` exists
- Confirm the project was created from the template

#### 1.2 Check for Script
Verify that `scripts/sync-template.sh` exists:
```bash
ls scripts/sync-template.sh
```

If script is missing:
- Print error message
- Recommend running this skill from a power_template project
- Suggest checking if project was created from template

### Phase 2: Run Sync Script

#### 2.1 Execute Dry Run (Default)
Run the sync script in dry-run mode first:
```bash
./scripts/sync-template.sh --dry-run || true
```

Actually, the script is interactive, so just run:
```bash
./scripts/sync-template.sh
```

The script will:
1. Clone/update the original template repository
2. Compare agent files (builder, planner, reviewer, web-searcher, code-reviewer)
3. Compare skill files (execute-plan, init-project, fix-review-issues, update-stack-config, detect-stack)
4. Compare config files (opencode/default-config.json)
5. Compare documentation files (AGENTS.md, README.md)
6. Compare workflow files (.github/workflows/gemini-review.yml)
7. Compare script files (scripts/sync-template.sh - detects its own updates!)
8. Show differences between current project and original template
9. Prompt for confirmation before applying changes

#### 2.2 Show What Would Be Updated
For each file with differences, show:
- File path
- Brief summary of changes (diff output)
- Total count of files that would be updated

### Phase 3: Apply Updates (User Confirmed)

#### 3.1 Update Files
After user confirmation, the script will:
- Copy updated agent files from template to project
- Copy updated skill files from template to project
- Preserve existing files if no differences found

#### 3.2 Commit Changes
After files are updated:
```bash
git add .opencode/agents/ .opencode/skills/
git commit -m "chore: sync agent and skill definitions with template"
```

Commit message can be customized by user.

### Phase 4: Verify

4.1 Check Git Status
```bash
git status
```

Confirm that these files were modified:
- `.opencode/agents/` and `.opencode/skills/` (agent and skill definitions)
- `opencode/default-config.json` (configuration)
- `AGENTS.md` and `README.md` (documentation)
- `.github/workflows/` (workflows)
- `scripts/sync-template.sh` (the sync script itself!)

#### 4.2 Verify Files Not Affected
Ensure these were NOT modified:
- `docs/` (technical design, execution plan)
- `.operational/` (project state)
- Project source code
- Any other project-specific files

### Phase 5: Continue Work

#### 5.1 Resume Previous Work
After successful sync, the user can:
- Continue with execute-plan skill if in middle of implementation
- Resume development work
- Use updated agent instructions for future tasks

#### 5.2 Apply to In-Progress Work
If currently running execute-plan:
- The builder agent will now use updated instructions
- Self-unblocking strategy will be in effect (if newly added)
- Other agent improvements will apply to future tasks

## Usage

### Basic Usage
```bash
/skill update-template
```

### With Dry Run
The script is interactive and always shows what would be changed first:
```bash
/skill update-template
```

Then select option 1 from the menu to see differences without applying changes.

### From Different Directory
If project is not in current directory, specify path:
```bash
/skill update-template --project /path/to/project
```

## Required Environment Variables
None required

## Optional Environment Variables

- `PROJECT_DIR`: Path to power_template project (overrides auto-detection)
- `SKIP_COMMIT`: Set to "1" to skip git commit after sync

## Required Agents

- `builder`: Runs the sync script and manages git operations

## Error Handling

### Script Not Found
```
Error: scripts/sync-template.sh not found
This project may not have been created from the power_template repository.

To manually add the script, copy it from:
https://github.com/thiagorcdl/power_template/blob/master/scripts/sync-template.sh
```

### Invalid Project
```
Error: Not a valid power_template project (missing .opencode directory)

Please ensure you are running this skill from a directory that was created
from the power_template repository.
```

### No Internet Connection
```
Error: Failed to clone original template repository
Check your internet connection and try again.
```

### Git Merge Conflicts
```
Error: Git commit failed
There may be merge conflicts or other issues.

Please resolve manually:
  1. Run 'git status' to see the issue
  2. Resolve conflicts or fix the issue
  3. Run 'git commit' to complete the update
```

## Success Criteria

1. ✅ Valid power_template project detected
2. ✅ sync-template.sh script located
3. ✅ Original template cloned/fetched successfully
4. ✅ Differences between project and template shown
5. ✅ User confirms before applying changes
6. ✅ Agent and skill files updated
7. ✅ Only .opencode/ files modified
8. ✅ Changes committed with descriptive message
9. ✅ Project docs, code, and state untouched

## What Gets Updated

The following files are synced from the template:

### Agent Files
- `.opencode/agents/builder.md`
- `.opencode/agents/planner.md`
- `.opencode/agents/reviewer.md`
- `.opencode/agents/web-searcher.md`
- `.opencode/agents/code-reviewer.md`

### Skill Files
- `.opencode/skills/execute-plan/SKILL.md`
- `.opencode/skills/init-project/SKILL.md`
- `.opencode/skills/fix-review-issues/SKILL.md`
- `.opencode/skills/update-stack-config/SKILL.md`
- `.opencode/skills/detect-stack/SKILL.md`

### Config Files
- `opencode/default-config.json`

### Documentation Files
- `AGENTS.md`
- `README.md`

### Workflow Files
- `.github/workflows/gemini-review.yml`

### Script Files
- `scripts/sync-template.sh` (self-updating!)

## What Does NOT Get Updated

These files are never modified by the sync:
- `docs/technical-design.md` - your project's technical design
- `docs/execution-plan.md` - your project's execution plan
- `.operational/` - your project state and TODOs
- Your source code (src/, lib/, etc.)
- Configuration files specific to your project
- Any files outside of the sync list (agents, skills, config, documentation, workflows, scripts)

## Example Session

```bash
$ /skill update-template

[Validate Project]
✓ Valid power_template project found
✓ Sync script found: scripts/sync-template.sh

[Run Sync Script]
Cloning original template repository...
✓ Template repository ready

Comparing Agent files...

  [WARNING] Differences found: agents/builder.md
  --- Differences for agents/builder.md ---
  --- /tmp/power_template_original/.opencode/agents/builder.md
  +++ /home/user/project/.opencode/agents/builder.md
  @@ -50,6 +50,66 @@
    - Follow project-specific style guides
    - Use auto-formatters when available
    
   +## Self-Unblocking Strategy
   +
   +**CRITICAL**: Before asking for human intervention...

  [SUCCESS] Already up to date: agents/planner.md
  [SUCCESS] Already up to date: agents/reviewer.md

Comparing Skill files...

  [WARNING] Differences found: skills/execute-plan/SKILL.md
  --- Differences for skills/execute-plan/SKILL.md ---

  [SUCCESS] Already up to date: skills/init-project/SKILL.md

Comparing Config files...

  [SUCCESS] Already up to date: opencode/default-config.json

Comparing Documentation files...

  [WARNING] Differences found: README.md
  --- Differences for README.md ---

Comparing Workflow files...

  [SUCCESS] Already up to date: .github/workflows/gemini-review.yml

Comparing Script files...

  [WARNING] Differences found: scripts/sync-template.sh
  --- Differences for scripts/sync-template.sh ---
  [Self-update detected!]

[Menu]
1) Compare all files (dry run)
2) Compare and update all files
3) Show full diff for specific file
4) Exit

Select option [1-4]: 2

Do you want to proceed with the updates? [y/N]: y

Updating Agent files...
  [SUCCESS] Updated: agents/builder.md

Updating Skill files...
  [SUCCESS] Updated: skills/execute-plan/SKILL.md

Updating Documentation files...
  [SUCCESS] Updated: README.md

Updating Script files...
  [SUCCESS] Updated: scripts/sync-template.sh (self-update!)

Summary:
  - Updated: 4 files
  - Created: 0 files

Do you want to commit the changes? [y/N]: y
Checking git status...
Changes to be committed:
  modified:   .opencode/agents/builder.md
  modified:   .opencode/skills/execute-plan/SKILL.md
  modified:   README.md
  modified:   scripts/sync-template.sh

Enter commit message [default: chore: sync template definitions and files]:
chore: add self-unblocking strategy and update documentation

[SUCCESS] Changes committed successfully

✓ Template sync completed successfully!

Updated files:
  - .opencode/agents/builder.md
  - .opencode/skills/execute-plan/SKILL.md
  - README.md
  - scripts/sync-template.sh (self-updated!)

Your project now has the latest agent and skill definitions.
Your work in docs/, .operational/, and source code is preserved.
```

## Troubleshooting

### "Script not found"
Check if scripts directory exists:
```bash
ls -la scripts/
```

If missing, the project may have been created from an older version of the template. Copy the script manually.

### "Template clone failed"
Check internet connection and try again:
```bash
ping github.com
```

### "Permission denied"
Make the script executable:
```bash
chmod +x scripts/sync-template.sh
```

### "Git commit failed"
Check git status:
```bash
git status
```

There may be uncommitted changes or merge conflicts. Resolve manually before running sync again.

### "Only some files updated"
This is normal behavior. Files that match the template are not updated. Only changed files are replaced.

## Best Practices

- **Run dry-run first**: Always select option 1 first to see what will change
- **Review differences**: Look at the diff output to understand what's changing
- **Commit separately**: The script commits changes, so your current work should be committed first
- **Test after sync**: If you're in the middle of execute-plan, continue work to verify agents behave correctly
- **Document in project**: Note template updates in your project's changelog or notes

## Advanced Usage

### Update Specific Files
Use option 3 to see full diff for specific files:
```
3) Show full diff for specific file

Available files:
  - agents/builder.md
  - skills/execute-plan/SKILL.md

Enter file path to show diff: agents/builder.md
```

### Manual Sync
If you prefer manual control, you can run the script directly:
```bash
./scripts/sync-template.sh
```

Or specify a different project:
```bash
./scripts/sync-template.sh /path/to/other/project
```

### Skip Commit
If you want to review changes before committing, set the environment variable:
```bash
SKIP_COMMIT=1 /skill update-template
```

## Related Skills

- `/skill init-project` - Initialize a new project from the template
- `/skill execute-plan` - Execute tasks using the (potentially updated) agent instructions
- `/skill fix-review-issues` - Fix issues found during code review

## Related Documentation

- `AGENTS.md` - Documentation of all agents
- `SKILLS.md` - Documentation of all skills
- `.opencode/agents/*.md` - Individual agent documentation
- `.opencode/skills/*/SKILL.md` - Individual skill documentation
