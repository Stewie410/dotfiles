---@diagnostic disable: missing-fields
local wezterm = require("wezterm") --[[@as Wezterm]]
local act = wezterm.action

---@type KeyAssignment[]
return {
  { key = "Escape",     mods = "NONE",  action = act.PopKeyTable },
  { key = "q",          mods = "NONE",  action = act.PopKeyTable },

  { key = "LeftArrow",  mods = "NONE",  action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "UpArrow",    mods = "NONE",  action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "DownArrow",  mods = "NONE",  action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "RightArrow", mods = "NONE",  action = act.AdjustPaneSize({ "Right", 1 }) },

  { key = "LeftArrow",  mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "UpArrow",    mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "DownArrow",  mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "RightArrow", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
}
