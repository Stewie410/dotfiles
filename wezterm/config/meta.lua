---@diagnostic disable: missing-fields

---@as Wezterm
---@module "wezterm"

local rgx_uri = "(\\w+://\\S+)"

---@type Config
return {
	automatically_reload_config = true,
	exit_behavior = "CloseOnCleanExit",
	exit_behavior_messaging = "Verbose",
	status_update_interval = 1000,

	scrollback_lines = 20000,

	hyperlink_rules = {
		{ regex = "\\(" .. rgx_uri .. "\\)", format = "$1", highlight = 1 }, -- (URI)
		{ regex = "\\[" .. rgx_uri .. "\\]", format = "$1", highlight = 1 }, -- [URI]
		{ regex = "\\{" .. rgx_uri .. "\\}", format = "$1", highlight = 1 }, -- {URI}
		{ regex = "<" .. rgx_uri .. ">", format = "$1", highlight = 1 }, -- <URI>
		{ regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+", format = "$0" }, -- URI
		{ regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" }, -- mailto
	},
}
