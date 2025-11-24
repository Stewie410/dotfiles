#!/usr/bin/env bash
# shellcheck disable=SC2178

# reverse order of array elements in-place (no extdebug)
# @param ref(array)
array.reverse() {
    local -n arr="${1}"
    local i

    (( ${#arr[@]} == 1 )) && return
    shift
    for (( i = ${#arr[@]} - 1; i >= 0; i-- )); do
        set -- "${@}" "${i}"
    done
    arr=( "${@}" )
}

# remove & return last element of array
# @param ref(array)
# @return T
array.pop() {
    local -n arr="${1}"
    printf '%s\n' "${arr[-1]}"
    unset 'arr[-1]'
}

# remove and return first element of array
# @param ref(array)
# @return T
array.shift() {
    local -n arr="${1}"
    printf '%s\n' "${arr[0]}"
    arr=( "${arr[@]:1}" )
}
