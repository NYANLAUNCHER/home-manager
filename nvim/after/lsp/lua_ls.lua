---@type vim.lsp.Config
return {
  on_init = function (client)
    local join = vim.fs.joinpath
    local path = client.workspace_folders[1].name -- workspace directory
    -- Don't do anything if there is project local config
    if vim.uv.fs_stat(join(path, '.luarc.json'))
      or vim.uv.fs_stat(join(path, '.luarc.jsonc'))
    then
      return
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
        path = { -- (see `:h lua-module-load`)
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath('config'),
        }
      }
    })
  end,
  settings = {
    Lua = {
      diagnostics = {
        disable = { "undefined-global" },
      },
      telemetry = { enable = false },
    }
  }
}
