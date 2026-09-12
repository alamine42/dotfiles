# claude-audit

Two tools that measure and prune the Claude Code config: the `claude-audit`
command, and the `/audit-repo` slash command.

Every command reads only. Nothing is written unless you add `--apply`.

Written 2026-09-05.

---

## Step 0 - Check the install

```bash
claude-audit --help
```

This prints the usage. If the shell says "command not found", open a new
terminal tab and try again.

The tool lives in `dotfiles/bin/claude-audit`. A symlink in
`~/Development/bin/` puts it on the PATH. `install.sh` recreates that symlink
on a new machine.

---

## Step 1 - See where you stand

```bash
claude-audit global
```

This reports six things:

1. The context loaded at every session start, by component.
2. Credentials found in config files, with their git status.
3. Dead config: override keys for skills that do not exist, hooks that point
   at missing files, hook scripts wired to nothing.
4. Instruction files that are byte-identical across repos.
5. The mechanical fixes it can make.
6. The judgment calls it cannot make for you.

Nothing is written.

---

## Step 2 - Look at every repo at once

```bash
claude-audit repo --all
```

One line per repo: token cost, whether it carries a push mandate, whether it
holds a secret. Use this to choose which repo to work on.

---

## Step 3 - Fix the push conflict

Many `AGENTS.md` files carry an old beads instruction: "Work is NOT complete
until git push succeeds." The `/build-it` and `/wrap-up` commands say the
opposite. Both load at the same time, so the model must guess.

The text is stale. Current beads emits a short snippet with no push mandate.

Look first:

```bash
claude-audit agents-md
```

Then write:

```bash
claude-audit agents-md --apply
```

This rewrites the beads section and keeps every hand-written section. It backs
up each file first. It does not commit.

Review the result:

```bash
cd ~/Development/perennial && git diff AGENTS.md
```

Commit each repo the way you normally do.

To undo one file:

```bash
cp ~/Documents/claude-config-backup-2026-09-05/agents-md/perennial__AGENTS.md \
   ~/Development/perennial/AGENTS.md
```

Add `--include-archive` to also change the repos under `ARCHIVE/`.

---

## Step 4 - Clear dead global config

```bash
claude-audit global --apply
```

This removes override keys that name skills that do not exist, and deletes
skill directories that are disabled but still on disk. It backs up
`settings.json` first.

It does not touch prose, credentials, or plugins.

---

## Step 5 - Audit one repo

```bash
cd ~/Development/alkemy
claude-audit repo .
```

Then start a Claude session in that repo and run:

```
/audit-repo
```

The script measures. The command reads each instruction line, sorts it into
one bucket, and proposes what to cut. It waits for your approval.

Start with `alkemy`. It costs 4,430 tokens and the same file sits in four
repos, so it is the largest single win.

---

## Keep it current

Run `claude-audit global` after you install a plugin or a skill.

Run `claude-audit agents-md` after a beads upgrade. It reads `bd onboard` at
run time, so it re-syncs instead of drifting again.

---

## What the tools cannot do

**Rotate keys.** The audit removed the key text from config files. The keys
stay live until you revoke them in each console:

- Anthropic - the key was in `notaligned`
- Linear - three keys, in `alfred`, `schoolr`, and `claude_setup`

**Scope the plugins.** This is the largest saving: about 10,900 tokens per
session. The vercel plugin costs 6,975 tokens and figma costs 3,830. Both load
in every repo. Neither is needed in most of them.

There is no command for this. Decide which projects need each plugin, remove
them from `enabledPlugins` in `~/.claude/settings.json`, then enable them per
project.

---

## Files

| Path | What it is |
|---|---|
| `dotfiles/bin/claude-audit` | the tool |
| `dotfiles/claude-commands/audit-repo.md` | the `/audit-repo` command |
| `~/Development/bin/claude-audit` | symlink that puts it on the PATH |
| `~/Documents/claude-config-backup-2026-09-05/` | backups of every file changed |
