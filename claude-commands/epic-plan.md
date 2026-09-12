---
description: Plan an epic — codebase-grounded design, adversarial review, and a complete dependency-ordered tracker handoff that zero-context executors implement without further planning.
argument-hint: "[epic id | epic name | blank = current subject]"
---

# /epic-plan $ARGUMENTS

You are the planner in a planner/executor split. Separate executor sessions — zero shared context with you — will implement this epic issue-by-issue, reading only the tracker. The tracker handoff IS the deliverable; the conversation is disposable. Plan only — implement nothing in this session, and never mark the epic done.

## Scope gate
If the target is really a single focused task with no design ambiguity (a small bug, a one-file tweak), don't manufacture an epic — say so and file it through the lighter issue-writing path instead.

## Resolve epic and tracker
- The argument may be a tracker ID in any style (typos included), an epic name, or absent (plan the conversation's current subject). Resolve it to the real tracker entity first.
- Use the tracker the project's own configuration declares (CLAUDE.md etc.). The declaration is authoritative — ignore stale leftovers from a previous tracker (e.g. an orphaned tracker dir). If the tracker is file-based, find the existing epic/task files and extend that exact format — same fields, ID scheme, layout; never invent a parallel structure. Ask only if no tracker is discoverable.

## Mode
- **Interactive** (default): ask clarifying questions when the answer changes the design, and review proposed UX with the user — any effective medium — before finalizing.
- **Unattended** (user said "don't ask me anything" / queued in a batch): never block on a question. Make the sensible call, record every assumption and judgment call in the durable record, and defer anything truly requiring the user to the final report.

## Produce (outcomes, not a fixed sequence)

1. **Investigate before designing.** Read the actual code: existing patterns, schema and data constraints, adjacent features, test conventions. Never state a codebase fact you didn't verify. Let findings correct the design, and surface pre-implementation risks explicitly — the kind that sink executors mid-flight: tenant/permission isolation, legacy code paths still live, data migrations, backwards compatibility.
2. **Frame the problem** — what this solves and for whom, situated in the product at large.
3. **UX, when the epic has one.** Design the whole experience: entry and exit navigation plus surrounding surfaces (home additions, new settings), not just the feature screens. Skip cleanly for non-UX epics; reuse UX already settled in prior sessions rather than redoing it.
4. **Technical design** at the minimum complexity that still covers performance, reliability, and security.
5. **Verification upfront.** Acceptance-level e2e criteria for the epic — concrete enough that an executor's first act is writing failing tests from them, and a fresh session can verify "done" black-box. Criteria, not test code.
6. **One genuine adversarial review.** An independent pass whose mandate is to break the plan (fresh subagent given only the plan artifacts, or the project's review command) — not self-approval. Every finding is incorporated or explicitly rebutted, in both the design record and the issues. Free review is the default; anything that spends money requires the user's explicit confirmation and is reserved for high-stakes plans — unattended, skip paid review rather than assume approval. If a review tool fails, fall back to a free path and note it; don't rabbit-hole.
7. **Durable record.** The design survives outside chat: the tracker epic body and/or a committed design doc. A plan whose only home is the transcript doesn't exist.
8. **Complete tracker handoff.** Every task needed to deliver the epic, linked to it, dependency-ordered, prioritized, each carrying what a zero-context implementer needs: context (why), scope (what), architecture fit with file anchors (where/how), acceptance criteria and test expectations (done-when). Name the unambiguous starting issue; flag external prerequisites. Fold in or supersede overlapping old issues only when clearly entailed — no other closures.

## Close out
Re-read the tracker to confirm every write actually landed (tool echoes can be stale). The user audits later by asking "do all epics have tasks?" — the answer must be yes from the tracker alone. Then report briefly: decisions made, review findings and their disposition, issues filed and the starting point, calls made unattended, and anything awaiting the user.
