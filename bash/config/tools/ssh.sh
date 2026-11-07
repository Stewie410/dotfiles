#!/usr/bin/env bash

__wsl_ssh() {
	local name
	name="wsl-ssh-agent"

	systemctl --user --quiet list-unit-files "${name}.service" &> /dev/null ||
		return 1

	systemctl --user is-active "${name}.service" &> /dev/null ||
		systemctl --user enable --now "${name}.service" &> /dev/null ||
		return 1

	sock="${XDG_RUNTIME_DIR}/${name}.sock"

	[[ -S "${sock}" ]] &&
		return 0

	unset sock
	return 1
}

__bw_ssh() {
	sock="${HOME}/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"

	[[ -S "${sock}" ]] &&
		return 0

	unset sock
	return 1
}

declare sock
if ((HOST_IS_WSL)) && __wsl_ssh; then
	export SSH_AUTH_SOCK="${sock}"
elif __bw_ssh; then
	export SSH_AUTH_SOCK="${sock}"
fi
unset sock
unset -f "__wsl_ssh" "__bw_ssh"
