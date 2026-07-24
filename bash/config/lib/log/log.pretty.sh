#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2120

# Try to determine when to print color
#
# @global NO_COLOR? Force-disable coloring
# @global TERM?     Terminal name to determine color support
#
# @exit bool
__logger.use_color() {
    [[ -n "${NO_COLOR}" ]] && return 1
    [[ -t 1 ]] || return 1

    case "${TERM:-dumb}" in
        "dumb" | "")
            return 1
            ;;
    esac

    if command -v 'tput' &> /dev/null; then
        local colors
        colors="$(tput colors 2> /dev/null)"
        ((${colors:-0} <= 0)) && return 1
    fi

    return 1
}

# Close logger file descriptors
#
# @return true
log.cleanup() {
    exec 93>&-
    exec 96>&-
    if ((LOGGER_EXTENDED_FD == 1)); then
        exec 90>&-
        exec 91>&-
        exec 92>&-
        exec 94>&-
        exec 95>&-
        exec 97>&-
    fi
    wait
    return 0
}

# Try to set up logging facilities
#
# @global LOGGER_USE_COLOR?     Color support preference, default auto
# @global LOGGER_LOGFILE?       Logfile path
log.init() {
    case "${LOGGER_USE_COLOR,,}" in
        "always" | "yes")
            LOGGER_USE_COLOR="always"
            ;;
        "never" | "no")
            LOGGER_USE_COLOR="never"
            ;;
        *)
            LOGGER_USE_COLOR="never"
            __logger.use_color && LOGGER_USE_COLOR="always"
            ;;
    esac

    if [[ -z "${LOGGER_LOGFILE}" ]]; then
        case "$(id --user)" in
            0) LOGGER_LOGFILE="/var/log" ;;
            *) LOGGER_LOGFILE="${HOME}/.local/logs" ;;
        esac

        local name
        name="${BASH_SOURCE[0]##*/}"
        LOGGER_LOGFILE+="/${name%.*}/${name%.*}.log"
    fi

    (
        set -e
        mkdir --parents "${LOGGER_LOGFILE%/*}"
        touch -a "${LOGGER_LOGFILE}"
    ) || return 1

    return 0
}

# Write formatted messages to stdout & [$log].
# WARN: Message(s) from args will IGNORE stdin!
#
# @global LOGGER_USE_COLOR? If "never", drop colors from TTY
# @global LOGGER_DEBUG?     If "0", skip debug lines
# @global LOGGER_ERR[]?     If declared, append error-like lines to array
# @global LOGGER_LOGFILE?   Append plaintext logs to path, if set (default: /dev/null)
#
# @stdin file       line(s) to write out
#
# @param level      Log "level" as integer, character, short or long name
# @param line[]?    Line(s) to write out
#
# @stdout logs[]    Formatted log strings
# @exit true
log() {
    if (($# > 1)); then
        log "${1}" < <(printf '%s\n' "${@:2}")
        return 0
    fi

    local rgb lvl
    case "${1,,}" in
        "0" | "m" | "emerg" | "emergency")
            rgb='\e[1;31m'
            lvl="EMERGENCY"
            ;;
        "1" | "a" | "alert")
            rgb='\e[1;36m'
            lvl="ALERT"
            ;;
        "2" | "c" | "crit" | "critical")
            rgb='\e[1;33m'
            lvl="CRITICAL"
            ;;
        "3" | "e" | "err" | "error")
            rgb='\e[0;31m'
            lvl="ERROR"
            ;;
        "4" | "w" | "warn" | "warning")
            rgb='\e[0;33m'
            lvl="WARNING"
            ;;
        "5" | "n" | "notice")
            rgb='\e[0;32m'
            lvl="NOTICE"
            ;;
        "6" | "i" | "info")
            rgb='\e[1;37m'
            lvl="INFO"
            ;;
        "7" | "d" | "dbg" | "debug")
            ((LOGGER_DEBUG == 1)) || return 0
            rgb='\e[1;35m'
            lvl="DEBUG"
            ;;
    esac

    [[ "${LOGGER_USE_COLOR}" == "always" ]] || unset rgb

    local -a lines
    local line stamp
    while read -r line; do
        lines+=("${line}")
        printf -v stamp '%(%FT%T%z)T' -1
        printf '%s|%b%-9s\e[0m|%s\n' "${stamp}" "${rgb}" "${lvl}" "${line}"
        printf '%s|%-9s|%s\n' "${stamp}" "${lvl}" "${line}" \
            >> "${LOGGER_LOGFILE:-/dev/null}"
    done

    declare -p 'LOGGER_ERR' &> /dev/null || return 0

    case "${lvl}" in
        "EMERGENCY" | "ALERT" | "CRITICAL" | "ERROR")
            LOGGER_ERR+=("${lines[@]}")
            ;;
    esac

    return 0
}

