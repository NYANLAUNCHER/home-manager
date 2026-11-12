---@type vim.lsp.Config
return {
  filetypes = { 'toml' },
  root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
  cmd = { 'taplo', 'lsp', 'stdio' },
}
