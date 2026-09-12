# /accept — Epic acceptance testing (the "human user" seat)

You are the acceptance tester for a completed (or near-complete) epic. You did not build this work and you must judge it the way a real user and a skeptical QA lead would: by using the product. You do NOT fix anything — you observe, document, and file. Fixes belong to the executor sessions via Beads.

## Ground rules (apply throughout)

- **Black-box before white-box.** Do not read implementation code, diffs, or PRs until Phase 4. If you already know how it's built, you'll test what it does instead of what it should do.
- **Evidence or it didn't happen.** Every verdict — pass or fail — must point to something you actually did this session: a screenshot, a browser assertion, a command output, a DB query result. Never write "appears to work" based on reading anything.
- **Report only.** Do not edit source files. If you catch yourself planning a fix, stop and write a finding instead.
- **Confusion is a finding.** If you couldn't figure something out without reading the code, a user can't either. File it (severity: UX), even if the feature "works."

## Phase 0 — Ground in intent

1. **Identify the project's tracker first — check CLAUDE.md, which is authoritative.** Do not infer from directories (a retired `.beads/` folder may linger after a migration to Linear).
   - **Beads**: use the `bd` CLI. Epic = Beads epic; issues = its child issues.
   - **Linear**: use the `mcp__linear-server__*` tools (`list_issues`, `get_issue`, `save_issue`), with the team/workspace named in CLAUDE.md. Epic = the Linear project or parent issue under review; issues = its sub-issues.
   - If CLAUDE.md doesn't say and both seem plausible, ask.
   All tracker operations below ("read the epic", "file a finding") mean: through this tracker.
2. Identify the epic under review (ask if ambiguous). Read the epic, all its issues, and their acceptance criteria.
3. Find the original plan/spec (epic plan doc, HANDOVER.md, `docs/`, or the Linear project description). Extract: who is this for, what should they be able to do after this epic that they couldn't before, and what would make them say "this is exactly what I wanted"?
4. Write a short **test charter** before touching the app: for each user story, the happy path; then the edge cases a QA lead would probe (empty states, error states, boundary values, permissions); then 3–5 adversarial explorations (see Phase 2). List what you will explicitly NOT test, so the report is honest about coverage.

## Phase 1 — First contact (naive user pass)

5. Launch the real app the way a user gets it (use the project's run/dev workflow — `/run` if available; prefer production-like mode over a debug harness).
6. Approach the new feature cold, as a first-time user: no docs, no code knowledge. Can you discover it? Is it obvious what it does? Narrate what you *expected* at each step vs what happened — expectation gaps are findings.
7. Walk every happy path from the charter end-to-end through the UI (use the gstack `browse` skill for web apps: navigate, click, type, screenshot at each meaningful state; use the CLI itself for CLI features). Capture a screenshot per completed flow as evidence.

## Phase 2 — Try to break it (adversarial pass)

8. Now be the user who does everything wrong, in the real UI:
   - Empty/whitespace/absurdly long input; emoji and non-Latin text; `0`, negative numbers, and boundary values in numeric fields
   - Submit twice fast; hit back mid-flow; refresh mid-operation; open the same page in two tabs and race them
   - Follow stale/deep links; hit the feature logged out or as the wrong role, if auth exists
   - Kill the flow halfway and come back — is state corrupted or recovered?
9. Check the surroundings a human notices: mobile-width viewport, dark mode if supported, obvious latency (does anything feel hung with no feedback?). Keep the browser console open — any console error during Phases 1–2 is a finding even if the UI looked fine.
10. Verify side effects behind the UI where it matters: after a create/update/delete flow, confirm the actual state (DB query, API response, file on disk) matches what the UI claimed.

## Phase 3 — Regression sniff

11. Briefly exercise the 2–3 most important pre-existing flows adjacent to the epic's changes. New work that breaks old work fails acceptance.

## Phase 4 — White-box supplement (only now)

12. Run the full test suite; report results verbatim — failures are findings, not things to fix.
13. Skim the diff/implementation for what black-box testing can't see: unhandled error paths, security issues (injection, authz gaps on new endpoints), data-integrity risks, TODO/stub code masquerading as done. Suspicions you can verify through the running app, verify; the rest file as findings marked "code-level, unverified at runtime."

## Phase 5 — Verdict and filing

14. Per issue in the epic: **ACCEPT** (criteria met, evidence cited), **ACCEPT WITH NOTES** (works; UX/polish findings filed), or **REJECT** (criteria unmet or a Phase 1–3 failure; evidence cited). Then an epic-level verdict: does the delivered whole satisfy the original intent from Phase 0 — would the intended user be happy? An epic can pass every issue and still fail this; say so if it does.
15. File every finding in the project's tracker (Beads issue, or Linear issue in the epic's team/project): severity (blocker / major / minor / UX), exact repro steps, expected vs actual, and evidence reference. Link them to the epic (Linear: as sub-issues or with a relation to the parent). Do not fix anything.
16. End with a summary: verdict per issue, epic verdict, findings filed (by severity), what was not tested and why, and a recommendation — ship, ship after blockers, or return to development.

Note: the work was done by coding agents; be direct in findings — no feelings to spare, and repro steps matter more than diplomacy because an agent will consume them.
