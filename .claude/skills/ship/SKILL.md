---
name: ship
description: Post-development workflow that runs parallel code review, simplification, and security review, then implements agreed fixes, runs final tests, commits, and closes the Beads task. Use after unit tests pass on a feature or bug fix.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task, AskUserQuestion
---

# /ship - Post-Development Shipping Workflow

Run this skill after unit tests pass on a completed feature or bug fix. It orchestrates code review, simplification, security review, and ships the code.

## Workflow Overview

```
Unit tests pass → /ship
        ↓
┌─────────────────────────────────────┐
│  PHASE 1: Parallel Reviews          │
│  • Code Review Agent                │
│  • Simplify Agent                   │
│  • Security Review Agent            │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│  PHASE 2: Triage Findings           │
│  • Present all findings             │
│  • User decides: fix now / task / skip│
│  • Auto-create tasks for major issues│
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│  PHASE 3: Implement Fixes           │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│  PHASE 4: Document Feature          │
│  • Write FEATURE_<name>.md          │
│  • Context, design, tradeoffs       │
│  • Implementation details           │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│  PHASE 5: Final Verification        │
│  • Lint, type-check, unit tests     │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│  PHASE 6: Commit & Close            │
│  • Auto-generate commit message     │
│  • Git commit and push              │
│  • Close Beads task, sync to Linear │
└─────────────────────────────────────┘
```

---

## PHASE 0: Detect Current Task

Auto-detect the current Beads task:

```bash
# Get current task from Beads
bd list --status in_progress --format json 2>/dev/null || bd list --format json 2>/dev/null | head -20
```

Parse the output to find the task that's in progress. Store:
- `TASK_ID` - the Beads task ID
- `TASK_TITLE` - the task title/subject

If multiple tasks are in progress or none found, ask the user which task this work is for.

Also get the list of changed files:
```bash
git diff --name-only HEAD~1..HEAD 2>/dev/null || git diff --name-only --cached || git diff --name-only
```

Store as `CHANGED_FILES`.

---

## PHASE 1: Parallel Reviews

Launch THREE parallel agents using the Task tool. All three should run simultaneously.

### Agent 1: Code Review

```
Spawn Task agent with subagent_type="code-reviewer"

Prompt:
"Review the following files for code quality issues:
${CHANGED_FILES}

Focus on:
- Logic errors or bugs
- Code smells (duplication, long functions, poor naming)
- Missing error handling
- Performance issues
- Adherence to project conventions

Return a structured list of findings with:
- File and line number
- Severity (high/medium/low)
- Issue description
- Suggested fix"
```

### Agent 2: Simplify

```
Spawn Task agent with subagent_type="general-purpose"

Prompt:
"Review the following files for simplification opportunities:
${CHANGED_FILES}

Focus on:
- Overly complex logic that could be simplified
- Unnecessary abstractions
- Code that could be more readable
- Redundant code that could be removed
- Opportunities to use built-in functions/methods

Return a structured list of simplifications with:
- File and line number
- Current code snippet
- Proposed simplification
- Why it's better"
```

### Agent 3: Security Review

```
Spawn Task agent with subagent_type="code-reviewer"

Prompt:
"Perform a security review of the following files:
${CHANGED_FILES}

Check for:
- Injection vulnerabilities (SQL, command, XSS)
- Authentication/authorization gaps
- Secrets or credentials in code
- Insecure data handling
- Missing input validation
- OWASP Top 10 issues

Categorize each finding as:
- CRITICAL: Must fix before shipping (auth bypass, injection, secrets exposure)
- HIGH: Should fix before shipping (missing validation, insecure defaults)
- MEDIUM: Create task for later (hardening opportunities)
- LOW: Nice to have (defense in depth suggestions)

Return structured findings with severity, description, and remediation."
```

**Wait for all three agents to complete before proceeding.**

---

## PHASE 2: Triage Findings

Consolidate all findings from the three agents into a single report.

### Security Auto-Triage

For security findings, apply this logic:
- **CRITICAL**: Flag as "must fix now" - do not allow skipping
- **HIGH**: Default to "fix now" but allow user override
- **MEDIUM**: Default to "create task"
- **LOW**: Default to "skip" but show to user

### Present Findings to User

Use AskUserQuestion to present findings grouped by category:

```
## Code Review Findings
1. [severity] file:line - description
2. ...

## Simplification Opportunities
1. file:line - description
2. ...

## Security Findings
🔴 CRITICAL (must fix):
1. ...

🟠 HIGH (recommended fix):
1. ...

🟡 MEDIUM (will create task):
1. ...

🟢 LOW (skipping):
1. ...
```

Ask user:
- "Which items should I implement now? (Enter numbers, e.g., '1,3,5' or 'all' or 'none')"
- For MEDIUM security items: "Create tasks for these? (y/n)"

Store user decisions:
- `IMPLEMENT_NOW` - list of items to fix
- `CREATE_TASKS` - list of items to create as new Beads tasks

---

## PHASE 3: Implement Fixes

For each item in `IMPLEMENT_NOW`:

1. Read the relevant file
2. Apply the fix (use Edit tool)
3. Briefly note what was changed

For each item in `CREATE_TASKS`:

```bash
bd add "[Security] <issue description>" --epic <current-epic-if-known>
```

Report progress as you go.

---

## PHASE 4: Document Feature

Create a comprehensive feature document that captures all context for future reference.

### Generate Feature Name

