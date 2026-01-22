-- Format current file
function Format()
  local file = vim.api.nvim_buf_get_name(0)
  local workspace_dir = vim.lsp.buf.list_workspace_folders()[1] or ""
  vim.cmd(string.format("wa | !rustfmt --config-path %s %s", workspace_dir, file))
end
-- Alias for Format()
vim.cmd([[
com! Fmt :lua Format()
cnoreabbrev fmt Fmt
]])
return {
  filetypes = {'rust'},
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  }
}
