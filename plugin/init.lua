local wt = require "wezterm"

local plugin = wt.plugin.list()[1]
if wt.target_triple:find "windows" ~= nil then
  local plugin_dir = plugin.plugin_dir:gsub("\\[^\\]*$", "")
  package.path = package.path .. ";" .. plugin_dir .. "\\?."
else
  local plugin_dir = plugin.plugin_dir:gsub("/[^/]*$", "")
  package.path = package.path .. ";" .. plugin_dir .. "/?."
end

local function lquire(module)
  return require(plugin.component .. "." .. module)
end

local M = {}

local wave = lquire "plugin.schemes.kanagawa-wave"

M.apply_to_config = function(Config)
  return Config
end

return M
