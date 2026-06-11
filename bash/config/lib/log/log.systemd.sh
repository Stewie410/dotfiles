#!/usr/bin/env bash

declare -A __logger_levels=(
    ["emerg"]='0'
    ["alert"]='1'
    ["crit"]='2'
    ["err"]='3'
    ["warn"]='4'
    ["notice"]='5'
    ["info"]='6'
    ["debug"]='7'
)

# Write formatted messages to journald (/dev/fd/4)
# WARN: Message(s) from args will IGNORE stdin!
#
# @global debug?    If true, skip debug lines
# @global err[]?    If declared, append ERROR-like logs to array
#
# @stdin file       Content to write out
#
# @param level      Log "level" (see $__logger_levels)
# @param line[]?    Line(s) to write out
#
# @exit true
log() {
    if (($# > 1)); then
        log "${1}" < <(printf '%s\n' "${@:2}")
        return 0
    fi

    local id
    id="${__logger_levels["${1,,}"]}"

    # shellcheck disable=SC2154
    ((id == 7 && debug != 1)) && return 0

    local -a lines
    local line
    while read -r line; do
        lines+=("${line}")
        printf '<%d>%s\n' "${id}" "${line}" >&4
    done

    # handle missing ${err[@]}
    declare -p 'err' &> /dev/null \
        || local -a err

    ((id <= 3)) && err+=("${lines[@]}")

    return 0
}

# Execute command & log cmd/args via log()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout           Command's normal stdout
# @stderr           Command's normal stderr
# @exit int         Command's exit code
log.debug() {
    local dbg
    printf -v dbg ' %q' "${@}"
    log debug "EXEC: ${dbg:1}"

    "${1}" "${@:2}"
}

# Log message(s) as emergency with log(), then early-fail script
#
# @param line?      Line(s) to write as failure reason (default: Unknown Cause)
#
# @stderr logs[]    Die reason(s)
# @exit false
die() {
    set -- "${1:-Unknown Cause}" "${@:2}"
    log debug "${@}"
    exit 1
}
