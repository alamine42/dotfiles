#!/usr/bin/env bash
# Cloud Claude Code - Dotfiles Installer
# Run this after cloning the dotfiles repo
#
# Usage:
#   git clone git@github.com:YOU/dotfiles.git ~/.dotfiles
#   ~/.dotfiles/install.sh

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

echo "Installing dotfiles from $DOTFILES..."

# Ensure we're in the right place
if [[ ! -f "$DOTFILES/install.sh" ]]; then
    echo "Error: install.sh not found in $DOTFILES"
    echo "Clone the repo first: git clone <repo> ~/.dotfiles"
    exit 1
fi

# Create necessary directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/projects"

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
link_file "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "Linking scripts..."
link_file "$DOTFILES/bin/sessionizer" "$HOME/bin/sessionizer"
chmod +x "$HOME/bin/sessionizer"

echo ""
echo "Done!"
echo ""
echo "Next steps:"
echo "  1. Reload shell: source ~/.zshrc"
echo "  2. Set ntfy topic: echo 'export NTFY_TOPIC=your-topic' >> ~/.zshrc"
echo "  3. Start a project: sessionizer"
echo ""
