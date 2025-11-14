#!/usr/bin/env bash
# shellcheck source=/dev/null

source "${BASH_CONFIG_HOME}/modules/shell.sh"
source "${BASH_CONFIG_HOME}/modules/gh.sh"
source "${BASH_CONFIG_HOME}/modules/readline.sh"
source "${BASH_CONFIG_HOME}/modules/lesspipe.sh"

if [[ "$(uname --kernel-release)" == *"WSL2"* ]]; then
    source "${BASH_CONFIG_HOME}/modules/wsl/ssh.sh"
fi

source "${BASH_CONFIG_HOME}/alias/core.sh"
source "${BASH_CONFIG_HOME}/alias/tools.sh"
source "${BASH_CONFIG_HOME}/alias/dev.sh"

source "${BASH_CONFIG_HOME}/functions/bm.sh"
source "${BASH_CONFIG_HOME}/functions/mkcd.sh"

[[ -s "${HOME}/.cargo/env" ]] &&
    source "${HOME}/.cargo/env"

[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] &&
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
