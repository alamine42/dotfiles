# Cloud Claude Code - Remote Development Environment
# ~/.zshrc

# ----- Path -----
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

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

# ----- Session management -----
alias s='sessionizer'
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'

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

# ----- Docker aliases -----
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dex='docker exec -it'
alias dlogs='docker logs -f'

# ----- Claude aliases -----
alias c='claude'
alias cn='claude-notify'

# ----- Ntfy notification helper -----
notify() {
    local topic="${NTFY_TOPIC:-cloudcc}"
    local message="${1:-Task completed}"
    curl -s -d "$message" "ntfy.sh/$topic" > /dev/null 2>&1 &
}

# Claude wrapper with notification on completion
claude-notify() {
    claude "$@"
    local exit_code=$?
    notify "Claude finished in $(basename "$PWD") (exit: $exit_code)"
    return $exit_code
}

# ----- Project helpers -----
# Quick cd to projects
p() {
    cd "$HOME/projects/$1" 2>/dev/null || echo "Project not found: $1"
}

# List projects
projects() {
    ls -1 "$HOME/projects"
}

# Clone and enter project
clone() {
    local repo="$1"
    cd "$HOME/projects" || return
    git clone "$repo"
    local dir=$(basename "$repo" .git)
    cd "$dir" && sessionizer "$dir"
}

# ----- Editor -----
export EDITOR='micro'
export VISUAL='micro'

# ----- Starship prompt -----
eval "$(starship init zsh)"

# ----- Local overrides -----
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
