require('vis')

-- Global
vis.events.subscribe(vis.events.INIT, function()
  vis:command("set theme nord")
end)

-- Per-window
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  vis:command("set tabwidth 4") -- configure per filetype in filetype/<filetype>.lua
  vis:command("set numbers true")
  vis:command("set autoindent true")
  vis:command("set relativenumbers true")
  vis:command("set layout v")
  vis:command("set shell /usr/bin/env bash")
end)

-- Plugins
---@param path string Module path passed to require
---@param fn_success fun(value: tbl) Passes the first return value of the module if it is a table, otherwise passes empty table
---@param fn_fail? function Optionally run function on failure
local load_plugin = function(path, fn_success, fn_fail)
  local success, value = pcall(require, path)
  if type(value) ~= "table" then
    value={}-- Return an empty table if module table not returned
  end
  if success then
    fn_success(value)
  else
    if type(fn_fail)=="function" then
      fn_fail()
    else
      vis:info("WARN: failed to load plugin: "..path)
    end
  end
end

-- https://github.com/stalker57241/treeview
load_plugin('plugins/treeview', function(treeview)
  treeview.setup()
end)

load_plugin('plugins/vis-lspc', function(treeview) -- https://gitlab.com/muhq/vis-lspc
  lspc.setup()
end)
