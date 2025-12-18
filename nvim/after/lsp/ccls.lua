return {
  filetypes = { 'c', 'cpp', 'cuda' },
  root_markers = { '.ccls', 'compile_commands.json' },
  init_options = {
    compilationDatabaseDirectory = 'build',
    index = {
      threads = 0,
    },
    clang = {
      excludeArgs = { '-frounding-math'}
    },
  }
}
