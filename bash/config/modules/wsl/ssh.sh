#!/usr/bin/env bash

_check_service() {
    if ! systemctl --user list-unit-files "wsl-ssh-agent.service" &>/dev/null; then
        printf 'Missing /etc/systemd/user/wsl-ssh-agent.service\n' >&2
        return 1
    fi
    if ! systemctl --user is-active "wsl-ssh-agent.service" &>/dev/null; then
        if ! systemctl --user enable --now "wsh-ssh-agent.service" &>/dev/null; then
            printf 'Failed to start /etc/systemd/user/wsl-ssh-agent.service\n' >&2
            return 1
        fi
    fi
    return 0
}

_check_service \
    && export SSH_AUTH_SOCK='/run/user/1000/wsl-ssh-agent.sock'
