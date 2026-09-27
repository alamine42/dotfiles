# Cloud dev server profile: reached over ssh, work runs inside tmux.

# ----- Session management -----
alias s='sessionizer'
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'

# ----- Docker aliases -----
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dex='docker exec -it'
alias dlogs='docker logs -f'

# ----- Ntfy notification helper -----
notify() {
    local topic="${NTFY_TOPIC:-cloudcc}"
    local message="${1:-Task completed}"
    curl -s -d "$message" "ntfy.sh/$topic" > /dev/null 2>&1 &
}

# Claude wrapper with notification on completion
alias cn='claude-notify'
claude-notify() {
    claude "$@"
    local exit_code=$?
    notify "Claude finished in $(basename "$PWD") (exit: $exit_code)"
    return $exit_code
}

# Git push with notification (replaces the plain gp alias from common)
unalias gp 2>/dev/null
gp() {
    local branch=$(git branch --show-current 2>/dev/null)
    local repo=$(basename "$(git remote get-url origin 2>/dev/null)" .git 2>/dev/null || basename "$PWD")

    if git push "$@"; then
        notify "Push succeeded: $branch -> $repo"
    else
        notify "Push FAILED: $branch -> $repo"
        return 1
    fi
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
command -v starship &> /dev/null && eval "$(starship init zsh)"
