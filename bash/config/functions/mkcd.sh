#!/usr/bin/env bash

mkcd() {
    _show_help() {
        cat <<EOF
Make and change directory

USAGE: ${FUNCNAME[1]} [OPTIONS] PATH

OPTIONS:
    -h, --help          Show this help message
    -p, --pushd         pushd into directory, instead of cd
    -d, --date DATE     Make and change to DATE's working directory (see -w)
    -w, --working PATH  Use PATH as working directory parent
                        (default: \$WORKING_DIR || ~/working)
EOF
    }

    _fdate() {
        date --date="${1}" --iso-8601
    }

    # TODO: realpath is not portable
    _real() {
        realpath --canonicalize-missing "${1}" && return 0
        printf 'Cannot resolve path: %s\n' "${1}" >&2
        return 1
    }

    local opts date working action
    action="cd"
    working="${WORKING_DIR:-$HOME/working}"
    opts="$(
        getopt \
            --options hpd:w: \
            --longoptions help,pushd,date:,working: \
            --name "${FUNCNAME[0]}" \
            -- "${@}"
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
        -h | --help)
            _show_help
            return 0
            ;;
        -p | --pushd) action="pushd" ;;
        -d | --date)
            date="$(_fdate "${2}")" || return 1
            shift
            ;;
        -w | --working)
            working="$(_real "${2}")" || return 1
            shift
            ;;
        --)
            shift
            break
            ;;
        *) break ;;
        esac
        shift
    done

    [[ -n "${date}" ]] && set -- "${working}/${date}"
    mkdir --parents "${1}" || return 1

    case "${action}" in
    cd) cd "${1}" || return 1 ;;
    pushd) pushd "${1}" || return 1 ;;
    esac

    return 0
}

alias mdot='mkcd -d today'
