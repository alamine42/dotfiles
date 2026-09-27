# ~/.zshrc: loads the shared config, then one machine profile.
#
# The profile name is in ~/.config/dotfiles/profile ("server" or "laptop").
# install.sh --profile <name> writes it. With no file, the profile is "server".
# Machine-only settings and secrets go in ~/.zshrc.local, which git never sees.

# Resolve the ~/.zshrc symlink to find the repo.
DOTFILES_DIR="${${(%):-%x}:A:h}"
DOTFILES_PROFILE="$(cat ~/.config/dotfiles/profile 2>/dev/null || echo server)"

source "$DOTFILES_DIR/zsh/common.zsh"
if [[ -f "$DOTFILES_DIR/zsh/$DOTFILES_PROFILE.zsh" ]]; then
    source "$DOTFILES_DIR/zsh/$DOTFILES_PROFILE.zsh"
else
    echo "dotfiles: unknown profile '$DOTFILES_PROFILE'" >&2
fi

# ----- Local overrides -----
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