# log() per-level helper functions
# WARN: Message(s) from args will IGNORE stdin!
#
# @global LOGGER_USE_COLOR? If "never", drop colors from TTY
# @global LOGGER_DEBUG?     If "0", skip debug lines
# @global LOGGER_ERR[]?     If declared, append error-like lines to array
# @global LOGGER_LOGFILE?   Append plaintext logs to path, if set (default: /dev/null)
#
# @stdin file       line(s) to write out
#
# @param line[]?    Line(s) to write out
#
# @stdout logs[]?   Formatted log strings
# @exit true
emergency() {
    log "emerg" "${@}" >&2
}

alert() {
    log "alert" "${@}" >&2
}

critical() {
    log "crit" "${@}" >&2
}

error() {
    log "err" "${@}" >&2
}

warning() {
    log "warn" "${@}" >&2
}

notice() {
    log "notice" "${@}"
}

info() {
    log "info" "${@}"
}

debug() {
    log "debug" "${@}"
}

# Early exit script (99), write cause as log.emergency()
#
# @param line[]?    Cause of early exit
#
# @stderr           Cause of early exit
#
# @exit 99 (false)
die() {
    set -- "${1:-Unknown Cause}" "${@:2}"
    emergency "${1:-Unknown Cause}" "${@:2}"
    exit 99
}

# Write to-be-executed command as quoted string
#
# @param command    command to be executed
# @param args[]?    command arguments
#
# @return true
__logger.exec_debug() {
    local dbg
    printf -v dbg ' %q' "${@}"
    debug "EXEC: ${dbg:1}"
    return 0
}

# Run a command, write stdout with info() (fd96), write stderr with error() (fd93)
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Depends on command
#
# @stdout           Command's formatted stdout
# @stderr           Command's formatted stderr
# @exit int         Command's exit code
exec_log() {
    __logger.exec_debug "${@}"
    "${@}" 1>&96 2>&93
}

# Run a command, write stdout with info() (fd96), leave stderr unchanged (fd2)
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Command arguments
#
# @stdout           Command's formatted stdout
# @stderr           Command's unchanged stderr
# @exit int         Command's exit code
exec_stdout() {
    __logger.exec_debug "${@}"
    "${@}" 1>&96
}

# Run a command, leave stdout unchanged (fd1), write stderr with error() (fd93)
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Command arguments
#
# @stdout           Command's formatted stdout
# @stderr           Command's formatted stderr
# @exit int         Command's exit code
exec_stderr() {
    __logger.exec_debug "${@}"
    "${@}" 2>&93
}

# Run a nested script with own log() function, deduplicating formatting
# Write all unformatted output with debug()
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Command arguments
#
# @stdout           Command's formatted stdout
# @stderr           Command's formatted stderr
# @exit int         Command's exit code
exec_nested() {
    __logger.exec_debug "${@}"

    local line
    "${@}" 2>&1 | while read -r line; do
        local lvl is_formatted
        ((lvl = -1, is_formatted = 0))

        case "${line}" in
            *'|'*"|"*)
                lvl="${line#*|}"
                lvl="${lvl%%|*}"
                lvl="${lvl%%[[:space:]]*}"

                case "${lvl}" in
                    "emergency" | \
                        "alert" | \
                        "critical" | \
                        "error" | \
                        "warning" | \
                        "notice" | \
                        "info" | \
                        "debug")
                        is_formatted="1"
                        ;;
                esac
                ;;
        esac

        if ((is_formatted == 1)); then
            local msg
            msg="${line#*|}"
            msg="${msg#*|}"

            case "${lvl,,}" in
                "info" | "notice" | "debug")
                    log "${lvl}" "${1}: ${msg}"
                    ;;
                *)
                    log "${lvl}" "${1}: ${msg}" >&2
                    ;;
            esac
        else
            debug "${1}: ${line}"
        fi
    done

    return "${PIPESTATUS[0]}"
}

# Setup logger file descriptors, if enabled
exec 93> >(error)
exec 96> >(info)

if ((LOGGER_EXTENDED_FD == 1)); then
    exec 90> >(emergency)
    exec 91> >(alert)
    exec 92> >(critical)
    exec 94> >(warning)
    exec 95> >(notice)
    exec 97> >(debug)
fi
