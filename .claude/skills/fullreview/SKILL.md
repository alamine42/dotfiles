---
name: fullreview
description: "Full post-feature review pass: UX polish, simplify, design review, and two rounds of code review with fixes. Run only when the user asks for it or another skill calls it; never on your own initiative."
---

Perform the following steps without asking me for confirmation to move to a next step unless there are critical findings that need my input:

1. Run `/improve-ux feature` and incorporate its recommendations.
2. Simplify the code where possible without compromising feature functionality, performance, security or reliability. Run /simplify
3. Run /better-interface (full mode) on the feature's screens and flows, and fix what it finds.
4. Run an independent code review of the changes, then address / fix all the issues raised. Then run it one more time for good measure, and fix those issues too.
   - **Default (no extra cost):** use the built-in /code-review.
   - **High-stakes changes** (auth, payments, data migrations, security boundaries, public API contracts, foundational architecture): tell me why it qualifies and confirm before running /codex-review (paid, OpenAI API) instead. Do not stop the codex review unless it exceeds 30 mins.
   - If I passed `codex` as an argument to this skill, use /codex-review without asking.
5. Then run tests and confirm they all pass. If any fail, fix those too.
6. When all tests pass, give me a clear and concise summary of the work done and ask me if I'm ready to ship it. Title this summary "Full Review" + add a name for the feature, and note which review engine was used (Claude /code-review or Codex).

If I say yes, commit and push the code. Then close the task in Beads (`bd close <id>`), or whatever tracker the project uses (TODO.md, Linear, GitHub Issues, etc.) if beads isn't set up.
