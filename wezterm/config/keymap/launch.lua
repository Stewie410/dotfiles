---@diagnostic disable: missing-fields
local wezterm = require("wezterm") --[[@as Wezterm]]
local largs = wezterm.action.ShowLauncherArgs

---@type KeyAssignment[]
return {
	{ key = "t", mods = "NONE", action = largs({ title = "Tabs", flags = "FUZZY|TABS" }) },
	{ key = "d", mods = "NONE", action = largs({ title = "Domains", flags = "FUZZY|DOMAINS" }) },
	{ key = "w", mods = "NONE", action = largs({ title = "Workspaces", flags = "FUZZY|WORKSPACES" }) },
	{ key = "m", mods = "NONE", action = largs({ title = "Launch Menu", flags = "FUZZY|LAUNCH_MENU_ITEMS" }) },
	{ key = "k", mods = "NONE", action = largs({ title = "Keymap", flags = "FUZZY|KEY_ASSIGNMENTS" }) },
	{ key = "c", mods = "NONE", action = largs({ title = "Commands", flags = "FUZZY|COMMANDS" }) },
}
