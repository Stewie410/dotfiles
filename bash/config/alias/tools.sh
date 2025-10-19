#!/usr/bin/env bash

# alias apt-list='apt-mark showmanual'

command -v 'bat' &>/dev/null ||
    alias bat='batcat'

alias che='chezmoi'

alias xelatexmk='latexmk -xelatexmk'
alias cld='xelatexmk -f -synctex=1 interaction=nonstopmode'

alias ssha='ssh -o "User=root"'
alias scpa='scp -o "User=root"'

alias sshw='ssh -F ~/.ssh/work.conf'
alias scpw='scp -F ~/.ssh/work.conf'

alias tmux='tmux -f ~/.config/tmux/tmux.conf'

alias ytdl='yt-dlp'
alias ytdla='yt-dlp --extract-audio'

alias csf='curl --silent --fail'
alias wttr='csf wttr.in'
alias pubip='csf ipinfo.io/ip'
alias ipinfo='csf ipinfo.io/json'
