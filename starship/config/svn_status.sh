#!/usr/bin/env bash

main() {
    local -a count
    while read -r REPLY; do
        case "${REPLY:0:1}" in
            "A" )       count[0]='+';; # added
            "D" )       count[1]='✘';; # removed
            "M" )       count[2]='!';; # modified
            "R" )       count[3]='»';; # replaced
            "?" | "X" ) count[4]='?';; # untracked
            "!" | "~" ) count[5]='⇕';; # missing/obstructed
            "I" )       count[6]='_';; # ignored
            "C" )       count[7]='=';; # conflict
        esac
    done < <(svn --non-interactive status --depth='infinity')

    (( ${#count[@]} > 0 )) || return 1

    local status
    status="${count[*]}"
    printf '%s\n' "${status// /}"
    return 0
}

main "${@}"
