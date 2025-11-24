local M={
  lsp=require('config.ft.c').lsp, -- copy ccls config
  dap=require('config.ft.c').dap, -- copy gdb config
}
vim.lsp.config(M.lsp.name, M.lsp.cfg)
vim.lsp.enable(M.lsp.name)
require('dap').configurations.cpp = { M.dap }
return M
