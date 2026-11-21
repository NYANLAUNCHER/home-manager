return {
  {'neovim/nvim-lspconfig'},
  {'nvimdev/lspsaga.nvim',
    config=function()
      require('lspsaga').setup({
        symbol_in_winbar = {
          enable = true
        },
        light_bulb = {
          enable = false
        }
      })
    end
  },
  -- Integrations
  {'quarto-dev/quarto-nvim',
    dependencies = {
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
