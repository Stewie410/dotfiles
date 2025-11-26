#!/usr/bin/env bash

_gh_connected() {
    while read -r REPLY; do
        [[ "${REPLY,,}" == *"logged in to github"* ]] && return 0
    done < <(gh auth status)
    return 1
}

_gh_login() {
    gh auth login --with-token < "${HOME}/.secrets/gh_auth"
}

_gh_connected || _gh_login
unset -f '_gh_connected' '_gh_login'
