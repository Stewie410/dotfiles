#!/usr/bin/env bash

# set all elements to a static value.
# @param value
# @param ref(array)
array.fill() {
    local -n arr="${2}"
    local i
    for i in "${!arr[@]}"; do
        arr["${i}"]="${1}"
    done
}

# set all elements within range to a static value
# @param value
# @param ref(array)
# @param start
# @param end?
array.fill.slice() {
    # shellcheck disable=SC2178
    local -n arr="${2}"
    local i
    for (( i = ${3}; i < ${4:-${#arr[@]}}; i++ )); do
        arr["${i}"]="${1}"
    done
}
