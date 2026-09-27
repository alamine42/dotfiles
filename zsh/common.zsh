# Shared by every profile. Loaded first by ~/.zshrc.

# ----- Path -----
export PATH="$HOME/bin:$HOME/Development/bin:$HOME/.local/bin:$PATH"

# ----- History -----
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# ----- Key bindings -----
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# ----- Completion -----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ----- General aliases -----
alias ll='ls -la'
alias l='ls -lh'
alias ..='cd ..'
alias ...='cd ../..'

# ----- Python/venv aliases -----
alias python='python3'
alias act='source venv/bin/activate 2>/dev/null || source .venv/bin/activate'
alias mkenv='python3 -m venv venv'

# ----- Shell config aliases -----
alias bp='${EDITOR:-vi} ~/.zshrc'
alias sbp='source ~/.zshrc'
alias dotup='"$DOTFILES_DIR/install.sh" && source ~/.zshrc'

# ----- Git aliases -----
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline -20'
alias gco='git checkout'
alias gb='git branch'

# ----- Claude aliases -----
alias c='claude'
