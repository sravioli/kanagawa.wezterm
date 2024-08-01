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

---Wrapper for require to use locally
---@param module string
---@return unknown, unknown|nil
M.lrequire = function(module)
  return require(Kanagawa.component .. ".plugin." .. module)
end

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
---color.set_tab_button(config, theme)
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
