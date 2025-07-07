local M = {}

local wezterm = require("wezterm") --[[@as Wezterm]]

---comment
---@param MuxTabObj
---@return unknown
function M.tab_title(tab)
	return (tab.tab_title ~= nil and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
end
