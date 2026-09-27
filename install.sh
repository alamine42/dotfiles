#!/usr/bin/env bash
# Cloud Claude Code - Dotfiles Installer
# Run this after cloning the dotfiles repo. Run it again at any time to
# update: it pulls the repo, then brings every link up to date.
#
# Usage:
#   git clone git@github.com:YOU/dotfiles.git ~/.dotfiles
#   ~/.dotfiles/install.sh                    # first run: cloud dev server
#   ~/.dotfiles/install.sh --profile laptop   # first run: a Mac used directly
#   ~/.dotfiles/install.sh                    # later runs keep the saved profile
#   ~/.dotfiles/install.sh --no-pull          # update links without git pull

set -euo pipefail

ARGS=("$@")
PROFILE=""
PULL=1
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) PROFILE="${2:-}"; shift 2 ;;
        --profile=*) PROFILE="${1#*=}"; shift ;;
        --no-pull) PULL=0; shift ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

# With no --profile, keep the profile from the last run. The first run
# defaults to server.
PROFILE_FILE="$HOME/.config/dotfiles/profile"
if [[ -z "$PROFILE" ]]; then
    PROFILE="$(cat "$PROFILE_FILE" 2>/dev/null || echo server)"
fi
if [[ "$PROFILE" != "server" && "$PROFILE" != "laptop" ]]; then
    echo "Error: --profile must be 'server' or 'laptop'"
    exit 1
fi

# Default to the folder that holds this script, so any clone location works.
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Scripts go where each platform already keeps them and has them on PATH.
if [[ "$(uname)" == "Darwin" ]]; then
    BINDIR="${BINDIR:-$HOME/Development/bin}"
else
    BINDIR="${BINDIR:-$HOME/bin}"
fi

echo "Installing dotfiles from $DOTFILES (profile: $PROFILE)..."

# Ensure we're in the right place
if [[ ! -f "$DOTFILES/install.sh" ]]; then
    echo "Error: install.sh not found in $DOTFILES"
    echo "Clone the repo first: git clone <repo> ~/.dotfiles"
    exit 1
fi

# ----- Update the repo -----
# Pull only when the tree is clean and the pull is a fast-forward. If the
# pull changes this script, run the new copy instead of the old one.
if [[ "$PULL" == 1 && -z "${DOTFILES_PULLED:-}" ]] && git -C "$DOTFILES" rev-parse --abbrev-ref '@{u}' &> /dev/null; then
    echo ""
    echo "Pulling latest changes..."
    if [[ -n "$(git -C "$DOTFILES" status --porcelain)" ]]; then
        echo "  Local changes found, skipping pull"
    else
        before="$(git -C "$DOTFILES" rev-parse HEAD)"
        if git -C "$DOTFILES" pull --ff-only --quiet; then
            after="$(git -C "$DOTFILES" rev-parse HEAD)"
            if [[ "$before" == "$after" ]]; then
                echo "  Already up to date"
            else
                echo "  Updated ${before:0:7} -> ${after:0:7}"
                DOTFILES_PULLED=1 exec "$DOTFILES/install.sh" ${ARGS[@]+"${ARGS[@]}"}
            fi
        else
            echo "  Pull failed, continuing with the local copy"
        fi
    fi
fi

# ----- Dependency Installation -----
# Only the server profile needs these: the laptop profile has no tmux,
# sessionizer, starship, or micro.

install_deps_apt() {
    echo ""
    echo "Installing dependencies via apt..."
    sudo apt update
    sudo apt install -y fzf tmux curl

    # Install starship
    if ! command -v starship &> /dev/null; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Install micro
    if ! command -v micro &> /dev/null; then
        echo "Installing micro..."
        curl https://getmic.ro | bash
        sudo mv micro /usr/local/bin/
    fi
}

install_deps_brew() {
    echo ""
    echo "Installing dependencies via brew..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Please install it first: https://brew.sh"
        echo "Skipping dependency installation."
        return 0
    fi
    brew install fzf tmux starship micro
}

install_dependencies() {
    echo ""
    echo "Checking dependencies..."

    local missing=()
    for dep in fzf tmux starship micro; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "All dependencies already installed."
        return 0
    fi

    echo "Missing: ${missing[*]}"

    if [[ "$(uname)" == "Darwin" ]]; then
        install_deps_brew
    else
        install_deps_apt
    fi
}

if [[ "$PROFILE" == "server" ]]; then
    install_dependencies
fi

