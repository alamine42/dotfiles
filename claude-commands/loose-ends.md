Triage open tasks/issues that don't belong to an epic (or were opened as follow-ups from past planned work), and recommend where they should go.

> **Tracker:** Check the project's CLAUDE.md for whether task tracking is **Beads** (`bd` CLI) or **Linear** (`mcp__linear-server__*` tools; team/workspace named there). CLAUDE.md is authoritative — a leftover `.beads/` dir may remain after a migration, so don't infer from directories. Mapping: epic ↔ Linear project or parent issue; task ↔ issue/sub-issue. Run every tracker read/write below through that tracker.

1/ Identify all the open tasks/issues that do not belong to an epic and/or were opened as follow-ups from past planned work. Make sure these are NOT in-progress.
2/ Review these items, estimate their ROI
3/ Identify which ones are good candidates to be folded into existing epics, but don't make any changes yet
4/ Identify whether any set of those items warrant the creation of a new epic, but don't make any changes yet
5/ Present your findings to me in a simple & concise manner, and tell me what your recommendations are (e.g. "These X tasks should go into this Y epic, these Z tasks need a new epic, and these W tasks are one offs"). Including priorities.
