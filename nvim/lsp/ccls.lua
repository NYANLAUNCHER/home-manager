return {
  root_markers = { ".ccls" },
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
