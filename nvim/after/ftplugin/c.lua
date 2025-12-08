vim.opt.tabstop=4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4

local dap = require('dap')
dap.configurations.c = dofile(vim.fn.stdpath('config')..'/dap/gdb.lua')
