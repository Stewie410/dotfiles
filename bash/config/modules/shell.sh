#!/usr/bin/env bash

set -o vi
# stty -ixon
shopt -s \
    histappend \
    cdspell \
    checkwinsize \
    checkjobs \
    cmdhist \
    globstar \
    mailwarn \
    no_empty_cmd_completion
