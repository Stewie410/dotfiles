#!/usr/bin/env bash

# defaults to false
__supports_colors() {
    [[ -n "${NO_COLOR}" || "${CLI_COLOR}" == "0" ]] && return 1
    [[ -n "${FORCE_COLOR}" ]] && return 0
    [[ -t 1 ]] || return 1
    if command -v 'tput' &>/dev/null; then
        (( $(tput colors) > 0 )) && return 0
    fi
    if [[ -n "${TERM}" && "${TERM}" != "dumb" ]]; then
        case "${TERM}" in
            "xterm"* | "rxvt"* | "screen"* | "tmux"* )              return 0;;
            "ansi" | "linux" | "vt100" | "vt220" | "alacritty" )    return 0;;
        esac
    fi
    return 1
}

declare -a __log_level_colors=(
    '\e[1;31m' # emerg
    '\e[1;36m' # alert
    '\e[1;33m' # crit
    '\e[0;31m' # err
    '\e[0;33m' # warn
    '\e[0;32m' # notice
    '\e[1;37m' # info
    '\e[1;35m' # debug
)

(( ${#LOG_LEVEL_COLORS[@]} > 0 )) \
    && __log_level_colors=( "${LOG_LEVEL_COLORS[@]}" )

declare -a __log_level_names=(
    'EMERGENCY'
    'ALERT'
    'CRITICAL'
    'ERROR'
    'WARNING'
    'NOTICE'
    'INFO'
    'DEBUG'
)

(( ${#LOG_LEVEL_NAMES[@]} > 0 )) \
    && __log_level_names=( "${LOG_LEVEL_NAMES[@]}" )

__supports_colors || unset __log_level_colors
unset -f '__supports_colors'

# print formatted args|stdin to TTY & optional $log
# @param emerg|alert|crit|err|warn|notice|info|debug
# @param message?... if no message(s), read from stdin
# @return string[]
log.pretty() {
    if (( $# == 1 )); then
        mapfile -t largs
        set -- "${1}" "${largs[@]}"
        unset largs
    fi

    local id
    case "${1,,}" in
        emerg )     id="0";;
        alert )     id="1";;
        crit )      id="2";;
        err )       id="3";;
        warn )      id="4";;
        notice )    id="5";;
        info )      id="6";;
        debug )     id="7";;
    esac
    shift

    local rgb lvl
    rgb="${__log_level_colors[id]}"
    lvl="${__log_level_names[id]}"

    while (( $# > 0 )); do
        printf '%(%FT%T)T|%s|%b%-9s\e[0m|%s\n' -1 \
            "${FUNCNAME[1]}" "${rgb}" "${lvl}" "${1}"
        shift
    done | tee >(
        sed --unbuffered $'s/\e[[][^a-zA-Z]*m//g' >> "${log:-/dev/null}"
    )
}

# print formatted args|stdin to journald (fd/4) & optional $log
# @param emerg|alert|crit|err|warn|notice|info|debug
# @param message?... if no message(s), read from stdin
log.systemd() {
    if (( $# == 1 )); then
        mapfile -t largs
        set -- "${1}" "${largs[@]}"
        unset largs
    fi

    local id
    case "${1,,}" in
        emerg )     id="0";;
        alert )     id="1";;
        crit )      id="2";;
        err )       id="3";;
        warn )      id="4";;
        notice )    id="5";;
        info )      id="6";;
        debug )     id="7";;
    esac
    shift

    local lvl
    lvl="${__log_level_names[id]}"

    while (( $# > 0 )); do
        printf '<%d>%s|%s\n' "${id}" "${FUNCNAME[1]}" "${1}" >&4
        printf '%(%FT%T)T|%s|%-9s|%s\n' -1 \
            "${FUNCNAME[1]}" "${lvl}" "${1}" >> "${log:-/dev/null}"
    done
}

# Run cmd [args] with exec, redirect stdout/stderr to log.pretty()
# WARNING redirects cmd stdout to fd/98 -> log.pretty() info
# WARNING redirects cmd stderr to fd/99 -> log.pretty() err
# Cleans up fd/98-99 on return
# @param command|function|alias
# @param args?...
# @return string[]
log.exec.pretty() {
    __internal.cleanup() {
        exec >&98-
        exec >&99-
        return "${1}"
    }
    exec 98> >(log.pretty info >&1)
    exec 99> >(log.pretty err >&2)
    ( exec "${@}" ) 1>&98 2>&99
    __internal.cleanup "$?"
}

# Run cmd [args] with exec, redirect stdout/stderr to log.systemd()
# WARNING redirects cmd stdout to fd/98 -> log.systemd() debug
# WARNING redirects cmd stderr to fd/99 -> log.systemd() err
# Cleans up fd/98-99 on return
# @param command|function|alias
# @param args?...
log.exec.systemd() {
    __internal.cleanup() {
        exec >&98-
        exec >&99-
        return "${1}"
    }
    exec 98> >(log.systemd debug >&1)
    exec 99> >(log.systemd err >&2)
    ( exec "${@}" ) 1>&98 2>&99
    __internal.cleanup "$?"
}

# Log fatal message (emergency) with log.pretty(), then exit 1 immediately
# @param message?...
# @return string[]
log.die.pretty() {
    set -- "${1:-DIE REASON: N/A}" "${@:2}"
    log.pretty emerg "${@}"
    exit 1
}

# Log fatal MessageData (emergency) with log.systemd(), then exit 1 immediately
# @param message?...
log.die.systemd() {
    set -- "${1:-DIE REASON: N/A}" "${@:2}"
    log.systemd emerg "${@}"
    exit 1
}
