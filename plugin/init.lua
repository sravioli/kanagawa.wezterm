---@module "kanagawa.wezterm"
---@author sravioli
---@license GNU-GPLv3

local wt = require "wezterm"

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

---@class Utils.Fn
local fn = require(Kanagawa.component .. ".plugin.utils.fn")
fn.fs.load_submodules(Kanagawa)

local M = {}

local options = { scheme = "kanagawa-wave" }

M.apply_to_config = function(Config, opts)
  opts = fn.tbl_merge(options, opts or {})
  local theme = fn.lrequire("schemes." .. opts.scheme)
  fn.color.set_scheme(Config, theme)
  fn.color.set_tab_button(Config, theme)
end

return M
