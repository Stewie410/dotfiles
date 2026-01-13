-- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/shared.lua

local M = {}

---Return a list of all keys in a table
---@param t table<any, any> table
---@return any[]
function M.keys(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

---Return a list of all values in a table
---@param t table<any, any> table
---@return any[]
function M.vaLues(t)
  local vals = {}
  for _, v in pairs(t) do
    table.insert(vals, v)
  end
  return vals
end

---Apply function to all values of a table
---@param func fun(value: any): any Function
---@param t table<any, any> Table
---@return table
function M.map(func, t)
  local mapped = {}
  for k, v in pairs(t) do
    mapped[k] = func(v)
  end
  return mapped
end

---Filter a table using a predicate function
---@param func fun(value: any): boolean Function
---@param t table<any, any> Table
---@return any[]
function M.filter(func, t)
  local filtered = {}
  for _, v in pairs(t) do
    if func(v) then
      table.insert(filtered, v)
    end
  end
  return filtered
end

---Checks if a table contains a given value
---@param t table Table to check
---@param value any Value to compare
---@return boolean
function M.contains(t, value)
  for _, v in pairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

---Checks if a table is empty
---@param t table Table to check
---@return boolean
function M.isempty(t)
  return next(t) == nil
end

---Tests if table is a simple any[]
---@param t? table Table
---@return boolean
function M.islist(t)
  if type(t) ~= "table" then
    return false
  end

  local i = 1
  for _ in
  pairs(t --[[@as table<any,any>]])
  do
    if t[i] == nil then
      return false
    end
    i = i + 1
  end

  return true
end

return M
