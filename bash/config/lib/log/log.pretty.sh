#!/usr/bin/env bash

# Try to determine when to print color
#
# @global NO_COLOR? Force-disable coloring
# @global TERM?     Terminal name to determine color support
#
# @exit bool
__logger.use_color() {
    # https://no-color.org/
    [[ -n "${NO_COLOR}" ]] && return 1

    case "${TERM:-dumb}" in
        "xterm"* | "rxvt"* | "screen"* | "tmux"*) return 0 ;;
        "ansi" | "linux" | "vt100" | "vt220") return 0 ;;
        "alacritty" | "kitty") return 0 ;;
    esac

    [[ -t 1 ]] || return 1
    if command -v 'tput' &> /dev/null; then
        (($(tput colors) > 0)) && return 0
    fi

    return 1
}

# Try to set up logging facilities
#
# @global NO_COLOR?     Force-disable coloring
# @global TERM?         Terminal name to determine color support
#
# @param logger         Logger name: logger.pretty|logger.systemd
# @param preference     Color support preference: always|yes|never|no|auto
# @param logfile?       Logfile path (logger.pretty only)
#
# shellcheck disable=SC2154
__logger.init() {
    # logger.systemd: no colors, no bespoke logfile
    if [[ "${1,,}" == "logger.systemd" ]]; then
        unset log nocolor
        return 0
    fi

    # logger.pretty: color support
    case "${2,,}" in
        "always" | "yes") nocolor="0" ;;
        "never" | "no") nocolor="1" ;;
        "auto")
            __logger.use_color
            nocolor="$?"
            ;;
    esac

    # logger.pretty: logfile
    if ((EUID == 0)); then
        log="/var/log/${log}"
    else
        # handle non-root logfiles
        log="${HOME}/.local/logs/${log}"
    fi
    mkdir -p "${log%/*}"
    touch -a "${log}"

    return 0
}

declare -A __logger_levels=(
    ["emerg"]='EMERGENCY'
    ["alert"]='ALERT'
    ["crit"]='CRITICAL'
    ["err"]='ERROR'
    ["warn"]='WARNING'
    ["notice"]='NOTICE'
    ["info"]='INFO'
    ["debug"]='DEBUG'
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
log() {
    if (($# > 1)); then
        log "${1}" < <(printf '%s\n' "${@:2}")
        return 0
    fi

    local lvl rgb rst
    lvl="${__logger_levels["${1,,}"]}"
    rgb="${__logger_colors["$lvl"]}"
    rst='\e[0m'

    # shellcheck disable=SC2154
    [[ "${lvl}" == "DEBUG" && "${debug}" -ne 1 ]] && return 0
    [[ -n "${nocolor}" ]] && unset rgb rst

    local -a lines
    local line stamp
    while read -r line; do
        lines+=("${line}")
        printf -v stamp '%(%FT%T%z)T' -1
        printf '%s|%b%-9s%b|%s\n' \
            "${stamp}" "${rgb}" "${lvl}" "${rst}" "${line}"
        printf '%s|%-9s|%s\n' \
            "${stamp}" "${lvl}" "${line}" >> "${log:-/dev/null}"
    done

    # handle missing ${err[@]}
    declare -p 'err' &> /dev/null \
        || local -a err

    case "${lvl}" in
        "EMERGENCY" | "ALERT" | "CRITICAL" | "ERROR")
            err+=("${lines[@]}")
            ;;
    esac

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
log.exec() {
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
    log emerg "${@}"
    exit 1
}
