# Dotfiles Specification

Minimal dotfiles for remote development with Claude Code, optimized for mobile access via SSH.

## Overview

### Purpose

Provide a lightweight, consistent shell environment for:

- Remote development on DigitalOcean droplets
- Local development on macOS
- Mobile-first tmux usage (iPhone/iPad SSH clients)
- Seamless Claude Code integration per project

### Design Principles

1. **Minimal** - Only include what's actively used
2. **Mobile-optimized** - Large touch targets, readable status bars, Ctrl-a prefix
3. **Claude-native** - Auto-launch Claude Code, liberal permissions, notification support
4. **Portable** - Same dotfiles work on macOS and Ubuntu with no OS-specific branching

## Components

### Shell Configuration (.zshrc)

**Core settings:**
- Emacs keybindings (better for mobile)
- 50k history with deduplication
- Case-insensitive completion

**Aliases organized by category:**

| Category | Aliases |
|----------|---------|
| Navigation | `ll`, `l`, `..`, `...` |
| Session | `s` (sessionizer), `t`, `ta`, `tl` |
| Git | `gs`, `gd`, `gds`, `ga`, `gc`, `gp`, `gpl`, `gl`, `gco`, `gb` |
| Docker | `d`, `dc`, `dps`, `dex`, `dlogs` |
| Claude | `c`, `cn` (with notification) |

**Helper functions:**
- `notify()` - Send ntfy.sh push notification
- `claude-notify()` - Run Claude with completion notification
- `p()` - Quick cd to ~/projects/<name>
- `projects()` - List available projects
- `clone()` - Clone repo and create session

**Override pattern:**
- `~/.zshrc.local` is sourced if present
- Use for secrets only (NTFY_TOPIC, API keys)
- Never commit .local files

### tmux Configuration (.tmux.conf)

**Mobile optimizations:**
- `Ctrl-a` prefix (easier than Ctrl-b on mobile keyboards)
- Mouse support enabled
- Top status bar (visible when keyboard is up)
- Minimal status: session name + time only

**Key bindings:**

| Key | Action |
|-----|--------|
| `Ctrl-a \|` | Vertical split |
| `Ctrl-a -` | Horizontal split |
| `Ctrl-a h/j/k/l` | Vim-style pane nav |
| `Alt-Arrow` | Pane nav (no prefix) |
| `Alt-1..5` | Window switch (no prefix) |
| `Ctrl-a s` | Session picker |
| `Ctrl-a r` | Reload config |
| `Ctrl-a m` | Toggle mouse |

**Theme:**
- Catppuccin-inspired colors
- Blue accent for active elements
- Minimal visual noise

### Prompt (starship.toml)

**Visible modules:**
- Directory (truncated to 2 levels)
- Git branch
- Git status (minimal symbols: `!+?` for modified/staged/untracked)
- Docker context (only when relevant)

**Disabled modules:**
- All cloud providers (aws, gcloud, k8s)
- All language versions (nodejs, python, rust, go)

**Rationale:** Keep prompt under 40 characters for mobile readability.

### Git Configuration (.gitconfig)

**User settings:**
- Configured for single user (Mehdi El-Amine)
- Default branch: main

**Push behavior:**
- `autoSetupRemote = true` - Push creates tracking branch automatically
- `default = current` - Push current branch by name

**Aliases:** Standard shortcuts (st, co, br, ci, df, lg)

**No workflow conventions enforced** - Project-specific.

### Session Manager (bin/sessionizer)

**Behavior:**
- `sessionizer` - fzf picker from ~/projects
- `sessionizer <name>` - Direct project by name
- `sessionizer /path` - Absolute path

**Session lifecycle:**
- Creates tmux session named after project
- Auto-launches `claude` command in new sessions
- Multiple Claude instances can run (one per session)
- Sessions persist across switches

**Configuration:**
- `PROJECT_DIR` env var (default: ~/projects)
- `AUTO_CLAUDE` env var (default: true)

**Error handling:**
- Missing fzf: Error with install instructions
- Missing project: Lists available projects
- Claude startup failure: Silent continue (user sees error)

### Claude Code Settings (settings.local.json)

**Permission philosophy:** Liberal trust model

