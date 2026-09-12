---
description: Audit this repo's CLAUDE.md, AGENTS.md, skills, agents and hooks for context cost, duplication, contradictions and staleness. Proposes cuts; changes nothing without approval.
---

Audit the agentic config for the repo I'm in. Propose only — write nothing until I approve.

## 1. Measure

Run `claude-audit repo "$PWD"` and read the output. It gives you the token cost,
byte-identical copies in other repos, push-policy conflicts, dangling `/command`
and `mcp__*__` references, and any credentials in `.claude/settings*.json`.
Don't recompute what it already measured.

## 2. Classify every line of every instruction file

Read them in full. Assign each rule exactly one bucket, one line of reasoning:

- **Project fact** — build commands, service names, deploy quirks, non-obvious
  layout, which tests are slow. Keep, as terse as it can be stated.
- **Observed-failure correction** — exists because the model actually did the
  wrong thing here, repeatedly. Keep if it still reproduces; mark **re-test** if
  the rule predates the current model and name the task that would prove it.
- **Generic advice** — "write clean code", "handle errors", "add tests", "be
  concise". Remove; the model does this unprompted.
- **Stale** — names a tool, file, command, or workflow that no longer exists. Remove.
- **Duplicate** — same rule in another file, or restated by a skill. Keep one
  copy, at the narrowest scope that still fires.
- **Capability workaround** — step-by-step for something now done in one shot,
  output-format scaffolds, "think step by step". Collapse to the desired outcome.
- **Contradictory** — conflicts with another in-scope rule. Resolve or cut both.
- **Persona/tone** — "you are an expert", "be careful", "world-class". Remove.

Default is remove. An item stays only if you can name the concrete recurring
situation where the model would get it wrong without it. "Seems useful" is not
that.

## 3. For each project skill and subagent

Does it carry knowledge the model lacks, or is it a procedure I could ask for in
one sentence? Mostly-procedure becomes a command or is deleted. Check the
descriptions are distinct enough to fire reliably — overlapping ones mis-trigger
and are a reason to merge.

## 4. Propose

- Rewritten files, with before/after token counts.
- One line per removal saying why.
- Anything shared with sibling repos: say which level it belongs at instead of
  being copied.
- Anything better enforced deterministically: propose the hook, not the prose.
- Re-test items as experiments — the task to run with the rule removed, and what
  the failure would look like.

Then stop and wait.
