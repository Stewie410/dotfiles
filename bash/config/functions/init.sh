#!/usr/bin/env bash

source "${BASH_CONFIG_HOME}/functions/bm.sh"	# shuck: source=bm.sh
source "${BASH_CONFIG_HOME}/functions/mkcd.sh"	# shuck: source=mkcd.sh
source "${BASH_CONFIG_HOME}/functions/uuidk.sh"	# shuck: source=uuidk.sh

[[ -d "${HOME}/.subversion" ]] &&
	source "${BASH_CONFIG_HOME}/functions/svn.sh" # shuck: source=svn.sh

[[ -n "${HOST_IS_WSL}" ]] &&
	source "${BASH_CONFIG_HOME}/functions/windows_explorer.sh" # shuck: source=windows_explorer.sh
