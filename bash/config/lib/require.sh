#!/usr/bin/env bash

# Returns true if any names are present in path/environment
#
# @global PATH          $PATH
#
# @param name[]         Items to search for (file/exec, alias, function, builtin)
#
# @exit bool
require.item() {
    command -v "${@}" &>/dev/null
}

# Returns true if all names are present in path/environment
#
# @global PATH          $PATH
#
# @param name[]         Items to search for (file/exec, alias, function, builtin)
#
# @exit bool
require.item.all() {
    local -a list
    mapfile -t list < <(command -v "${@}")
    (( ${#list[@]} == $# )) || return 1
    return 0
}

# Returns true if any names are executables present in path
#
# @global PATH          $PATH
#
# @param name[]         Executables to search for
#
# @exit bool
require.exec() {
    local item count
    while read -r item; do
        [[ "${item}" == *" is /"* && -x "${item##* is }" ]] && return 0
    done < <(command -v "${@}")
    return 1
}

# Returns true if all names are executables present in path
#
# @global PATH          $PATH
#
# @param name[]         Executables to search for
#
# @exit bool
require.exec.all() {
    local item count
    count="$#"
    while (( $# > 0 )); do
        while read -r item; do
            [[ "${item}" == *" is /"* && -x "${item##* is }" ]] || return 1
            (( count-- ))
            break
        done < <(command -V "${1}")
        shift
    done
    (( count == 0 )) || return 1
    return 0
}

# Returns true if any names are aliases present in environment
#
# @param name[]         Aliases to search for
#
# @exit bool
require.alias() {
    local item
    while read -r item; do
        [[ "${item}" == *"is aliased to"* ]] && return 0
    done < <(command -V "${@}")
    return 1
}

# Returns true if all names are aliases present in environment
#
# @param name[]         Aliases to search for
#
# @exit bool
require.alias.all() {
    local item count
    count="$#"
    while (( $# > 0 )); do
        while read -r item; do
            [[ "${item}" == *"is aliased to"* ]] || return 1
            (( count-- ))
            break
        done < <(command -V "${1}")
        shift
    done
    (( count == 0 )) || return 1
    return 0
}

# Returns true if any names are functions present in environment
#
# @param name[]         Functions to search for
#
# @exit bool
require.func() {
    local item
    while (( $# > 0 )); do
        while read -r item; do
            [[ "${item}" == "${1} is a function" ]] && return 0
            break
        done < <(command -V "${1}")
        shift
    done
    return 1
}

# Returns true if all names are functions present in environment
#
# @param name[]         Functions to search for
#
# @exit bool
require.func.all() {
    local item count
    count="$#"
    while (( $# > 0 )); do
        while read -r item; do
            [[ "${item}" == "${1} is a function" ]] || return 1
            (( count-- ))
            break
        done < <(command -V "${1}")
        shift
    done
    (( count == 0 )) || return 1
    return 0
}

# Returns true if any names are shell builtins
#
# @param name[]         Builtins to search for
#
# @exit bool
require.builtin() {
    local item
    while (( $# > 0 )); do
        while read -r item; do
            [[ "${item}" == *"shell builtin" ]] && return 0
            break
        done < <(command -V "${1}")
        shift
    done
    return 1
}

# Returns true if all names are shell builtins
#
# @param name[]         Builtins to search for
#
# @exit bool
require.builtin.all() {
    local item count
    count="$#"
    while (( $# > 0 )); do
        while read -r item; do
            [[ "${item}" == *"shell builtin" ]] || return 1
            (( count-- ))
            break
        done < <(command -V "${1}")
        shift
    done
    (( count == 0 )) || return 1
    return 0
}
