vim.opt.tabstop=2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2

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
