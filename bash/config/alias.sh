#!/usr/bin/env bash

# Core
alias l='ls'
alias ls='ls --group-directories-first --color=auto --classify'
alias ll='ls -l'
alias la='ls --almost-all'
alias lla='ls -l --almost-all'
alias llh='ls -l --human-readable'
alias llah='ls -l --almost-all --human-readable'

alias mv='mv --interactive'
alias rm='rm --interactive'
alias cp='cp --interactive'

alias grep='grep --color=auto'

# Tools
alias sshw='ssh -F "${HOME}/.ssh/work.conf"'
alias scpw='ssh -F "${HOME}/.ssh/work.conf"'

alias tmux='tmux -f "${XDG_CONFIG_HOME}/tmux/tmux.conf"'

alias wttr='curl -sf wttr.in'
alias pubip='curl -sf ipinfo.io/ip'
alias ipinfo='curl -sf ipinfo.io/json'

# Dev
alias git='git --no-pager'

alias vv='vim -u NONE'
alias nv='nvim -u NONE'

alias compose='docker compose'

alias ipscan='nmap -sn'
alias hnscan='nmap -sU -p137 --script nbstat.nse'

alias shellcheck='shellcheck --color=always'

# WSL
if [[ -n "${WSL_DISTRO_NAME}" ]]; then
    alias clip='/mnt/c/Windows/System32/clip.exe'
    alias explorer='/mnt/c/Windows/explorer.exe'
    # shellcheck disable=SC2139
    alias npiperelay="${WINHOME}/AppData/Local/Microsoft/WinGet/Links/npiperelay.exe"
    alias wezterm='/mnt/c/Program Files/WezTerm/wezterm.exe'
fi
