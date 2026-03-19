#!/usr/bin/env bash
# shellcheck disable=SC2317

# Try to determine when to print color
#
# @param choice "always"|"yes"|"never"|"no"|"auto"
#
# @exit bool
__logger.use_color() {
    case "${1,,}" in
        "always" | "yes" )  return 0;;
        "never" | "no" )    return 1;;
    esac

    # https://no-color.org/
    [[ -n "${NO_COLOR}" ]] && return 1

    case "${TERM:-dumb}" in
        "xterm"* | "rxvt"* | "screen"* | "tmux"* )  return 0;;
        "ansi" | "linux" | "vt100" | "vt220" )      return 0;;
        "alacritty" | "kitty" )                     return 0;;
    esac

    [[ -t 1 ]] || return 1
    if command -v 'tput' &>/dev/null; then
        (( $(tput colors) > 0 )) && return 0
    fi

    return 1
}

declare -A __logger_levels=(
    ["emerg"]='0,EMERGENCY'
    ["alert"]='1,ALERT'
    ["crit"]='2,CRITICAL'
    ["err"]='3,ERROR'
    ["warn"]='4,WARNING'
    ["notice"]='5,NOTICE'
    ["info"]='6,INFO'
    ["debug"]='7,DEBUG'
)

declare -A __logger_colors=(
    ["EMERGENCY"]='\e[1;31m'
    ["ALERT"]='\e[1;36m'
    ["CRITICAL"]='\e[1;33m'
    ["ERROR"]='\e[0;31m'
    ["WARNING"]='\e[0;33m'
    ["NOTICE"]='\e[0;32m'
    ["INFO"]='\e[1;37m'
    ["DEBUG"]='\e[1;35m'
)

