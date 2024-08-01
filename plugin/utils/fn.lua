---@diagnostic disable: undefined-field

---Various utility functions
---
---@module "utils.fn"
---@author sravioli
---@license GNU-GPLv3

local wt = require "wezterm"
local G = wt.GLOBAL
local Kanagawa = G["kanagawa.wezterm"]

---User defined utility functions
---@class Utils.Fn
---@field fs    Utils.Fn.FileSystem
---@field color Utils.Fn.Color
local M = {}

---Merges two tables
---@param t1 table
---@param ... table[] one or more tables to merge
---@return table t1 modified t1 table
M.tbl_merge = function(t1, ...)
  local tables = { ... }

  for i = 1, #tables do
    local t2 = tables[i]
    for k, v in pairs(t2) do
      if type(v) == "table" then
        if type(t1[k] or false) == "table" then
          M.tbl_merge(t1[k] or {}, t2[k] or {})
        else
          t1[k] = v
        end
      else
        t1[k] = v
      end
    end
  end

  return t1
end

---Memoize the function return value in the given `wezterm.GLOBAL` key
---@param key string key in which to memoize fn return value
---@param value any function to memoize
---@return any value function that returns the cached value
M.gmemoize = function(key, value)
  local is_fn = type(value) == "function"
  if G[key] == nil then
    G[key] = is_fn and value() or value
  end
  return is_fn and function()
    return G[key]
  end or value
end

---Wrapper for require to use locally
---@param module string
---@return unknown, unknown|nil
M.lrequire = function(module)
  return require(Kanagawa.component .. ".plugin." .. module)
end

-- {{{1 Utils.Fn.FileSystem

---@class Utils.Fn.FileSystem
---@field private target_triple string
M.fs = {}

M.fs.target_triple = M.gmemoize("target_triple", wt.target_triple)

-- {{{2 META

---@class Utils.Fn.FileSystem.Platform
---@field os "windows"|"linux"|"mac"|"unknown" The operating system name
---@field is_win boolean Whether the platform is Windows.
---@field is_linux boolean Whether the platform is Linux.
---@field is_mac boolean Whether the platform is Mac.

-- }}}

---Determines the platform based on the target triple.
---
---This function checks the target triple string to determine if the platform is Windows,
---Linux, or macOS.
---
---@return Utils.Fn.FileSystem.Platform platform
M.fs.platform = M.gmemoize("plaftorm", function()
  local is_win = M.fs.target_triple:find "windows" ~= nil
  local is_linux = M.fs.target_triple:find "linux" ~= nil
  local is_mac = M.fs.target_triple:find "apple" ~= nil
  local os = is_win and "windows" or is_linux and "linux" or is_mac and "mac" or "unknown"
  return { os = os, is_win = is_win, is_linux = is_linux, is_mac = is_mac }
end)

local is_win = M.fs.platform().is_win

---Path separator based on the platform.
---
---This variable holds the appropriate path separator character for the current platform.
M.fs.path_separator = M.gmemoize("path_separator", is_win and "\\" or "/")

---Loads the plugin submodules that would otherwise not be loaded
---@param Plugin Plugin
---@return nil
M.fs.load_submodules = function(Plugin)
  local plugins = wt.plugin.list()
  for i = 1, #plugins do
    if plugins[i].url == Plugin.url then
      Plugin.dir = plugins[i].plugin_dir
      Plugin.component = plugins[i].component
      break
    end
  end

  if not Plugin.dir or not Plugin.component then
    return wt.log_error { [Plugin.name] = "Unable to find plugin!" }
  end

  if is_win then
    local plugin_dir = Plugin.dir:gsub("\\[^\\]*$", "")
    package.path = package.path .. ";" .. plugin_dir .. "\\?.lua"
  else
    local plugin_dir = Plugin.dir:gsub("/[^/]*$", "")
    package.path = package.path .. ";" .. plugin_dir .. "/?.lua"
  end
end
-- }}}

-- {{{1 Utils.Fn.Color

---@class Utils.Fn.Color
M.color = {}

---Sets the tab button style in the configuration based on the specified theme.
---
---This function updates the `config` object to set the style for the tab buttons
---(`new_tab` and `new_tab_hover`) using the color scheme provided in the `theme` object.
---It constructs the button layout with appropriate colors, separators, and text attributes.
---
---@usage
---```lua
---local config = {}
---local theme = {
---  tab_bar = {
---    new_tab = { bg_color = "#000000", fg_color = "#FFFFFF", intensity = "Bold" },
---    new_tab_hover = { bg_color = "#111111", fg_color = "#EEEEEE", italic = true },
---    background = "#222222"
---  }
---}
---M.color.set_tab_button(config, theme)
---```
---
---@param config table The configuration object to be updated with tab button styles.
---@param theme table The theme object containing color schemes for different tab states.
M.color.set_tab_button = function(config, theme)
  config.tab_bar_style = {}
  local sep = {
    leftmost = "▐",
    left = wt.nerdfonts.ple_upper_right_triangle,
    right = wt.nerdfonts.ple_lower_left_triangle,
  }

  for _, state in ipairs { "new_tab", "new_tab_hover" } do
    local style = theme.tab_bar[state]
    local sep_bg, sep_fg = style.bg_color, theme.tab_bar.background

    ---@class Layout
    local ButtonLayout = M.lrequire("utils.layout"):new()
    local attributes = {
      style.intensity
        or (style.italic and "Italic")
        or (style.strikethrough and "Strikethrough")
        or (style.underline ~= "None" and style.underline),
    }

    ButtonLayout:push(sep_bg, sep_fg, sep.right, attributes)
    ButtonLayout:push(sep_bg, style.fg_color, " + ", attributes)
    ButtonLayout:push(sep_bg, sep_fg, sep.left, attributes)

    config.tab_bar_style[state] = ButtonLayout:format()
  end
end

M.color.set_scheme = function(Config, theme, name)
  Config.color_scheme = name
  Config.char_select_bg_color = theme.brights[6]
  Config.char_select_fg_color = theme.background
  Config.command_palette_bg_color = theme.brights[6]
  Config.command_palette_fg_color = theme.background
  Config.background = {
    { source = { Color = theme.background }, width = "100%", height = "100%" },
  }
  M.color.set_tab_button(Config, theme)
end

-- }}}

return M

-- vim: fdm=marker fdl=0
