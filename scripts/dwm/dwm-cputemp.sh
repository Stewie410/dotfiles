#!/usr/bin/env bash
#
# Report average CPU Core temperature

sensors --no-adapter | \
    awk '
        /^Core/ {
            cnt += 1
            sum += $3
        }
        END {
            printf " %0.0f°C", sum/cnt
        }
    '
