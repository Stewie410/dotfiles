#!/usr/bin/env bash
#
# Set bat/batcat as manpager

__batcat() {
	local bat
	bat="$(command -v "batcat")" ||
		return 1

	[[ -L "${HOME}/.local/bin/bat" ]] ||
		ln --symbolic --force "${bat}" "${HOME}/.local/bin/bat" &> /dev/null

	# manpage, maybe
	local usr man
	usr="${XDG_DATA_HOME}/man/man1/bat.1.gz"
	man="man1/batcat.1.gz"

	[[ -s "${usr}" ]] ||
		return 0

	local -a search
	IFS=":" read -ra search <<< "$(manpath --quiet)"

	[[ "${search[*]}" == *"${XDG_DATA_HOME}"* ]] ||
		return 1

	local p
	for p in "${search[@]}"; do
		[[ "${p}" == *"${XDG_DATA_HOME}"* ]] &&
			continue

		if [[ -s "${p}/${man}" ]]; then
			mkdir --parents "${usr%/*}"
			gunzip --keep --stdout "${p}/${man}" \
				| sed 's/batcat/bat/g;s/BATCAT/BAT/g' \
				| gzip --stdout - > "${usr}"

			command -v "mandb" &> /dev/null &&
				mandb --quiet

			return 0
		fi
	done

	return 1
}

__batcat || true
unset -f "__batcat"

if command -v "bat" &> /dev/null; then
	export MANPAGER="sh -c 'col -bx | bat --language man --plain'"
	export MANROFFOPT="-c"
fi
