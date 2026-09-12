Perform the following steps without asking me for confirmation to move to a next step unless there are critical findings that need my input:

1. Run the /improve-ux-feature command and incorporate its recommendations intelligently.
2. Simplify the code where possible without compromising feature functionality, performance, security or reliability. Run /simplify
3. Run /design-review
4. Run an independent code review of the changes, then address / fix all the issues raised. Then run it one more time for good measure, and fix those issues too.
   - **Default (no extra cost):** use the built-in /code-review.
   - **High-stakes changes** (auth, payments, data migrations, security boundaries, public API contracts, foundational architecture): tell me why it qualifies and confirm before running /codex-review (paid, OpenAI API) instead. Do not stop the codex review unless it exceeds 30 mins.
   - If I passed `codex` as an argument to this command, use /codex-review without asking.
5. Then run tests and confirm they all pass. If any fail, fix those too.
6. When all tests pass, give me a clear and concise summary of the work done and ask me if I'm ready to ship it. Title this summary "Full Review" + add a name for the feature, and note which review engine was used (Claude /code-review or Codex).

If I say yes, commit and push the code. Then close the task in Beads (`bd close <id>`), or whatever tracker the project uses (TODO.md, Linear, GitHub Issues, etc.) if beads isn't set up.
