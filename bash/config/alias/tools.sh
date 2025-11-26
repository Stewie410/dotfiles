#!/usr/bin/env bash

command -v 'apt-mark' &>/dev/null \
    && alias apt-list='apt-mark showmanual'

command -v 'bat' &>/dev/null \
    || alias bat='batcat'

alias cm='chezmoi'

alias ssha='ssh -o "User=root"'
alias scpa='scp -o "User=root"'

alias sshw='ssh -F ${SSH_HOME}/work.conf'
alias scpw='scp -F ${SSH_HOME}/work.conf'

alias tmux='tmux -f ${XDG_CONFIG_HOME}/tmux/tmux.conf'

alias wttr='curl -sf wttr.in'
alias pubip='curl -sf ipinfo.io/ip'
alias ipinfo='curl -sf ipinfo.io/json'
