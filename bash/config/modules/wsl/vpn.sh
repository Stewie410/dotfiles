#!/usr/bin/env bash
#
# wsl-vpnkit networking support

_wsl() {
    /mnt/c/Windows/System32/wsl.exe "${@}"
}

has_kit() {
    _wsl --list |& grep --quiet 'wsl-vpnkit'
}

start_kit() {
    _wsl --distribution "wsl-vpnkit" 'service wsl-vpnkit start'
}

has_kit && start_kit
unset -f _wsl has_kit start_kit

