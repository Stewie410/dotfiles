#!/usr/bin/env bash
# shellcheck disable=SC2053

# find all indicies of specified value
# @param value
# @param array...
# @return number[]|nil
array.index_of() {
    local i count
    for i in "${@:2}"; do
        [[ "${i}" == "${1}" ]] && printf '%d\n' "${count:=0}"
        (( count++ ))
    done
}

# find all indicies that match regex
# @param regex
# @param array...
# @return number[]|nil
array.index_of.regex() {
    local i count
    for i in "${@:2}"; do
        [[ "${i}" =~ ${1} ]] && printf '%d\n' "${count:=0}"
        (( count++ ))
    done
}

# find all indicies that match glob
# @param regex
# @param array...
# @return number[]|nil
array.index_of.glob() {
    local i count
    for i in "${@:2}"; do
        [[ "${i}" == ${1} ]] && printf '%d\n' "${count:=0}"
        (( count++ ))
    done
}

# find first index of specified value
# @param value
# @param array...
# @return number|nil
array.first_index_of() {
    local i count
    for i in "${@:2}"; do
        if [[ "${i}" == "${1}" ]]; then
            printf '%d\n' "${count:=0}"
            return
        fi
        (( count++ ))
    done
}

# find first index matching regex
# @param regex
# @param array...
# @return number|nil
array.first_index_of.regex() {
    local i count
    for i in "${@:2}"; do
        if [[ "${i}" =~ ${1} ]]; then
            printf '%d\n' "${count:=0}"
            return
        fi
        (( count++ ))
    done
}

# find first index of matching glob
# @param glob
# @param array...
# @return number|nil
array.first_index_of.glob() {
    local i count
    for i in "${@:2}"; do
        if [[ "${i}" == ${1} ]]; then
            printf '%d\n' "${count:=0}"
            return
        fi
        (( count++ ))
    done
}

# find last index of specified value
# @param value
# @param array...
# @return number|nil
array.last_index_of() {
    local i val
    val="${1}"
    shift

    for (( i = $# - 1; i >= 0; i-- )); do
        if [[ "${*:i:1}" == "${val}" ]]; then
            printf '%d\n' "${i}"
            return
        fi
    done
}

# find last index of matching regex
# @param regex
# @param array...
# @return number|nil
array.last_index_of.regex() {
    local i rgx
    rgx="${1}"
    shift

    for (( i = $# - 1; i >= 0; i-- )); do
        if [[ "${*:i:1}" =~ ${rgx} ]]; then
            printf '%d\n' "${i}"
            return
        fi
    done
}

# find last index of matching glob
# @param glob
# @param array...
# @return number|nil
array.last_index_of.glob() {
    local i pat
    pat="${1}"
    shift

    for (( i = $# - 1; i >= 0; i-- )); do
        if [[ "${*:i:1}" == ${pat} ]]; then
            printf '%d\n' "${i}"
            return
        fi
    done
}

# find all elements that satisfies passed function
# @param ref(func(x: T): boolean)
# @param array...
# @return number[]|nil
array.find() {
    local i count
    for i in "${@:2}"; do
        (exec "${1}" "${i}") && printf '%d\n' "${count:=0}"
        (( count++ ))
    done
}

# find first element that satisifies passed function
# @param ref(func(x: T): boolean)
# @param array...
# @return number|nil
array.find_first() {
    local i count
    for i in "${@:2}"; do
        if (exec "${1}" "${i}"); then
            printf '%d\n' "${count:=0}"
            return
        fi
        (( count++ ))
    done
}

# find last element that satisfies passed function
# @param ref(func(x: T): boolean)
# @param array...
# @return number|nil
array.find_last() {
    local i fun
    fun="${1}"
    shift

    for (( i = $# - 1; i >= 0; i-- )); do
        if (exec "${fun}" "${*:i:1}"); then
            printf '%d\n' "${i}"
            return
        fi
    done
}
