local wezterm = require("wezterm") --[[@as Wezterm]]

local is_win = wezterm.target_triple:find("windows") ~= nil
local is_mac = wezterm.target_triple:find("apple") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local arch = wezterm.target_triple:find("aarch64") ~= nil and "aarch64" or "x86_64"
local os_name = is_win and "windows" or is_mac and "mac" or is_linux and "linux" or "unknown"

---@alias WeztermTargetTriple "x86_64-pc-windows-msvc"|"x86_64-apple-darwin"|"aarch64-apple-darwin"|"x86_64-unknown-linux-gnu"
---@alias PlatformName "windows"|"mac"|"linux"|"unknown"
---@alias PlatformArch "x86_64"|"aarch64"

---@class Platform
---@field target WeztermTargetTriple Rust target-triple
---@field os PlatformName Basic OS Name
---@field arch PlatformArch Platform architecture
---@field is_win boolean Platform is Windows
---@field is_mac boolean Platform is MacOS
---@field is_linux boolean Platform is (any) Linux
return {
	target = wezterm.target_triple,
	os = os_name,
	arch = arch,
	is_win = is_win,
	is_mac = is_mac,
	is_linux = is_linux,
}
