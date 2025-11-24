#!/usr/bin/env bash
# shellcheck disable=SC2053

# check if any element matches exact value
# @param search
# @param array...
# @return boolean
array.contains() {
    local search
    for search in "${@:2}"; do
        [[ "${search}" == "${1}" ]] && return 0
    done
    return 1
}

# check if any element matches regex
# @param regex
# @param array...
# @return boolean
array.contains.regex() {
    local search
    for search in "${@:2}"; do
        [[ "${search}" =~ ${1} ]] && return 0
    done
    return 1
}

# check if any element matches glob pattern
# @param glob
# @param array...
# @return boolean
array.contains.glob() {
    local search
    for search in "${@:2}"; do
        [[ "${search}" == ${1} ]] && return 0
    done
    return 1
}
