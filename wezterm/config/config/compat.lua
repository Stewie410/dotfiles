local platform = require("util.platform")

local compat = {
	windows = {
		ssh_backend = "Ssh2",
		allow_win32_input_mode = true,
	},
	mac = {},
	linux = {
		enable_kitt_keyboard = true,
	},
}

return compat[platform.os]
