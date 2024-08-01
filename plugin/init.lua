---@module "kanagawa.wezterm"
---@author sravioli
---@license GNU-GPLv3

local wt = require "wezterm"

local M = {}

-- {{{1 class: Plugin

wt.GLOBAL["kanagawa.wezterm"] = {
  name = "kanagawa.wezterm",
  url = "https://www.github.com/sravioli/kanagawa.wezterm",
  component = "httpssCssZssZswwwsDsgithubsDscomsZssraviolisZskanagawasDswezterm",
  dir = nil,
}

---@class Plugin
---@field name string
---@field url string
---@field component string
---@field dir nil|string
local Kanagawa = wt.GLOBAL["kanagawa.wezterm"]
-- }}}

-- {{{1 allow loading submodules

local plugins = wt.plugin.list()
for i = 1, #plugins do
  if plugins[i].url == Kanagawa.url then
    Kanagawa.dir = plugins[i].plugin_dir
    Kanagawa.component = plugins[i].component
    break
  end
end

if not Kanagawa.dir or not Kanagawa.component then
  return wt.log_error { [Kanagawa.name] = "Unable to find plugin!" }
end

if wt.target_triple:find "windows" ~= nil then
  local plugin_dir = Kanagawa.dir:gsub("\\[^\\]*$", "")
  package.path = package.path .. ";" .. plugin_dir .. "\\?.lua"
else
  local plugin_dir = Kanagawa.dir:gsub("/[^/]*$", "")
  package.path = package.path .. ";" .. plugin_dir .. "/?.lua"
end
-- }}}

---Wrapper for require to use locally
---@param module string
---@return unknown, unknown|nil
local function lrequire(module)
  return require(Kanagawa.component .. ".plugin." .. module)
end

local fn = lrequire "utils.fn"
local options = { scheme = "kanagawa-wave" }

M.apply_to_config = function(Config, opts)
  opts = fn.tbl_merge(options, opts or {})
  local theme = lrequire("schemes." .. opts.scheme)
  fn.color.set_scheme(Config, theme, opts.scheme)
end

return M
