---
description: Autonomously build an entire epic — test-first, reviewed, tracker updated — then stop at the ship line and report. Never push, deploy, or close the epic.
---

Execute a planned epic end-to-end in one uninterrupted run. You own every technical decision; the user owns the ship decision.

## Target

Argument (if any) may be a task id, epic label (`E3`, `s17`), tracker project name, or phase ("phase 5"). With no argument, the target is the epic from this conversation's context — typically the one just planned. Use the project's tracker of record (per project CLAUDE.md — could be Beads, Linear, or other) to load the epic and its tasks. If you genuinely cannot determine which epic is meant, ask once, up front — never mid-run.

## Test-first (hard constraint)

Before implementing any task's behavior, tests for it must exist and be **run and observed to fail** for the right reason. If the epic already has failing tests (e.g. written during planning), use those — don't duplicate. Then implement to green. Sequencing is your call: per-task or per-milestone red→green both count; presenting after-the-fact tests as verification never does. Tests stay green through any refactoring. Do not skip, stub out, or quietly disable a failing test to get to green.

## Autonomy

Run the whole epic without stopping for approval. Specifically:

- **Technical decisions** (architecture, libraries, CI, infra, naming, trade-offs): decide yourself, note significant ones for the report.
- **Product decisions** (user-visible behavior, copy, scope questions): do NOT block on them. Pick a reasonable default or sequence the work to defer the decision, and batch all such questions into the final report. Interrupt mid-run only if the epic literally cannot proceed on any task without an answer.
- Never ask "shall I continue?", "ready for the next task?", or present per-task plans for sign-off. Assume the user is away (overnight runs are normal).

## Tracker discipline

- Set tasks in progress / closed as you actually start and finish them.
- If a task is claimed or being worked by another agent, leave its state alone and skip it — surface the conflict in the report rather than overwriting.
- Don't silently drop a task: every task in the epic ends the run either done, or explicitly reported as not done and why.
- File follow-up issues for out-of-scope findings, hardening, and loose ends instead of expanding the epic's scope.

## Finish sequence

1. All tasks implemented, full suite green.
2. Run `/fullreview` (or the project's equivalent independent review) over the completed work; fix its findings; suite still green.
3. Remove any test residue — temp files, seeded/fake data, generated artifacts.
4. Local commits are fine and encouraged. **Never** push, deploy, open a PR, merge, or close the epic — individual tasks get closed, the epic stays open. The user is personally the merge gate; a finished, unpushed result is the success state, not an incomplete one.
5. Report concisely: what was built; verification status (tests written-red-then-green, review findings fixed); tracker state; batched product decisions awaiting the user; loose ends (fixed, filed, or honestly admitted). Never claim done with failing tests, skipped tasks, or unaddressed review findings — report shortfalls plainly instead.

Build only what the epic's tasks call for — no extra features or speculative abstractions.
