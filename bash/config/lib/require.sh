#!/usr/bin/env bash

# require command/alias/function in env
# @param name
# @return boolean
util.require() {
    command -v "${1}" &>/dev/null
}

# require all commands/aliases/functions in env
# @param name...
# @return boolean
util.require.all() {
    while (( $# > 0 )); do
        util.require "${1}" || return 1
        shift
    done
    return 0
}

# require 1 of listed commands/alaises/functions in env
# @param name...
# @return boolean
util.require.any() {
    while (( $# > 0 )); do
        util.require "${1}" && return 0
        shift
    done
    return 1
}
