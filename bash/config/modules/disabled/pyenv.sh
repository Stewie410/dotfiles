#!/usr/bin/env bash

[[ -n "${PYENV_ROOT}" ]] && command -v pyenv &>/dev/null && \
    eval "$(pyenv init -)"
