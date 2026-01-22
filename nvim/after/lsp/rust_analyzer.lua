-- Format current file
function Format()
  local file = vim.api.nvim_buf_get_name(0)
  local workspace_dir = vim.lsp.buf.list_workspace_folders()[1] or ""
  local cfg_file = workspace_dir.."/rustfmt.toml"
  local cfg_args
  if vim.loop.fs_stat(cfg_file) then
    cfg_args = "--edition 2024 --config-path "..cfg_file
  else
    -- Default flags
    cfg_args = [[
      --edition 2024
    ]]
  end
  vim.cmd(string.format("wa | !rustfmt %s %s", cfg_args, file))
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
