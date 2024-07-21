#!/usr/bin/env bash
#
# Forward SSH auth requests to Windows or Keychain

req() {
    while (( $# > 0 )); do
        command -v "${1}" &>/dev/null || return 1
        shift
    done
    return 0
}

sock() {
    local listen relay
    listen="UNIX-LISTEN:${SSH_AUTH_SOCK},fork"
    relay="EXEC:'npiperelay.exe -ei -s //./pipe/openssh-ssh-agent',nofork"

    [[ -S "${SSH_AUTH_SOCK}" ]] && rm --force "${SSH_AUTH_SOCK}"

    (setsid socat "${listen}" "${relay}" & disown) &>/dev/null
}

kc() {
    local -a keys
    mapfile -t keys < <(find "${SSH_HOME}" -type f -iname 'id_*')
    keychain --eval --agents 'ssh' "${keys[@]}"
}

if ! [[ -d "/usr/lib/wsl-ssh" ]]; then
    if req 'socat' 'npiperelay.exe'; then
        sock
    elif req 'keychain'; then
        eval "$(kc)"
    else
        printf 'Failed to configure ssh-agent\n' >&2
    fi
fi

unset -f req sock kc
