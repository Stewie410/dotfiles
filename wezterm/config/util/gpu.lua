---@see https://github.com/KevinSilvester/wezterm-config/blob/master/utils/gpu-adapter.lua

local wezterm = require("wezterm") --[[@as Wezterm]]
local platform = require("util.platform")

---@alias WeztermGPUBackend "Vulkan"|"Metal"|"Gl"|"Dx12"
---@alias WeztermGPUDeviceType "DiscreteGpu"|"IntegratedGpu"|"Cpu"|"Other"

---@class WeztermGPUAdapter
---@field name string
---@field backend WeztermGPUBackend
---@field device number
---@field device_type WeztermGPUDeviceType
---@field driver? string
---@field driver_info? string
---@field vendor string

---@alias AdapterMap { [WeztermGPUBackend]: WeztermGPUAdapter|nil }|nil

---@class GpuAdapters
---@field __backends WeztermGPUBackend[]
---@field __preferred_backend WeztermGPUBackend
---@field __preferred_device_type WeztermGPUDeviceType
---@field discrete AdapterMap
---@field integrated AdapterMap
---@field cpu AdapterMap
---@field other AdapterMap
local M = {}
M.__index = M

---@see https://github.com/gfx-rs/wgpu#supported-platforms
M.AVAILABLE_BACKENDS = {
  windows = { "Dx12", "Vulkan", "Gl" },
  linux = { "Vulkan", "Gl" },
  mac = { "Metal" },
}

---@type WeztermGPUAdapter[]
M.ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---Initialize available GPU Map
---@return GpuAdapters
---@private
function M:init()
  local initial = {
    __backends = self.AVAILABLE_BACKENDS[platform.os],
    __preferred_backend = self.AVAILABLE_BACKENDS[platform.os][1],
    discrete = nil,
    integrated = nil,
    cpu = nil,
    other = nil,
  }

  for _, adapter in ipairs(self.ENUMERATED_GPUS) do
    if not initial[adapter.device_type] then
      initial[adapter.device_type] = {}
    end
    initial[adapter.device_type][adapter.backend] = adapter
  end

  local adapters = setmetatable(initial, self)
  return adapters
end

---Will pick thebest adapter based on the following:
---  1. Best GPU available (discrete > integrated > other > cpu)
---  2. "Best" graphics API available for a given platform
---
---"Other" GPU type is for WebGPU's OpenGL impl on discrete adapters
---
---Graphics API choices per-platform:
---  - Windows: DX12 > Vulkan > OpenGL
---  - Linux: Vulkan > OpenGL
---  - Mac: Metal
---@see GpuAdapters.AVAILABLE_BACKENDS
---
---If the best adapter combo is not found, let wezterm device the best
---@return WeztermGPUAdapter|nil
function M:pick_best()
  local adapter_type = nil

  for _, type in ipairs({ "discrete", "integrated", "other", "cpu" }) do
    if self[type] ~= nil and next(self[type]) then
      adapter_type = type
      break
    end
  end

  if adapter_type == nil then
    wezterm.log_error("No GPU Adapters found. Using default adapter")
    return nil
  end

  local preferred_backend = adapter_type == "other" and "Gl" or self.__preferred_backend
  local adapters = self[adapter_type]

  if not adapters[preferred_backend] then
    wezterm.log_error("Preferred backend not available. Using default adapter")
    return nil
  end

  return adapters[preferred_backend]
end

---Manually pick the adapter by graphics API and device type
---If the adapter is not found, let wezterm decide the best
---@param backend WeztermGPUBackend Preferred graphics API
---@param device_type WeztermGPUDeviceType Preferred device type
---@return WeztermGPUAdapter|nil
function M:pick_manual(backend, device_type)
  if not self[device_type] then
    wezterm.log_error("No GPU adapters found. Using default adapter")
    return nil
  end

  if not self[device_type][backend] then
    wezterm.log_error("Preferred backend not available. Using default adapter")
    return nil
  end

  return self[device_type][backend]
end

return M:init()
