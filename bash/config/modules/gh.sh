#!/usr/bin/env bash

if command -v 'gh' &>/dev/null; then
    token="${HOME}/.secrets/gh_auth"
    if [[ -s "${token}" ]]; then
        mapfile -t gh_auth < <(gh auth status 2>&1)
        if [[ "${gh_auth[*],,}" != *"logged in to github"* ]]; then
            gh auth login --with-token < "${token}"
        fi
    fi
    unset token gh_auth
fi
