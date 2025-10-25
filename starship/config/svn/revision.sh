#!/usr/bin/env bash

_info() {
    svn --non-interactive info --no-newline --show-item "${1}"
}

printf 'r%s|r%s' \
    "$(_info 'revision')" \
    "$(_info 'last-changed-revision')"
