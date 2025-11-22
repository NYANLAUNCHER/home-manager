vim.bo.tabstop=2
vim.bo.softtabstop=2
vim.bo.shiftwidth=2

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = {
          vim.fn.stdpath("config") .. "/nvim",
        },
      },
      diagnostics = {
        globals = { "vim", "require" },
      },
      runtime = {
        version = "LuaJIT",
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultGuidingStars = false,
      },
    },
  },
})
