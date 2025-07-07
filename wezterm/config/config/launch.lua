local platform = require("util.platform")

local shells = {
	pwsh = { label = "PowerShell Core", args = { os.getenv("PROGRAMFILES") .. "/PowerShell/7.pwsh.exe", "-NoLogo" } },
	powershell = { label = "PowerShell 5.1", args = { "powershell.exe" } },
	cmd = { label = "Command Prompt", args = { "cmd.exe" } },
	ubuntu = { label = "Ubuntu (WSL)", args = { "ubuntu.exe" } },
	vpnkit = { label = "wsl-vpnkit", args = { "wsl.exe", "-d", "wsl-vpnkit" } },
	git = { label = "Git Bash", args = { os.getenv("PROGRAMFILES") .. "/Git/bin/bash.exe", "-i", "-l" } },
	bash = { label = "Bash", args = { "bash", "-l" } },
	zsh = { label = "Zsh", args = { "zsh", "-l" } },
}

-- assume linux
local options = {
	default_prog = shells.bash.args,
	launch_menu = {
		shells.pwsh,
		shells.bash,
		shells.zsh,
	},
}

if platform.is_win then
	options.default_prog = shells.ubuntu.args
	options.launch_menu = {
		shells.pwsh,
		shells.powershell,
		shells.cmd,
		shells.ubuntu,
		shells.git,
	}
end

return options
