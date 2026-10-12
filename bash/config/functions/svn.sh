#!/usr/bin/env bash

svn-ignore() {
	_usage() {
		cat <<- EOF
			"Simple" svn propset wrapper

			USAGE: ${FUNCNAME[0]} [OPTIONS] [SVN_OPTS] PATTERN PATH [...]

			OPTIONS:
				-h, --help       Show this help message
				-H, --svn-help  Show svn propset help
				-g, --global    Make ignore inheritable
		EOF
	}

	_err() {
		printf '\e[0;31mERROR\e[0m: %s\n' "${@}" >&2
	}

	local prop
	prop='svn:ignore'

	case "${1}" in
		"-h" | "--help")
			_usage
			return 0
			;;
		"-H" | "--svn-help")
			svn help propset
			return 0
			;;
		"-g" | "--global")
			prop='svn:global-ignores'
			shift
			;;
		--)
			shift
			;;
	esac

	if (($# < 2)); then
		_err "Must specify pattern & path(s)."
		return 1
	fi

	svn propset "${prop}" "${@}"
}
