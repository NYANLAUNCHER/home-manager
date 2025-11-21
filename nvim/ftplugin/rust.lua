vim.opt.tabstop=2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2

vim.lsp.config.rust_analyzer.setup {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  }
}
