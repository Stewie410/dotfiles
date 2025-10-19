#!/usr/bin/env bash
# shellcheck source=/dev/null

source "${BASH_CONFIG_HOME}/modules/shell.sh"
source "${BASH_CONFIG_HOME}/modules/gh.sh"
source "${BASH_CONFIG_HOME}/modules/readline.sh"
source "${BASH_CONFIG_HOME}/modules/lesspipe.sh"

if [[ "$(uname --kernel-release)" == *"WSL2"* ]]; then
    source "${BASH_CONFIG_HOME}/modules/wsl/ssh.sh"
    source "${BASH_CONFIG_HOME}/modules/wsl/vpn.sh"
fi

source "${BASH_CONFIG_HOME}/aliases/core.sh"
source "${BASH_CONFIG_HOME}/aliases/tools.sh"
source "${BASH_CONFIG_HOME}/aliases/dev.sh"

source "${BASH_CONFIG_HOME}/functions/bm.sh"
source "${BASH_CONFIG_HOME}/functions/cheat.sh"
source "${BASH_CONFIG_HOME}/functions/d2.sh"
source "${BASH_CONFIG_HOME}/functions/mkcd.sh"
source "${BASH_CONFIG_HOME}/functions/python.sh"

[[ -s "${HOME}/.cargo/env" ]] &&
    source "${HOME}/.cargo/env"

[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] &&
    source "${SDKMAN_DIR}/bin/sdkmin-init.sh"
