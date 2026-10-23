#!/usr/bin/env bash

uuidk() {
	_usage() {
		cat << EOF
Small wrapper for /proc/sys/kernel/random/uuid

USAGE: uuidk [OPTIONS] [COUNT]

OPTIONS:
	-h, --help 			Show this help message
	-u, --upper 		Force upper-case
	-l, --lower 		Force lower-case (default)
EOF
	}

	_err() {
		printf '\e[0;31mERROR\e[0m: %s\n' "${@}" >&2
	}

	local kern
	kern="/proc/sys/kernel/random/uuid"
	if ! [[ -e "${kern}" ]]; then
		_err "Missing proc: ${kern}"
		return 1
	fi

	local upper
	case "${1}" in
	"-h" | "--help")
		_usage
		return 0
		;;
	"-u" | "--upper")
		upper="1"
		shift
		;;
	"-l" | "--lower")
		upper="0"
		shift
		;;
	"--")
		shift
		;;
	"-"*)
		_err "Unknown option: ${1}"
		return 1
		;;
	esac

	set -- "${1:-1}"

	local -a list
	mapfile -t list < <(
		for ((i = 0; i < ${1}; i++)); do
			cat "${kern}"
		done
	)

	if ((upper)); then
		printf '%s\n' "${list[@]^^}"
	else
		printf '%s\n' "${list[@],,}"
	fi

	return 0
}