All common development commands are pre-approved:
- Git operations (add, commit, push, restore, checkout)
- npm/node commands (install, test, run, build)
- Docker operations (compose, exec, logs)
- Database access (psql with password)
- Railway deployment commands
- General utilities (curl, jq, find, grep, ls, tree)

**Hook configuration:**
- Stop hook: Play system sound (macOS only, silent fail on Linux)

**Default mode:** acceptEdits

## Planned Enhancements

### 1. Dependency Auto-Installation

**Current state:** install.sh assumes dependencies exist

**Enhancement:** Add dependency installation to install.sh

```bash
# Required dependencies
DEPS=(fzf starship micro tmux)

# Install via apt (requires sudo)
sudo apt update && sudo apt install -y "${DEPS[@]}"
```

**Implementation notes:**
- Require sudo upfront
- Use apt (assumes Ubuntu/Debian on droplet)
- On macOS, assume brew is available or skip

### 2. Git Push Notifications

**Current state:** Only `cn` sends notifications

**Enhancement:** Add notification to git push

Replace `gp` alias with wrapper function:

```bash
gp() {
    if git push "$@"; then
        notify "Push succeeded: $(git branch --show-current) -> $(basename $(git remote get-url origin) .git)"
    else
        notify "Push FAILED: $(git branch --show-current)"
        return 1
    fi
}
```

**Notification content:** Simple success/fail with branch name

## Directory Structure

```
~/.dotfiles/
├── .gitconfig
├── .tmux.conf
├── .zshrc
├── bin/
│   └── sessionizer
├── install.sh
├── README.md
├── SPEC.md
├── settings.local.json    # Not symlinked, reference only
└── starship.toml
```

**Symlink targets:**
- `~/.zshrc` -> `~/.dotfiles/.zshrc`
- `~/.tmux.conf` -> `~/.dotfiles/.tmux.conf`
- `~/.gitconfig` -> `~/.dotfiles/.gitconfig`
- `~/.config/starship.toml` -> `~/.dotfiles/starship.toml`
- `~/bin/sessionizer` -> `~/.dotfiles/bin/sessionizer`

## Installation

### Prerequisites

- Git
- zsh (default shell)
- Internet connection for dependency installation

### Steps

```bash
# Clone to ~/.dotfiles
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/.dotfiles

# Run installer (will prompt for sudo)
~/.dotfiles/install.sh

# Reload shell
source ~/.zshrc

# Set up notifications (optional)
echo 'export NTFY_TOPIC=your-secret-topic' >> ~/.zshrc.local
```

### Updates

Pull changes and symlinks auto-update:

```bash
cd ~/.dotfiles && git pull
```

No explicit update command needed.

## Usage Patterns

### Starting a new project

```bash
mkdir ~/projects/myproject
cd ~/projects/myproject
git init
s myproject  # Creates session, launches Claude
```

### Switching projects

```bash
s            # fzf picker
s otherproj  # Direct switch
```

Multiple Claude instances remain active in their sessions.

### Getting notifications

```bash
# Set topic once
echo 'export NTFY_TOPIC=my-topic' >> ~/.zshrc.local
source ~/.zshrc

# Use claude with notification
cn "build the feature"

# After enhancement: git push auto-notifies
gp
```

### Local overrides

Create `~/.zshrc.local` for:
- `NTFY_TOPIC` - Notification channel
- API keys and secrets
- Machine-specific paths

Never put secrets in the main dotfiles.

## Out of Scope

The following are intentionally not included:

- **Server hardening** - Firewall, fail2ban, SSH config are outside dotfiles scope
- **Git workflow conventions** - Branching strategy is project-specific
- **Docker conventions** - Compose setup is project-specific
- **Multiple project directories** - Single ~/projects root keeps it simple
- **OS-specific configurations** - Same dotfiles work everywhere
- **Editor configuration** - micro is the default; no vim/emacs configs
- **Language version managers** - nvm, pyenv, etc. are project-specific

## Deployment Target

**Primary:** Railway

Railway MCP tools and CLI are pre-approved in permissions. Other platforms (fly.io, Render, Vercel) are not pre-configured but can be added to settings.local.json as needed.