# Write formatted messages to stdout & [$log].
# WARN: Message(s) from args will IGNORE stdin!
#
# @global log?      Append plaintext to path, if set (default: /dev/null)
# @global nocolor?  If true, drop colors from stdout
# @global debug?    If true, skip debug lines
# @global err[]?    If declared, append ERROR-like logs to array
#
# @stdin file       Content to write out
#
# @param level      Log "level" (see $__logger_levels)
# @param line[]?    Line(s) to write out
#
# @stdout logs[]    Formatted log strings
# @exit true
log.pretty() {
    if (( $# > 1 )); then
        log.pretty "${1}" < <(printf '%s\n' "${@:2}")
        return 0
    fi

    local lvl rgb rst
    lvl="${__logger_levels["${1,,}"]#*,}"
    rgb="${__logger_colors["$lvl"]}"
    rst='\e[0m'

    # shellcheck disable=SC2154
    [[ "${lvl}" == "DEBUG" && "${debug}" -ne 1 ]] && return 0
    [[ -n "${nocolor}" ]] && unset rgb rst

    local -a lines
    local line stamp
    while read -r line; do
        lines+=( "${line}" )
        printf -v stamp '%(%FT%T%z)T' -1
        printf '%s|%b%-9s%b|%s\n' \
            "${stamp}" "${rgb}" "${lvl}" "${rst}" "${line}"
        printf '%s|%-9s|%s\n' \
            "${stamp}" "${lvl}" "${line}" >> "${log:-/dev/null}"
    done

    # handle missing ${err[@]}
    declare -p 'err' &>/dev/null \
        || local -a err

    case "${lvl}" in
        "EMERGENCY" | "ALERT" | "CRITICAL" | "ERROR" )
            err+=( "${lines[@]}" )
            ;;
    esac

    return 0
}

# Run command & log stdout & stderr via log.pretty()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout logs[]    Command's stdout stream as log.pretty(info)
# @stderr logs[]    Command's stderr stream as log.pretty(err)
# @exit int         Exit-Code of command executed
log.pretty.exec() {
    exec 98> >(log.pretty info >&1)
    exec 99> >(log.pretty err >&2)

    local dbg
    printf -v dbg ' %q' "${@}"
    read -t 0 _ && dbg+=" </dev/stdin"
    log.pretty debug "EXEC: ${dbg:1}"
    unset dbg

    local result
    ( exec "${@}" ) 1>&98 2>&99
    result="$?"

    exec >&98-
    exec >&99-

    return "${result}"
}

# Run command & log only stdout via log.pretty()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout logs[]    Command's stdout stream as log.pretty(info)
# @stderr stream    Command's stderr stream
# @exit int         Exit-Code of command executed
log.pretty.exec.stdout() {
    exec 98> >(log.pretty info >&1)

    local dbg
    printf -v dbg ' %q' "${@}"
    read -t 0 _ && dbg+=" </dev/stdin"
    log.pretty debug "EXEC_INFO: ${dbg:1}"
    unset dbg

    local result
    ( exec "${@}" ) 1>&98
    result="$?"

    exec >&98-

    return "${result}"
}

# Run command & log only stderr via log.pretty()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout logs[]    Command's stdout stream
# @stderr stream    Command's stderr stream as log.pretty(err)
# @exit int         Exit-Code of command executed
log.pretty.exec.stderr() {
    exec 99> >(log.pretty err >&2)

    local dbg
    printf -v dbg ' %q' "${@}"
    read -t 0 _ && dbg+=" </dev/stdin"
    log.pretty debug "EXEC_ERR: ${dbg:1}"
    unset dbg

    local result
    ( exec "${@}" ) 2>&99
    result="$?"

    exec >&99-

    return "${result}"
}

# Log message(s) as emergency with log.pretty(), then early-fail script
#
# @param line?      Line(s) to write as failure reason (default: Unknown Cause)
#
# @stderr logs[]    Die reason(s)
# @exit false
log.pretty.die() {
    set -- "${1:-Unknown Cause}" "${@:2}"
    log.pretty emerg "${@}"
    exit 1
}

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
log.systemd() {
    if (( $# > 1 )); then
        log.systemd "${1}" < <(printf '%s\n' "${@:2}")
        return 0
    fi

    local id
    id="${__logger_levels["${1,,}"]%%,*}"

    # shellcheck disable=SC2154
[[ "${lvl}" == "DEBUG" && "${debug}" -ne 1 ]] && return 0

    local -a lines
    local line
    while read -r line; do
        lines+=( "${line}" )
        printf '<%d>%s\n' "${id}" "${line}" >&4
    done

    # handle missing ${err[@]}
    declare -p 'err' &>/dev/null \
        || local -a err

    (( id <= 3 )) && err+=( "${lines[@]}" )

    return 0
}

# Run command & log stdout & stderr via log.systemd()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @exit int         Exit-Code of command executed
log.systemd.exec() {
    exec 98> >(log.systemd info)
    exec 99> >(log.systemd err)

    local dbg
    printf -v dbg ' %q' "${@}"
    read -t 0 _ && dbg+=" </dev/stdin"
    log.systemd debug "EXEC: ${dbg:1}"
    unset dbg

    local result
    ( exec "${@}" ) 1>&98 2>&99
    result="$?"

    exec >&98-
    exec >&99-

    return "${result}"
}

# Run command & log only stdout via log.systemd()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout logs[]    Command's stdout stream as log.systemd(info)
# @stderr stream    Command's stderr stream
# @exit int         Exit-Code of command executed
log.systemd.exec.stdout() {
    exec 98> >(log.systemd info)

    local dbg
    printf -v dbg ' %q' "${@}"
    read -t 0 _ && dbg+=" </dev/stdin"
    log.systemd debug "EXEC_INFO: ${dbg:1}"
    unset dbg

    local result
    ( exec "${@}" ) 1>&98
    result="$?"

    exec >&98-

    return "${result}"
}


# Run command & log only stderr via log.systemd()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout logs[]    Command's stdout stream
# @stderr stream    Command's stderr stream as log.systemd(err)
# @exit int         Exit-Code of command executed
log.systemd.exec.stderr() {
    exec 99> >(log.systemd err)

    local dbg
    printf -v dbg ' %q' "${@}"
    read -t 0 _ && dbg+=" </dev/stdin"
    log.systemd debug "EXEC_ERR: ${dbg:1}"
    unset dbg

    local result
    ( exec "${@}" ) 2>&99
    result="$?"

    exec >&99-

    return "${result}"
}

# Log message(s) as emergency with log.systemd(), then early-fail script
#
# @param line?      Line(s) to write as failure reason (default: Unknown Cause)
#
# @stderr logs[]    Die reason(s)
# @exit false
log.systemd.die() {
    set -- "${1:-Unknown Cause}" "${@:2}"
    log.systemd debug "${@}"
    exit 1
}
