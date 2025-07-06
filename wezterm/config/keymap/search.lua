---@diagnostic disable: missing-fields, undefined-field
local wezterm = require("wezterm") --[[@as Wezterm]]
local copy = wezterm.action.CopyMode

---@type KeyAssignment[]
return {
	{ key = "Enter", mods = "NONE", action = copy("PriorMatch") },
	{ key = "Escape", mods = "NONE", action = copy("Close") },
	{ key = "n", mods = "CTRL", action = copy("NextMatch") },
	{ key = "p", mods = "CTRL", action = copy("PriorMatch") },
	{ key = "r", mods = "CTRL", action = copy("CycleMatchType") },
	{ key = "u", mods = "CTRL", action = copy("ClearPattern") },
	{ key = "PageUp", mods = "NONE", action = copy("PriorMatchPage") },
	{ key = "PageDown", mods = "NONE", action = copy("NextMatchPage") },
	{ key = "UpArrow", mods = "NONE", action = copy("PriorMatch") },
	{ key = "DownArrow", mods = "NONE", action = copy("NextMatch") },
}
