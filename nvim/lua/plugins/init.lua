local delkey = function(mode, lhs) vim.keymap.set(mode, lhs, '<nop>', { noremap=true, silent=true }) end
local keymap = vim.keymap.set
return {
  -- Local Plugins
  {'hex',
    dir = vim.fn.stdpath('config')..'/lua/hex',
    config=function()
      require('hex').setup()
    end
  },
  -- Colorscheme
  {'AlexvZyl/nordic.nvim',
    name = 'nordic',
    priority = 1000,
    config=function()
        require('nordic').load()
    end
  },
  -- Info & Man pages
  {'https://gitlab.com/HiPhish/info.vim',
    config=function()
      -- info page config & keybinds
      vim.api.nvim_create_autocmd({'FileType'}, {
        pattern='info',
        callback=function()
          keymap('n', 'gu',   '<Plug>(InfoUp)')
          keymap('n', 'gn',   '<Plug>(InfoNext)')
          keymap('n', 'gp',   '<Plug>(InfoPrev)')
          keymap('n', 'gm',   '<Plug>(InfoMenu)')
          keymap('n', 'gd',   '<Plug>(InfoFollow)')
          keymap('n', '<Cr>', '<Plug>(InfoFollow)')
        end
      })
      -- man page config & keybinds
      vim.api.nvim_create_autocmd({'FileType'}, {
        pattern='man',
        callback=function()
        end
      })
    end,
  },
  -- LSP Config
  {'neovim/nvim-lspconfig'},
  {'nvimdev/lspsaga.nvim',
    config=function()
      require('lspsaga').setup({
        symbol_in_winbar = {
          enable = true
        },
      })
    end
  },
  -- Text Stuffs
  {'kylechui/nvim-surround',
    event = 'VeryLazy',
    config=function()
      require('nvim-surround').setup({})
    end
  },
  {'andymass/vim-matchup',
    init=function()
      require('match-up').setup({
        treesitter = {
          stopline = 500
        }
      })
    end,
  },
  {'https://codeberg.org/andyg/leap.nvim',
    dependencies={'tpope/vim-repeat'},
    config=function()
      delkey({'n','x','o'}, 's')
      keymap({'n','x','o'}, 's', function ()
        require('leap').leap({
          backward=false,
        })
      end)
      keymap('n', 'S', function ()
        require('leap').leap({
          backward=true,
        })
      end)
    end,
  },
  {'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config=function()
      require'ibl'.setup({
        indent = { char = '┊' },
        scope = { enabled = false }
      })
    end
  },
  -- File Organization
  {'nvim-tree/nvim-tree.lua',
    config=function()
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
