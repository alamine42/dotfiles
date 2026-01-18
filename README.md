# Dotfiles - Cloud Claude Code

Minimal dotfiles for remote development with Claude Code on a DigitalOcean droplet.

## What's Included

| File | Purpose |
|------|---------|
| `.zshrc` | Shell config with aliases and helpers |
| `.tmux.conf` | Mobile-optimized tmux (Ctrl-a prefix, mouse support) |
| `.gitconfig` | Git settings and aliases |
| `starship.toml` | Minimal prompt config |
| `bin/sessionizer` | Project session manager |

## Installation

```bash
# On the droplet
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
source ~/.zshrc
```

## Key Features

### Sessionizer

Quick project switching with auto-launching Claude:

```bash
s                  # fzf picker
s myproject        # direct name
sessionizer /path  # absolute path
```

### Aliases

```bash
# Session management
s      → sessionizer
ta     → tmux attach
tl     → tmux list-sessions

# Git
gs     → git status
gd     → git diff
ga     → git add
gc     → git commit
gp     → git push

# Docker
dps    → docker ps
dc     → docker compose
dex    → docker exec -it

# Claude
c      → claude
cn     → claude-notify (sends push when done)
```

### Notifications

Set your ntfy topic:
```bash
echo 'export NTFY_TOPIC=my-secret-topic' >> ~/.zshrc
```

Then use `cn` (claude-notify) to get push notifications when tasks complete.

### tmux Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl-a` | Prefix (not Ctrl-b) |
| `Ctrl-a |` | Vertical split |
| `Ctrl-a -` | Horizontal split |
| `Ctrl-a h/j/k/l` | Navigate panes |
| `Ctrl-a s` | Session picker |
| `Ctrl-a r` | Reload config |
| `Alt-1..5` | Switch windows (no prefix) |

## Customization

After install, add local overrides:

```bash
# ~/.zshrc.local (sourced if exists)
export NTFY_TOPIC=my-topic
alias myalias='...'
```
