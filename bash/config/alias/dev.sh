#!/usr/bin/env bash

alias git='git --no-pager'
alias gdf='git --git-dir="${HOME}/dotfiles" --work-tree="${HOME}"'

# alias vv='vim -u NONE'
alias nv='nvim -u NONE'

alias hf='hyperfine'

alias compose='docker compose'

alias ipscan='nmap -sn'
alias hnscan='nmap -sU -p137 --script nbstat.nse'

alias shellcheck='shellcheck --color=always'

alias xml='xmlstarlet'
