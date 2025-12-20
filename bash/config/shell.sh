#!/usr/bin/env bash

set -o vi
# stty -ixon

shopts=(
    'histappend'
    'cdspell'
    'checkwinsize'
    'checkjobs'
    'cmdhist'
    'globstar'
    'mailwarn'
    'no_empty_cmd_completion'
)
shopt -s "${shopts[@]}"
unset shopts

bind 'Space:magic-space'
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set show-all-if-ambiguous'
