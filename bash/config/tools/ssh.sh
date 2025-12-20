#!/usr/bin/env bash

service="wsl-ssh-agent.service"
if systemctl --user list-unit-files "${service}" &>/dev/null; then
    if ! systemctl --user is-active "${service}" &>/dev/null; then
        systemctl --user enable --now "${service}"
    fi
fi
unset service
