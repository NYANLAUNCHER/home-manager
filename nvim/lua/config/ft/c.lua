local M={
  opt = { -- vim.bo
    tabstop=2,
    softtabstop=2,
    shiftwidth=2,
  },
  lsp = {
    name = "ccls",
    cfg = {
      init_options = {
        compilationDatabaseDirectory = "build",
        index = {
          threads = 0,
        },
        clang = {
          excludeArgs = { "-frounding-math"}
        },
      }
    }
  },
  dap = {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  }
}
vim.lsp.config(M.lsp.name, M.lsp.cfg)
vim.lsp.enable(M.lsp.name)
require('dap').configurations.c = { M.dap }

return M
