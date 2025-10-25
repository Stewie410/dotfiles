#!/usr/bin/env bash

get_status() {
    svn --non-interactive status --depth='immediates'
}

has_status() {
    [[ -n "$(get_status)" ]] && return 0
    return 1
}

parse_status() {
    local -A count
    local -a result
    local i

    while read -r i; do
        case "${i:0:1}" in
        A | C | D | I | M | R | X) ((count["${i:0:1}"]++)) ;;
        "?") ((count["q"]++)) ;;
        "!") ((count["b"]++)) ;;
        "~") ((count["t"]++)) ;;
        esac
    done < <(get_status)

    for i in "A" "C" "D" "I" "M" "R" "X" "q" "b" "t"; do
        ((count["$i"] > 0)) || continue
        case "${i}" in
        q) result+=("?:${count["q"]}") ;;
        b) result+=("!:${count["b"]}") ;;
        t) result+=("~:${count["t"]}") ;;
        *) result+=("${i}:${count["$i"]}") ;;
        esac
    done

    printf '%s' "${result[*]}"
}

main() {
    if [[ "${1,,}" == "stats" ]]; then
        parse_status
    else
        has_status
    fi
}

main "${@}"