# Create necessary directories
mkdir -p "$(dirname "$PROFILE_FILE")"
mkdir -p "$BINDIR"
if [[ "$PROFILE" == "server" ]]; then
    mkdir -p "$HOME/projects"
fi

# ~/.zshrc reads this file to pick the profile.
echo "$PROFILE" > "$PROFILE_FILE"

# Backup existing files. Never overwrite an older backup.
backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        local backup="${file}.bak"
        [[ -e "$backup" ]] && backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        echo "  Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

# Link a dotfile. Does nothing when the link is already correct.
link_file() {
    local src="${1%/}"
    local dest="$2"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        return 0
    fi
    if [[ -L "$dest" ]]; then
        rm "$dest"
    fi

    backup_if_exists "$dest"
    ln -s "$src" "$dest"
    echo "  Linked $dest"
}

# Remove a link that this repo made but the current profile does not use.
unlink_ours() {
    local dest="$1"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$DOTFILES"/* ]]; then
        rm "$dest"
        echo "  Removed $dest"
    fi
}

# Remove links into this repo whose target no longer exists, for example
# a script or skill that was deleted from the repo.
prune_dead_links() {
    local dir="$1" link
    [[ -d "$dir" ]] || return 0
    for link in "$dir"/*; do
        if [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == "$DOTFILES"/* ]]; then
            rm "$link"
            echo "  Removed dead link $link"
        fi
    done
}

echo ""
echo "Linking dotfiles..."
link_file "$DOTFILES/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES/.gitignore_global" "$HOME/.gitignore_global"
if [[ "$PROFILE" == "server" ]]; then
    link_file "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
    link_file "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
else
    unlink_ours "$HOME/.tmux.conf"
    unlink_ours "$HOME/.config/starship.toml"
fi

echo ""
echo "Linking scripts..."
echo "  Target: $BINDIR"
SCRIPTS=(codex-review design-review claude-audit)
if [[ "$PROFILE" == "server" ]]; then
    SCRIPTS+=(sessionizer)
else
    unlink_ours "$BINDIR/sessionizer"
fi
for script in "${SCRIPTS[@]}"; do
    link_file "$DOTFILES/bin/$script" "$BINDIR/$script"
    chmod +x "$DOTFILES/bin/$script"
done
prune_dead_links "$BINDIR"

case ":$PATH:" in
    *":$BINDIR:"*) ;;
    *) echo "  Warning: $BINDIR is not on your PATH" ;;
esac

echo ""
echo "Linking Claude skills..."
mkdir -p "$HOME/.claude/skills"
for skill_dir in "$DOTFILES/.claude/skills"/*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")
        link_file "$skill_dir" "$HOME/.claude/skills/$skill_name"
    fi
done
prune_dead_links "$HOME/.claude/skills"

echo ""
echo "Configuring Claude MCP servers..."
if command -v claude &> /dev/null; then
    # Add Playwright MCP for UI testing
    if ! claude mcp list 2>/dev/null | grep -q "playwright"; then
        claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest
        echo "  Added Playwright MCP"
    else
        echo "  Playwright MCP already configured"
    fi

    # Install Playwright browser dependencies (Chromium only for headless server).
    # The dry run lists the install folders; all of them exist once installed.
    pw_dirs="$(npx -y playwright install --dry-run chromium 2>/dev/null | sed -n 's/^ *Install location: *//p')"
    pw_missing=0
    [[ -z "$pw_dirs" ]] && pw_missing=1
    while IFS= read -r dir; do
        [[ -n "$dir" && ! -d "$dir" ]] && pw_missing=1
    done <<< "$pw_dirs"
    if [[ "$pw_missing" == 1 ]]; then
        echo "  Installing Playwright browsers (this may take a moment)..."
        npx -y playwright install --with-deps chromium
        echo "  Installed Playwright browsers"
    else
        echo "  Playwright browsers already installed"
    fi
else
    echo "  Claude CLI not found, skipping MCP setup"
fi

echo ""
echo "Done!"
echo ""
echo "Next steps:"
echo "  1. Put secrets and machine-only settings in ~/.zshrc.local"
if [[ "$PROFILE" == "server" ]]; then
    echo "  2. Set ntfy topic: echo 'export NTFY_TOPIC=your-topic' >> ~/.zshrc.local"
    echo "  3. Reload shell: source ~/.zshrc"
    echo "  4. Start a project: sessionizer"
else
    echo "  2. Reload shell: source ~/.zshrc"
fi
echo ""
