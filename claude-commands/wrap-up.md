---
description: End-of-session close-out — teardown, commit/sync, tracker, knowledge capture, handover briefing, and a verified final report.
---

Close out this working session. The deliverable is a truthful report of the project's resting state — the user reads it before walking away. Cardinal rule: **nothing lost**. Every unfinished thread must end with a durable record somewhere findable (a tracker item, or the briefing's remaining-work section — either counts).

**Scope guard**: this is the full close-out ritual, run only when the user asked to wrap up the session. If the user asked for one facet mid-session (just a commit, just a tracker tick, just a briefing refresh), do exactly that facet and reply in the same register as the request — a short confirmation of what you did and touched nothing else. No process hunts, no inventories of what a "real wrap-up" would cover, no close-out framing.

Right-size the ritual: a session where little happened gets a near-empty wrap-up — verify each facet is already clean, say so, done. Re-runs are normal: the user often keeps working after a wrap-up and invokes it again in the same session. A second run is a delta — refresh the briefing in place, record only new tracker changes and new lessons. Never duplicate.

Cover these facets, in whatever order fits.

**Verification honesty (governs every facet)** — Mechanical rules, not aspirations:

- Runtime state (processes, ports, servers) may be reported ONLY from command output you can quote from this session because you actually saw it arrive after a tool call. If you are about to write a command's result and cannot point to the moment you ran that command in this session, you did not run it — write "could not check" instead.
- Know the trap: process tools (ps, lsof, kill, curl) are often unavailable or denied in restricted sessions. A command that was denied or never invoked has NO result. Reporting an expected result as an observed one is fabrication — the single worst defect this close-out can produce, worse than leaving the item unverified.
- The honest line costs nothing: "dev-server state: could not check (no process tools available); removed stale pid file as file hygiene." Removing a stale pid FILE is fine as file hygiene, but it says nothing about live processes. Anything you could not check goes under an explicit "could not verify" list.
- Git evidence is reported the same way: SHAs, push ranges, and status come from git commands genuinely run this session — quote what they returned, nothing more.

An honest limitation beats a confident claim. Numbers in the report must match the evidence you show — if you list three commits, say three.

**Runtime teardown** — Stop dev servers, watchers, and background processes started this session, and confirm they're gone where your tools allow. If nothing was running, check and say so. Anything unverifiable goes under "could not verify", per above.

**Git** — Commit session work with sensible messages and sync per the project's stated convention: CLAUDE.md is authoritative on branch/push policy (some projects push straight to main; others don't push at all). Ask before discarding anything or when a file's disposition is genuinely ambiguous — never silently drop changes. Review what's staged: no secrets, no local-only files.

**Tracker** — The project's CLAUDE.md names the tracker and is authoritative; do NOT infer from directory contents (a leftover `.beads/` dir often survives a migration to Linear). Beads → `bd update` / `bd close`; Linear → the Linear MCP tools; otherwise GitHub Issues, TODO.md, etc. If there is no tracker, verify that and move on — never invent one or close items that aren't done. Close finished items with resolution notes; ensure unfinished work has a durable record.

**Knowledge capture** — Durable lessons from non-trivially-solved problems go in the project's knowledge base in its established format — here, `docs/solutions/<category>/` with frontmatter tags per `docs/solutions/README.md` (the /consolidate command does this). Grep existing docs first and never duplicate an entry. Exercise restraint: a routine session yields zero docs. These docs are project documentation — commit them like normal work.

**Handover briefing** — First discover the project's existing continuity artifact: check the project's own docs/config for a stated briefing location, and look for a prior briefing file whatever its name (HANDOVER.md, NOTES-FOR-NEXT-SESSION.md, etc.). If one exists, refresh THAT file in place — never write a rival file beside a stale one; the next session must find exactly one current briefing. Only when no convention exists, default to `HANDOVER.md` at the repo root (the sibling `/orient` command reads the briefing at next session's start). Write it for an agent, not a human: concrete current state beats narrative recap. Cover: what got done; problems hit and how they were fixed; decisions and the reasoning; gotchas and lessons; remaining work / next steps; a map of the key files. Fully replace the prior content — one file, always current, never appended-to. It must stay out of version control: run `git check-ignore <file>` and add it to `.gitignore` first if it isn't ignored.

**Final report** — End with a concise summary the user can trust: what was stopped (and what couldn't be verified), what was committed/pushed and where (SHAs, push range), tracker changes, docs written, briefing status. Counts and claims must match the evidence shown. Never report a clean state you didn't check.