Convert `TASK_TITLE` to a filename-friendly format:
- Remove special characters
- Replace spaces with underscores
- Use UPPER_SNAKE_CASE
- Example: "Add user authentication flow" → `FEATURE_USER_AUTHENTICATION_FLOW.md`

Store as `FEATURE_NAME`.

### Determine Documentation Location

Check for existing docs directory:
```bash
ls -d docs/features 2>/dev/null || ls -d docs 2>/dev/null || echo "."
```

If `docs/features` exists, use it. Otherwise create it:
```bash
mkdir -p docs/features
```

### Gather Context

Read all changed files to understand the implementation:
```bash
git diff --name-only HEAD~5..HEAD | head -20
```

For each significant file, read and analyze:
- What does this file do?
- How does it fit into the architecture?
- What are the key functions/classes?

### Write Feature Document

Create `docs/features/FEATURE_<name>.md` with this structure:

```markdown
# Feature: <TASK_TITLE>

**Task ID:** <TASK_ID>
**Date:** <current date>
**Author:** Claude + <user if known>

## Summary

<2-3 sentence summary of what this feature does and why it was built>

## Context & Motivation

### Problem Statement
<What problem does this solve? What was the pain point?>

### User Story
<As a [user type], I want [goal] so that [benefit]>

### Prior Art
<What existed before? What alternatives were considered?>

## Architecture & Design

### High-Level Design
<How does this feature fit into the overall system?>

```
<ASCII diagram if helpful>
```

### Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| <name> | <file path> | <what it does> |
| ... | ... | ... |

### Data Model Changes
<New tables, columns, or schema changes - if any>

### API Changes
<New endpoints or modifications - if any>

## Implementation Details

### Files Changed

<List each file with a brief description of changes>

- `path/to/file.ts` - <what changed and why>
- ...

### Key Decisions

1. **<Decision 1>**: <What was decided and why>
2. **<Decision 2>**: <What was decided and why>

### Tradeoffs Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| <Option A> | <pros> | <cons> | Chosen / Rejected |
| <Option B> | <pros> | <cons> | Chosen / Rejected |

## Testing

### Test Coverage
<What tests were added?>

### Manual Testing Steps
1. <Step 1>
2. <Step 2>
3. ...

## Security Considerations

<Any security implications? How were they addressed?>

## Future Improvements

<What could be improved later? What was intentionally deferred?>

- [ ] <Improvement 1>
- [ ] <Improvement 2>

## Related

- **Tasks created:** <list any tasks created during /ship>
- **Related features:** <links to related feature docs>
- **External docs:** <links to specs, PRDs, etc.>
```

### Populate the Document

Use information gathered from:
- `TASK_TITLE` and `TASK_ID`
- `CHANGED_FILES` analysis
- Review findings from Phase 1 (what issues were found and fixed)
- The Beads task description if available
- Any existing specs or PRDs in the repo

For sections you can't fully populate (like "Prior Art"), make a best effort or mark as "TBD - to be filled by developer".

### Verify Document

Show the generated document path and a summary to the user:

```
📄 Created: docs/features/FEATURE_<name>.md

Sections populated:
✓ Summary
✓ Context & Motivation
✓ Architecture & Design
✓ Implementation Details
⚠ Testing (partial - please review)
⚠ Security Considerations (please review)

Review the doc? (y/n)
```

If user says yes, show the full document. Accept any edits before proceeding.

---

## PHASE 5: Final Verification

Run the full verification suite (documentation file is now included):

```bash
# From the backend directory (adjust path as needed)
cd backend && npm run lint 2>&1 | tail -50
```

```bash
cd backend && npm run build 2>&1 | tail -30
```

```bash
cd backend && npm test 2>&1 | tail -50
```

If any step fails:
1. Show the error
2. Attempt to fix automatically if it's a simple issue (lint auto-fix, type error)
3. If can't fix, stop and report to user

Only proceed to Phase 6 if all checks pass.

---

## PHASE 6: Commit & Close

### Generate Commit Message

Based on:
- `TASK_TITLE` - the original task
- Changes made in Phase 3
- Files modified

Format:
```
<type>: <concise summary>

<what was done>
<any notable fixes from review>

Closes: <TASK_ID>
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

Where `<type>` is: feat, fix, refactor, chore, docs, test

### Execute

```bash
git add -A
git status
```

Show the status and the generated commit message to user for final approval.

Then:
```bash
git commit -m "<generated message>"
git push origin HEAD
```

### Close Task

```bash
bd close $TASK_ID
bd linear sync --push
```

---

## Final Report

Show summary:

```
✅ /ship complete!

📋 Task: <TASK_TITLE> (<TASK_ID>)
📁 Files changed: <count>
🔧 Fixes applied: <count>
📝 Tasks created: <count>
📄 Documentation: docs/features/FEATURE_<name>.md
🧪 Tests: passing
📤 Pushed to: <branch>
✔️ Task closed in Beads + Linear

New tasks created:
- <task-id>: <description>
- ...
```

---

## Error Handling

If any phase fails critically:
1. Do NOT proceed to commit
2. Report exactly what failed
3. Leave code in current state
4. Suggest next steps

Common failures:
- Tests fail after fixes → Show error, ask user how to proceed
- Git push fails → Check branch protection, auth issues
- Beads command fails → Suggest manual task closure

---

## Notes

- This skill assumes the project uses Beads for task management with Linear sync
- Adjust paths (e.g., `cd backend`) based on project structure
- The skill is designed for the Alkemy project but works generically
