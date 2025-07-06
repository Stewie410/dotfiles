local M = {}

local wezterm = require("wezterm") --[[@as Wezterm]]
local wezterm_config = wezterm.config_builder()

---Merge user options with default wezterm config
---@param config Config wezterm config options table
---@return Config
function M.setup(opts)
	local t = {}
end
