return {
  -- Local Plugins
  {'hex',
    dir = vim.fn.stdpath('config')..'/lua/hex',
    config = function()
      require('hex').setup()
    end
  },
  -- Colorscheme
  {'AlexvZyl/nordic.nvim',
    name = 'nordic',
    priority = 1000,
    config = function()
        require('nordic').load()
    end
  },
  -- LSP Config
  {'neovim/nvim-lspconfig' },
  {'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({
        symbol_in_winbar = {
          enable = false
        },
      })
    end
  },
  -- Text Stuffs
  {'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({ })
    end
  },
  {'andymass/vim-matchup',
    init = function()
      -- modify your configuration vars here
      vim.g.matchup_treesitter_stopline = 500

      -- or call the setup function provided as a helper. It defines the
      -- configuration vars for you
      require('match-up').setup({
        treesitter = {
          stopline = 500
        }
      })
    end,
  },
  {'unblevable/quick-scope',
    config = function()
      vim.g.qs_enable = 0
      -- note:
      -- use ';' to redo last line-search command
      vim.g.qs_hightlight_on_keys = {'f', 'F', 't', 'T'}
    end
  },
  {'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require'ibl'.setup({
        indent = { char = '┊' },
        scope = { enabled = false }
      })
    end
  },
  -- File Organization
  {'nvim-tree/nvim-tree.lua',
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.opt.termguicolors = true
      require'nvim-tree'.setup({
        view = {
          width = 30,
        },
        filters = {
          git_ignored = false,
        },
      })
    end
  },
}
