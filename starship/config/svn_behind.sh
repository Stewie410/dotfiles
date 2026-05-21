#!/usr/bin/env bash

svn_info() {
    svn --non-interactive info --no-newline "${@}" 2>/dev/null
}

svn_revision() {
    svn_info --show-item 'revision' "${@}"
}

get_remote() {
    __get() {
        svn_revision -r 'HEAD'
    }

    local name
    name="$(svn_info --show-item 'repos-root-url')"
    name="${name##*/}"

    local cache
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship/svn_behind/${name}"

    if ! [[ -s "${cache}" ]]; then
        mkdir -p "${cache%/*}"
        touch -a "${cache}"
        __get > "${cache}"
    else
        local age
        age="$(( $(date '+%s') - $(stat --format='%Y' "${cache}") ))"

        # if >1hr
        if (( age > 3600 )); then
            __get > "${cache}"
        fi
    fi

    cat "${cache}"
}

main() {
    local working remote
    working="$(svn_revision)"
    remote="$(get_remote)"

    (( remote > working )) \
        || return 1

    printf '⇣\n'
    return 0
}

main "${@}"
