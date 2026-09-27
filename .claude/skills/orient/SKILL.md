---
name: orient
description: "Get oriented in a project: read HANDOVER.md if recent, otherwise README, CLAUDE.md, architecture docs, environments and past decisions. Use at the start of a session or when the user asks to get up to speed."
---

# orient
If there is a HANDOVER.md file that's been recently updated, read that file and skip to step 7. Otherwise start from step 1.

1. Read the entire @README.md (if it exists) to understand project goals and structure
2. If there is a docs/architecture.md or similar, read that too
3. Review the overall architecture , key files, the main directories and their purposes. See if any learned lessons and decisions have been documented before, try in docs/ but also elsewhere.
4. Review the various environments (dev/stg/prod) and deployment instructions
5. Review git status, compare current branch against main to understand the differences. Peform a git pull if appropriate.
6. Review the list of open or in-progress tasks
7. Summarize in a concise "Current orientation" block
8. Confirm you're ready to continue
