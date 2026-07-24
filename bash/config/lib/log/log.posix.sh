#!/bin/sh

# Try to determine when to print color
#
# @global NO_COLOR? Force-disable coloring
# @global TERM?     Terminal name to determine color support
#
# @exit bool
__logger_use_color() {
    [ -n "${NO_COLOR}" ] && return 1
    [ -t 1 ] || return 1

    case "${TERM:-dumb}" in
        "dumb" | "")
            return 1
            ;;
    esac

    if command -v 'tput' > /dev/null 2>&1; then
        colors="$(tput colors 2> /dev/null)"
        if [ "${colors:-0}" -le 0 ]; then
            unset colors
            return 1
        fi
        unset colors
    fi

    return 0
}

# Try to set up logging facilities
#
# @global LOGGER_USE_COLOR?     Color support preference, default auto
# @global LOGGER_LOGFILE?       Logfile path
log_init() {
    use_color="$(printf '%s' "${LOGGER_USE_COLOR:-auto}" | tr '[:upper:]' '[:lower:]')"
    case "${use_color}" in
        "always" | "yes")
            LOGGER_USE_COLOR="always"
            ;;
        "never" | "no")
            LOGGER_USE_COLOR="never"
            ;;
        *)
            LOGGER_USE_COLOR="never"
            __logger_use_color && LOGGER_USE_COLOR="always"
            ;;
    esac
    unset use_color

    if [ -z "${LOGGER_LOGFILE}" ]; then
        case "$(id --user)" in
            0) LOGGER_LOGFILE="/var/log" ;;
            *) LOGGER_LOGFILE="${HOME}/.local/logs" ;;
        esac

        name="$(basename "${0}")"
        LOGGER_LOGFILE="${LOGGER_LOGFILE}/${name%.*}/${name%.*}.log"
        unset name
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
    if [ "$#" -gt 1 ]; then
        short="${1}"
        shift
        printf '%s\n' "${@}" | log "${short}"
        unset short
        return 0
    fi

    case "$(printf '%s' "${1}" | tr '[:upper:]' '[:lower:]')" in
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
            [ "${LOGGER_DEBUG:-0}" -eq 1 ] || return 0
            rgb='\e[1;35m'
            lvl="DEBUG"
            ;;
    esac

    [ "${LOGGER_USE_COLOR}" = "always" ] || unset rgb

    lines="$(mktemp)"
    while read -r line; do
        printf '%s\n' "${line}" >> "${lines}"
        stamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"
        printf '%s|%b%-9s\e[0m|%s\n' "${stamp}" "${rgb}" "${lvl}" "${line}"
        printf '%s|%-9s|%s\n' "${stamp}" "${lvl}" "${line}" \
            >> "${LOGGER_LOGFILE:-/dev/null}"
    done

    case "${lvl}" in
        "EMERGENCY" | "ALERT" | "CRITICAL" | "ERROR")
            cat "${lines}" >> "${LOGGER_ERR:-/dev/null}"
            ;;
    esac

    unset rgb lvl lines line stamp
    return 0
}

# logger.log() per-level helper functions
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
    [ "$#" -gt 0 ] || set -- "Unknown Cause"
    emergency "${@}"
    exit 99
}

# Write to-be-executed command as unquoted string
#
# @param command    command to be executed
# @param args[]?    command arguments
#
# @return true
__logger_exec_debug() {
    debug "EXEC: $*"
}

# Try setup named pipes for exec_* functions
#
# @stdout tuple(3)  Named pipe temp directory, stdout PID (fifo), stderr PID (fifo)
#
# @return bool
__logger_setup_fifo() {
    if ! pipedir="$(mktemp -d)" > /dev/null 2>&1; then
        critical "Cannot create tempdir for named pipes!"
        unset pipedir
        return 1
    fi

    stdout="${pipedir}/stdout"
    stderr="${pipedir}/stderr"

    if ! mkfifo "${stdout}" "${stderr}" > /dev/null 2>&1; then
        critical "Cannot create named pipes!"
        rm --recursive --force "${pipedir}"
        unset pipedir stdout stderr
        return 1
    fi

    log info < "${stdout}" &
    pid_stdout="$!"
    log err < "${stderr}" &
    pid_stderr="$!"

    printf '%s,%s,%s\n' "${pipedir}" "${pid_stdout}" "${pid_stderr}"
    unset pipedir stdout stderr pid_stdout pid_stderr

    return 0
}

