---@type vim.lsp.Config
return {
  filetypes = { 'c', 'cpp', 'cuda' },
  root_markers = { 'compile_commands.json' },
  init_options = {
    compilationDatabaseDirectory = 'build',
  }
}
