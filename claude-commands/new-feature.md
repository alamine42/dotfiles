I want to queue up development of a feature. Ask me to summarize the description of this feature in 1-2 sentences, first.

> **Tracker:** Check the project's CLAUDE.md for whether task tracking is **Beads** (`bd` CLI) or **Linear** (`mcp__linear-server__*` tools; team/workspace named there). CLAUDE.md is authoritative — a leftover `.beads/` dir may remain after a migration, so don't infer from directories. Mapping: epic ↔ Linear project or parent issue; task ↔ issue/sub-issue. Run every tracker read/write below through that tracker.

Then use this description to identify whether an epic or task already exists in the tracker for this feature. make sure that task description comprehensively encompasses everything what the feature I'm talking about. If there are any gaps, identify them.

If the feature is not completely clear to you, ask me interview questions using the AskUserQuestions tool until you are satisfied that you are clear on all the requirements, tradeoffs, and implementation choices.

If the feature doesn't already exist in the tracker, or if gaps exist, create the necessary epic with all the requisite requirements needed to develop a technical implementation plan.
