local wezterm = require("wezterm") --[[@as Wezterm]]

local plugin_opts = {
  ["https://github.com/adriankarklen/bar.wezterm"] = {
    modules = {
      tabs = {
        active_tab_fg = 3,
        inactive_tab_fg = 2,
        new_tab_fg = 4,
      },
      username = { enabled = false },
      hostname = { enabled = false },
      clock = { enabled = false },
      spotify = { enabled = false },
    },
  },
}

local config = {}

for k, v in pairs(plugin_opts) do
  local ok, plug = pcall(wezterm.plugin.require, k)
  if ok then
    plug.apply_to_config(config, v)
  end
end

return config
