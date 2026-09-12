Show me an overview of Epics & Tasks from the project's tracker.

> **Tracker:** Check the project's CLAUDE.md for whether task tracking is **Beads** (`bd` CLI) or **Linear** (`mcp__linear-server__*` tools; team/workspace named there). CLAUDE.md is authoritative — a leftover `.beads/` dir may remain after a migration, so don't infer from directories. Mapping: epic ↔ Linear project or parent issue; task ↔ issue/sub-issue. Run every tracker read/write below through that tracker.

The overview should be in tabular form, where each row is an epic, accompanied with epic ID, epic priority, and a list of titles/summaries of open tasks ordered by priority.

The epics should also be ordered by priority (highest priority at the top). Epics where all the tasks are open should not list all of the task titles, instead they should just say "X/Y Tasks open" where X is the number of open tasks and Y is the total number of tasks.

Closed epics should not be shown.