# Cleanup named pipes for exec_* functions
#
# @param pipedir        Path to stdout/stderr named pipes
# @param pid_stdout     stdout fifo PID
# @param pid_stderr     stderr fifo PID
#
# @return true
__logger_close_fifo() {
    (
        # Assume logs flushed at ~30s
        sleep 30
        kill "${2}" "${3}" 2> /dev/null
    ) &
    watchdog="$!"
    wait "${2}" "${3}"
    kill "${watchdog}" 2> /dev/null

    rm --recursive --force "${1}"
    unset watchdog

    return 0
}

# Run a command, write stdout/stderr with log() (via temp named-pipes, see mkfifo)
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Command arguments
#
# @stdout           Command's formatted stdout
# @stderr           Command's formatted stderr
# @exit int         Command's exit code, or failed-to-setup named pipes
exec_log() {
    if ! fifo_setup="$(__logger_setup_fifo)"; then
        unset fifo_setup
        return 1
    fi

    pipedir="${fifo_setup%%,*}"
    pid_stdout="${fifo_setup#*,}"
    pid_stdout="${pid_stdout%,*}"
    pid_stderr="${fifo_setup##*,}"

    __logger_exec_debug "${@}"

    "${@}" 1> "${pipedir}/stdout" 2> "${pipedir}/stderr"
    result="$?"

    __logger_close_fifo "${pipedir}" "${pid_stdout}" "${pid_stderr}"
    unset fifo_setup pipedir pid_stdout pid_stderr

    return "${result:-0}"
}

# Run a command, write stdout with log() (via temp named-pipes, see mkfifo), leave stderr unchanged (fd2)
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Command arguments
#
# @stdout           Command's formatted stdout
# @stderr           Command's unchanged stderr
# @exit int         Command's exit code, or failed-to-setup named pipes
exec_stdout() {
    if ! fifo_setup="$(__logger_setup_fifo)"; then
        unset fifo_setup
        return 1
    fi

    pipedir="${fifo_setup%%,*}"
    pid_stdout="${fifo_setup#*,}"
    pid_stdout="${pid_stdout%,*}"
    pid_stderr="${fifo_setup##*,}"

    __logger_exec_debug "${@}"

    "${@}" 1> "${pipedir}/stdout"
    result="$?"

    __logger_close_fifo "${pipedir}" "${pid_stdout}" "${pid_stderr}"
    unset fifo_setup pipedir pid_stdout pid_stderr

    return "${result:-0}"
}

# Run a command, leave stdout unchanged (fd1), write stderr with log() (via temp named-pipes, see mkfifo)
#
# @stdin file?      Depends on command
#
# @param command    Command to execute
# @param args[]?    Command arguments
#
# @stdout           Command's unchanged stdout
# @stderr           Command's formatted stderr
# @exit int         Command's exit code, or failed-to-setup named pipes
exec_stderr() {
    if ! fifo_setup="$(__logger_setup_fifo)"; then
        unset fifo_setup
        return 1
    fi

    pipedir="${fifo_setup%%,*}"
    pid_stdout="${fifo_setup#*,}"
    pid_stdout="${pid_stdout%,*}"
    pid_stderr="${fifo_setup##*,}"

    __logger_exec_debug "${@}"

    "${@}" 2> "${pipedir}/stderr"
    result="$?"

    __logger_close_fifo "${pipedir}" "${pid_stdout}" "${pid_stderr}"
    unset fifo_setup pipedir pid_stdout pid_stderr

    return "${result:-0}"
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
    result_file="$(mktemp)"

    __logger_exec_debug "${@}"

    {
        "${@}"
        printf '%d' "$?" > "${result_file}"
    } 2>&1 | while read -r line; do
        lvl=""
        is_formatted="0"
        case "${line}" in
            *'|'*"|"*)
                lvl="${line#*|}"
                lvl="${lvl%%|*}"
                lvl="${lvl%%[[:space:]]*}"

                case "${lvl}" in
                    "EMERGENCY" | \
                        "ALERT" | \
                        "CRITICAL" | \
                        "ERROR" | \
                        "WARNING" | \
                        "NOTICE" | \
                        "INFO" | \
                        "DEBUG")
                        is_formatted="1"
                        ;;
                esac
                ;;
        esac

        if [ "${is_formatted}" -eq 1 ]; then
            msg="${line#*|}"
            msg="${msg#*|}"

            case "${lvl}" in
                "INFO" | "NOTICE" | "DEBUG")
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
    unset line lvl msg is_formatted

    result="$(cat "${result_file}")"
    rm --force "${result_file}"
    unset result_file

    return "${result:-0}"
}
