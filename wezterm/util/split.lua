local M = {}

local wezterm = require("wezterm")

function M.toggle()
  local tabnr = 0
  local tab = wezterm.mux.get_tab(tabnr)

  if tab:get_pane_direction("Down") then
    wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })
  else
    wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })
  end
end
