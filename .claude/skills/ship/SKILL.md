---
name: ship
description: Post-development workflow that runs parallel code review, simplification, and security review, then implements agreed fixes, runs final tests, commits, and closes the tracker task (Beads or Linear). Run only when the user asks for it or another skill calls it; never on your own initiative.
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
│  PHASE 3.5: Consolidate Learnings   │
│  • Run /consolidate if fixes applied│
│  • Capture problems & solutions     │
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
│  • Close task in the tracker        │
│  • Show next available tasks        │
└─────────────────────────────────────┘
```

---

## PHASE 0: Detect Tracker and Current Task

### Resolve the tracker

Check the project's CLAUDE.md for the tracker. It is authoritative — a leftover `.beads/` dir may remain after a migration, so don't infer from directories. Store `TRACKER` as one of:
- `beads` — Beads only (`bd` CLI)
- `beads+linear` — Beads with Linear sync (`bd linear sync`)
- `linear` — Linear only, through the Linear MCP tools (team/workspace named in CLAUDE.md)

If CLAUDE.md names no tracker, ask the user. Every later tracker step branches on `TRACKER`. Mapping: epic ↔ Linear project or parent issue; task ↔ issue/sub-issue.

### Find the current task

**Beads / beads+linear:**
```bash
bd list --status in_progress --format json 2>/dev/null || bd list --format json 2>/dev/null | head -20
```

**Linear:** list issues assigned to the current user in the project's team with a started state (e.g. "In Progress"). If the branch name contains an issue key (e.g. `eng-123-...`), prefer that issue.

Store:
- `TASK_ID` - the Beads ID or Linear issue key (e.g. `ENG-123`)
- `TASK_TITLE` - the task title/subject
- `TASK_PARENT` - the epic: Beads epic, or Linear project / parent issue (if any)

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
- `CREATE_TASKS` - list of items to create as new tracker tasks

---

## PHASE 3: Implement Fixes

For each item in `IMPLEMENT_NOW`:

1. Read the relevant file
2. Apply the fix (use Edit tool)
3. Briefly note what was changed

For each item in `CREATE_TASKS`:

- **Beads / beads+linear:** `bd add "[Security] <issue description>" --epic <TASK_PARENT-if-known>`
- **Linear:** create an issue titled `[Security] <issue description>` in the same team, under `TASK_PARENT` (same project, or as a sub-issue of the parent), with a Security label if the team has one. Put the finding, file anchors and suggested fix in the description.

Report progress as you go.

---

## PHASE 3.5: Consolidate Learnings

If non-trivial fixes were implemented in Phase 3 (especially security fixes, bug fixes, or issues that revealed surprising behavior), run `/consolidate` to capture the learnings.

### When to Consolidate

Run `/consolidate` if ANY of these are true:
- A CRITICAL or HIGH severity security issue was fixed
- A bug or logic error was discovered and fixed
- The fix revealed non-obvious behavior or a gotcha
- The solution required investigation or wasn't immediately apparent

### Skip Consolidation If

- Only minor style/simplification changes were made
- All fixes were trivial (typos, formatting, obvious improvements)
- No `IMPLEMENT_NOW` items were processed

### Execute

If consolidation is warranted:
1. Invoke the `/consolidate` skill
2. Let it extract the problem/solution from the current session
3. It will create a doc in `docs/solutions/{category}/`

This ensures valuable debugging insights are captured before moving to feature documentation.

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
- The tracker task description if available
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
<attribution trailer, if the harness specifies one>
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

- **Beads:** `bd close $TASK_ID`
- **beads+linear:** `bd close $TASK_ID`, then `bd linear sync --push`
- **Linear:** set the issue to the team's completed state (e.g. "Done"). Add a comment with the commit SHA, branch, and PR link if one exists. If the team's GitHub integration closes issues on merge, still set the state, since this push may not merge.

Re-read the task to confirm the close landed.

### Show Next Tasks

List upcoming tasks so the user knows what's next:

- **Beads / beads+linear:** `bd list --status pending --limit 5`
- **Linear:** up to 5 unstarted issues (Todo/Backlog) in `TASK_PARENT`, or the team if there is none, ordered by priority

Store as `NEXT_TASKS` for the final report.

---

## Final Report

Show summary:

```
✅ /ship complete!

📋 Task: <TASK_TITLE> (<TASK_ID>)
📁 Files changed: <count>
🔧 Fixes applied: <count>
📝 Tasks created: <count>
📄 Feature doc: docs/features/FEATURE_<name>.md
📚 Solution doc: docs/solutions/<category>/<slug>.md (if created)
🧪 Tests: passing
📤 Pushed to: <branch>
✔️ Task closed in <tracker>

New tasks created:
- <task-id>: <description>
- ...

📋 Next up:
- <task-id>: <task-title>
- <task-id>: <task-title>
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
- Tracker command fails (`bd` or Linear) → Report the error and suggest manual task closure

---

## Notes

- Works with Beads, Beads with Linear sync, or Linear alone — CLAUDE.md decides which
- Adjust paths (e.g., `cd backend`) based on project structure
- The skill is designed for the Alkemy project but works generically
