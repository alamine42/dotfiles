# Laptop profile: a Mac used directly, without ssh or tmux.
# Keep secrets and project-specific aliases in ~/.zshrc.local, not here.

# ----- Path -----
[[ -x /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.npm-global/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# ----- Prompt -----
export PS1=$'[\033[36;1m%~\033[m\] '

# ----- Aliases -----
alias l='ls -lhG'
alias ll='ls -al'
alias e='subl . &'
alias bp='vi ~/.zshrc'
[[ -f ~/.vimrc ]] && alias vi='vim -u ~/.vimrc'
alias port='pnpm exec portless'

# ----- Claude aliases -----
alias cloudcc='ssh cloudcc -t "~/bin/sessionizer"'
alias cc='claude --permission-mode auto'
alias opus='claude --model opus'
alias fable='claude --model "claude-fable-5[1m]"'
alias accept='claude --model "claude-fable-5[1m]" "/accept"'
