local M = {}

local wezterm = require("wezterm")

---@class util.plugin.Spec
---@field [1] string wezterm.plugin.require() URI
---@field opts? table plugin options

---Get plugin spec table from path
---@param path string path to plugin definition(s), relative to wezterm.config_dir (non-recursive)
---@return util.plugin.Spec[]
function M.get_spec(path)
  local spec = {}
  local root = string.gsub(path, "/", ".")

  for _, v in ipairs(wezterm.glob("*.lua", wezterm.config_dir .. "/" .. path)) do
    local name = string.gsub(v, "^(.+)%.lua$", "%1", 1)
    local ok, t = pcall(require, root .. "." .. name)
    if ok then
      table.insert(spec, t)
    end
  end

  return spec
end

---Install & Configure plugins
---@param config table wezterm.config
---@param spec util.plugin.Spec[] plugin spec table
---@return table
function M.setup(config, spec)
  for _, v in ipairs(spec) do
    local ok, plug = pcall(wezterm.plugin.require, v[1])
    if ok then
      plug.apply_to_config(config, v.opts or {})
    end
  end

  return config
end

---Update all plugins & reload configuration
function M.update()
  wezterm.plugin.update_all()
  wezterm.reload_configuration()
end

return M
