Adversarial design review of the current feature's plan using Codex CLI. This catches architecture flaws, missing edge cases, UX gaps, and task plan issues BEFORE implementation begins.

## Step 1: Gather Context

Identify the current feature being worked on by checking:
1. Git branch name and recent commits
2. Beads tasks in progress (`bd list`)
3. Any PLAN.md, DESIGN.md, SPEC.md, TODO.md, or architecture docs
4. Recent plan files or design discussions in the repo

If you can't determine what feature is being planned, ask the user.

## Step 2: Ensure Design Artifacts Exist

Verify that there are design artifacts to review. The design-review script looks for: PLAN.md, DESIGN.md, SPEC.md, TODO.md, ARCHITECTURE.md, and docs/ equivalents. It also pulls Beads tasks automatically.

If no design artifacts exist, create a new design artifact for feature (markdown file) and name something specific to this feature.

If the design lives in files with non-standard names, note them — you'll pass them via `-f` flags.

## Step 3: Run Codex Design Review

Execute the design-review script, passing any extra files via `-f`:

```
design-review -C "$PWD" [-f extra-file.md ...]
```

Show the full review output to the user. If the script fails, show the error and help troubleshoot.

## Step 4: Incorporate Feedback

Go through each finding from Codex's review:
- **CRITICAL** findings: Incorporate immediately. These represent fundamental flaws.
- **WARNING** findings: Incorporate. These would cause bugs or tech debt.
- **SUGGESTION** findings: Incorporate if they meaningfully improve quality.
- **PRAISE** findings: Note these — preserve what Codex highlighted as good.

Update the relevant design artifacts (PLAN.md, SPEC.md, Beads tasks, etc.) directly. If Codex identifies missing tasks, create them in Beads. If it identifies missing edge cases, add them to the plan.

## Step 5: Summary

Present a concise summary titled "Design Review Complete:"+ a name for the feature with:
1. **Codex's verdict** — Was the design ready, needs revisions, or needs rethinking?
2. **Changes made** — Bullet list of what you changed based on Codex's feedback
3. **Findings ignored** — Any suggestions you skipped and why (if any)
4. **Updated plan** — The revised plan/design in full, so the user can see the final version

Ask the user if they're satisfied with the revised design or want another review pass.
