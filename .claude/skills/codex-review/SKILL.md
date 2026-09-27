---
name: codex-review
description: Run the codex-review script for an independent Codex CLI review of uncommitted changes. Paid (OpenAI API). Run only when the user asks for it or another skill calls it; never on your own initiative.
---

Run the codex-review script to get an independent AI code review (via Codex CLI) of the current uncommitted changes.

Execute this command:
```
codex-review -C "$PWD"
```

Show the full review output to the user. If the script reports no changes, let the user know. If the script fails, show the error and help troubleshoot.
