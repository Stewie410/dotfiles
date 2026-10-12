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
alias scpw='scp -F "${HOME}/.ssh/work.conf"'

alias tmux='tmux -f "${XDG_CONFIG_HOME}/tmux/tmux.conf"'

alias wttr='curl -sf wttr.in'
alias pubip='curl -sf ipinfo.io/ip'
alias ipinfo='curl -sf ipinfo.io/json'

alias texmk='latexmk -xelatex -f -synctex=1 -interaction=nonstopmode'

# Dev
alias git='git --no-pager'

alias vv='vim -u NONE'
alias nv='nvim -u NONE'
#alias nv12='NVIM_APPNAME=nvim-0.12 ~/.local/appimage/nvim-0.12.0.appimage'

alias compose='docker compose'

alias ipscan='nmap -sn'
alias hnscan='nmap -sU -p137 --script nbstat.nse'

alias shchk='shellcheck --color=always'

if [[ -d "${HOME}/.var/app/org.wezfurlong.wezterm" ]]; then
	alias wezterm="flatpak run org.wezfurlong.wezterm"
fi
