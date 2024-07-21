#!/usr/bin/env bash
#
# wsl-vpnkit networking support

wsl.exe --list | grep --quiet 'wsl-vpnkit' && \
    wsl.exe --distribution "wsl-vpnkit" "service wsl-vpnkit start"
