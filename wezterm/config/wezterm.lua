local wezterm = require("wezterm") --[[@as Wezterm]]
local config = wezterm.config_builder()

local cfg = {
	compat = require("config.compat"),
	domain = require("config.domain"),
	launch = require("config.launch"),
	meta = require("config.meta"),
	ux = require("config.ux"),
	keymap = require("config.keymap"),
	-- plug = require("config.plugin"),
}

-- apply config
for _, t in pairs(cfg) do
	for k, v in pairs(t) do
		config[k] = v
	end
end

local plugins = {
	bar = require("plugins.bar"),
}

-- install & setup plugins
for _, t in pairs(plugins) do
	local ok, plug = pcall(wezterm.plugin.require, t[1])
	if ok then
		plug.apply_to_config(config, t.opts)
	end
end

return config
