#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2120

# Close logger file descriptors
#
# @return true
__logger.cleanup() {
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

    local id
    case "${1,,}" in
        "0" | "m" | "emerg" | "emergency")
            id="0"
            ;;
        "1" | "a" | "alert")
            id="1"
            ;;
        "2" | "c" | "crit" | "critical")
            id="2"
            ;;
        "3" | "e" | "err" | "error")
            id="3"
            ;;
        "4" | "w" | "warn" | "warning")
            id="4"
            ;;
        "5" | "n" | "notice")
            id="5"
            ;;
        "6" | "i" | "info")
            id="6"
            ;;
        "7" | "d" | "dbg" | "debug")
            ((LOGGER_DEBUG == 1)) || return 0
            id="7"
            ;;
    esac

    local -a lines
    local line
    while read -r line; do
        lines+=("${line}")
        printf '<%d>%s\n' "${id}" "${line}" >&4
    done

    declare -p 'err' &> /dev/null \
        || return 0

    ((id <= 3)) && err+=("${lines[@]}")

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
    log "emerg" "${@}"
}

alert() {
    log "alert" "${@}"
}

critical() {
    log "crit" "${@}"
}

error() {
    log "err" "${@}"
}

warning() {
    log "warn" "${@}"
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
