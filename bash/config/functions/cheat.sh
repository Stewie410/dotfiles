#!/usr/bin/env bash

cheat() {
    _show_help() {
        cat <<EOF
Get a cheat-sheet for a command

USAGE: ${FUCNNAME[1]} [-h|--help] COMMAND
EOF
    }

    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        _show_help
        return 0
    elif (($# == 0)); then
        printf 'No command specified\n' >&2
        return 1
    fi

    curl --silent --fail "cheat.sh/${1}"
}
