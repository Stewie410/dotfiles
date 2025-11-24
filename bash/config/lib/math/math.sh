#!/usr/bin/env bash

# calculate greatest common denominator
# @param number
# @param number...
# @return number
math.gcd() {
    local a b gcd
    a="${1}"
    shift

    while (( $# > 0 )); do
        gcd="${1}"
        until (( a % gcd == 0 )); do
            b="${a}"
            a="${gcd}"
            (( gcd = b % a ))
        done
        shift
    done

    printf '%d\n' "${gcd}"
}

# calculate lowest common multiple
# @param number
# @param number...
# @return number
math.lcm() {
    local gcd lcm
    lcm="${1}"
    shift

    while (( $# > 0 )); do
        gcd="$(math.gcd "${lcm}" "${1}")"
        (( lcm = (lcm * ${1}) / gcd ))
        shift
    done

    printf '%d\n' "${lcm}"
}

# find highest value from list
# @param number
# @param number...
# @return number
math.max() {
    local i max
    max="${1}"
    for i in "${@:2}"; do
        (( i > max )) && max="${i}"
    done
    printf '%d\n' "${i}"
}

# find lowest value from list
# @param number
# @param number...
# @return number
math.min() {
    local i min
    min="${1}"
    for i in "${@:2}"; do
        (( i < min )) && min="${i}"
    done
    printf '%d\n' "${i}"
}
