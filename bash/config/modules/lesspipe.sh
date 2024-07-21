#!/usr/bin/env bash

command -v 'lesspipe' &>/dev/null && \
    eval "$(SHELL="/bin/sh" lesspipe)"
