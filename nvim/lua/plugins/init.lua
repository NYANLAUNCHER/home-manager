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
          keymap('n', 'gt',   '<Plug>(InfoGoto)')
          keymap('n', '<Cr>', '<Plug>(InfoFollow)')
          keymap('n', 'gd',   ':call <SNR>15_xRefUnderCursor()<CR><Space>', {noremap=true})
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
  -- Navigation & Text Manipulation
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
  {'folke/flash.nvim',
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
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
      require('nvim-tree').setup({
        view = {
          width = 30,
        },
        filters = {
          git_ignored = false,
        },
      })
    end
  },
  {'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false, -- delete everything before cursor
            ["<C-k>"] = false, -- delete everything after cursor
          },
        }
      }
    },
    config = function()
      local builtin=require('telescope.builtin')
      keymap('n', '<leader>ff', builtin.find_files, {desc="Telescope find files"})
      keymap('n', '<leader>fg', builtin.live_grep, {desc="Telescope live grep"})
    end
  }
}
