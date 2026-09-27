#!/usr/bin/env bash
# Cloud Claude Code - Dotfiles Installer
# Run this after cloning the dotfiles repo
#
# Usage:
#   git clone git@github.com:YOU/dotfiles.git ~/.dotfiles
#   ~/.dotfiles/install.sh                    # cloud dev server (default)
#   ~/.dotfiles/install.sh --profile laptop   # a Mac used directly, no tmux

set -euo pipefail

PROFILE="server"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) PROFILE="${2:-}"; shift 2 ;;
        --profile=*) PROFILE="${1#*=}"; shift ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done
if [[ "$PROFILE" != "server" && "$PROFILE" != "laptop" ]]; then
    echo "Error: --profile must be 'server' or 'laptop'"
    exit 1
fi

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

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
mkdir -p "$HOME/.config/dotfiles"
mkdir -p "$BINDIR"
if [[ "$PROFILE" == "server" ]]; then
    mkdir -p "$HOME/projects"
fi

# ~/.zshrc reads this file to pick the profile.
echo "$PROFILE" > "$HOME/.config/dotfiles/profile"

# Backup existing files
backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        echo "  Backing up existing $file to ${file}.bak"
        mv "$file" "${file}.bak"
    fi
}

# Link a dotfile
link_file() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        rm "$dest"
    fi

    backup_if_exists "$dest"
    ln -sf "$src" "$dest"
    echo "  Linked $dest"
}

echo ""
echo "Linking dotfiles..."
link_file "$DOTFILES/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES/.gitignore_global" "$HOME/.gitignore_global"
if [[ "$PROFILE" == "server" ]]; then
    link_file "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
    link_file "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
fi

echo ""
echo "Linking scripts..."
echo "  Target: $BINDIR"
SCRIPTS=(codex-review design-review claude-audit)
if [[ "$PROFILE" == "server" ]]; then
    SCRIPTS+=(sessionizer)
fi
for script in "${SCRIPTS[@]}"; do
    link_file "$DOTFILES/bin/$script" "$BINDIR/$script"
    chmod +x "$DOTFILES/bin/$script"
done

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

    # Install Playwright browser dependencies (Chromium only for headless server)
    if ! npx -y playwright install --dry-run chromium 2>/dev/null | grep -q "already installed"; then
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
