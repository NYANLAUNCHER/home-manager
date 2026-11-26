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
  vis:command("set showtabs false")
  vis:command("set showspaces false")
  vis:command("set expandtab off")
  vis:command("set shell /usr/bin/env bash")
end)

-- Plugins
local treeview = require('plugins/treeview')
treeview.setup()
