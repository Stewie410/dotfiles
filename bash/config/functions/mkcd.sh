#!/usr/bin/env bash

mkcd() {
    _usage() {
        cat <<EOF
Make and change directory

USAGE: mkcd [OPTIONS] PATH

OPTIONS:
    -h, --help          Show this help message
    -d, --date DATE     Make and change to DATE's working directory (see -w)
    -p, --push          Use 'pushd' instead of 'cd'
    -w, --working PATH  Use PATH as working directory parent
                        (default: \$WORKING_DIR or ~/working)
EOF
    }

    _err() {
        printf '\e[0;31mERROR\e[0m: %s\n' "${@}" >&2
    }

    _fdate() {
        date --date="${1}" --iso-8601
    }

    _real() {
        readlink --canonicalize-missing "${1}" && return 0
        _err "Cannot resolve path: ${1}"
        return 1
    }

    local opts date wd push
    wd="${WORKING_DIR:-$HOME/working}"
    opts="$(
        getopt \
            --options hpd:w: \
            --longoptions help,push,date:,working: \
            --name 'mkcd' \
            -- "${@}"
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       _usage; return 0;;
            -d | --date )       date="$(_fdate "${2}")" || return 1; shift;;
            -w | --working )    wd="$(_real "${2}")" || return 1; shift;;
            -p | --push )       push="1";;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    [[ -n "${date}" ]] && set -- "${wd}/${date}"
    mkdir --parents "${1}" || return 1
    if [[ -n "${push}" ]]; then
        pushd "${1}" || return 1
    else
        cd "${1}" || return 1
    fi
    return 0
}

alias mkpd='mkcd -p'
alias mdot='mkcd -pd today'
