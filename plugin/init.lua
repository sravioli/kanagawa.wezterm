local wt = require "wezterm"

local M = {}

local path = ...
wt.log_info { path = path }

M.apply_to_config = function(Config)
  return Config
end

return M
