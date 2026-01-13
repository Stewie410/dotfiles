local wezterm = require("wezterm") --[[@as Wezterm]]
local act = wezterm.action

local keys = {
  -- tabs: nav
  { key = "Tab",        mods = "LEADER",       action = act.ActivateTabRelative(1) },
  { key = "Tab",        mods = "LEADER|SHIFT", action = act.ActivateTabRelative(-1) },

  -- tabs: mov
  { key = "[",          mods = "LEADER|CTRL",  action = act.MoveTabRelative(-1) },
  { key = "]",          mods = "LEADER|CTRL",  action = act.MoveTabRelative(1) },

  -- tabs: spawn/close
  { key = "t",          mods = "LEADER|CTRL",  action = act.SpawnTab("CurrentPaneDomain") },
  { key = "W",          mods = "LEADER|CTRL",  action = act.CloseCurrentTab({ confirm = true }) },

  -- panes: nav
  { key = "LeftArrow",  mods = "SHIFT|CTRL",   action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow",  mods = "SHIFT|CTRL",   action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow",    mods = "SHIFT|CTRL",   action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "SHIFT|CTRL",   action = act.ActivatePaneDirection("Right") },
  { key = "H",          mods = "CTRL",         action = act.ActivatePaneDirection("Left") },
  { key = "J",          mods = "CTRL",         action = act.ActivatePaneDirection("Down") },
  { key = "K",          mods = "CTRL",         action = act.ActivatePaneDirection("Up") },
  { key = "L",          mods = "CTRL",         action = act.ActivatePaneDirection("Right") },

  -- panes: rotate
  { key = "[",          mods = "CTRL",         action = act.RotatePanes("CounterClockwise") },
  { key = "]",          mods = "CTRL",         action = act.RotatePanes("Clockwise") },

  -- panes: spawn/close
  { key = "Enter",      mods = "CTRL",         action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "Enter",      mods = "SHIFT|CTRL",   action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "W",          mods = "CTRL",         action = act.CloseCurrentPane({ confirm = false }) },

  -- copy/paste
  { key = "C",          mods = "CTRL",         action = act.CopyTo("Clipboard") },
  { key = "V",          mods = "CTRL",         action = act.PasteFrom("Clipboard") },

  -- search
  { key = "/",          mods = "LEADER",       action = act.Search("CurrentSelectionOrEmptyString") },

  -- scrolling
  { key = "PageUp",     mods = "SHIFT",        action = act.ScrollByPage(-1) },
  { key = "PageDown",   mods = "SHIFT",        action = act.ScrollByPage(1) },

  -- meta
  -- { key = "k", mods = "LEADER|CTRL", action = act.ClearScrollback("ScrollbackOnly") },
  { key = "l",          mods = "LEADER|CTRL",  action = act.ShowDebugOverlay },
  -- { key = "n", mods = "CTRL", action = act.SpawnWindow },
  { key = "p",          mods = "CTRL",         action = act.ActivateCommandPalette },
  { key = "r",          mods = "LEADER|CTRL",  action = act.ReloadConfiguration },
  { key = "z",          mods = "LEADER|CTRL",  action = act.TogglePaneZoomState },
  { key = "F11",        mods = "NONE",         action = act.ToggleFullScreen },

  -- modes
  { key = "x",          mods = "LEADER",       action = act.ActivateCopyMode },
  {
    key = "r",
    mods = "LEADER",
    action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
  },
  {
    key = "l",
    mods = "LEADER",
    action = act.ActivateKeyTable({ name = "launcher", one_shot = true }),
  },
}

local mouse_bindings = {
  -- <C-LMB> to open URI
  { event = { Up = { streak = 1, button = "Left" } },   mods = "CTRL", action = act.OpenLinkAtMouseCursor },
  { event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.Nop },
}

return {
  disable_default_key_bindings = true,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 3000 },
  keys = keys,
  key_tables = {
    resize_pane = require("config.keymap.resize"),
    launcher = require("config.keymap.launch"),
    copy_mode = require("config.keymap.copy"),
    search_mode = require("config.keymap.search"),
  },
  mouse_bindings = mouse_bindings,
}
