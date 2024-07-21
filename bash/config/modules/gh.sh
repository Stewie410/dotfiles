#!/usr/bin/env bash

gh auth status |& grep --quiet 'Logged in to github' || \
    gh auth login --with-token < "${HOME}/.secrets/gh_auth"
