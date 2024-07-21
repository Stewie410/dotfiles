#!/usr/bin/env bash

cheat() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        cat << EOF
Get a cheat-sheet for a command, from cheat.sh

USAGE: ${FUNCNAME[1]} [-h|--help] COMMAND [...]
EOF
        return 0
    fi

    while (( $# > 0 )); do
        curl --silent --fail "cheat.sh/${1}"
        shift
    done
}
