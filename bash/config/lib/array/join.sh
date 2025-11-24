#!/usr/bin/env bash

# concatenate elements by delim into a string
# @param delim
# @param array...
# @return string
array.join() {
    local i str
    str="${2}"
    if (( $# > 2 )); then
        for i in "${@:3}"; do
            str+="${1}${i}"
        done
    fi
    printf '%s\n' "${str}"
}
