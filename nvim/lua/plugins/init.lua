return {
  -- Colorscheme
  {
    "AlexvZyl/nordic.nvim",
    name = "nordic",
    priority = 1000,
    config = function()
        require('nordic').load()
    end
  },
  -- Text Stuffs
  --"tpope/vim-surround",
  {
    "kylechui/nvim-surround",
    --version = "^3.0.0", -- Use for stability
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({ })
    end
  },
  {
    "unblevable/quick-scope",
    config = function()
      vim.g.qs_enable = 0
      -- note:
      -- use ';' to redo last line-search command
      vim.g.qs_hightlight_on_keys = {'f', 'F', 't', 'T'}
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = 'ibl',
    config = function()
      require'ibl'.setup({
        indent = { char = '┊' },
        scope = { enabled = false }
      })
    end
  },
  {
    "hex",
    dir = vim.fn.stdpath("config").."/lua/hex",
    config = function()
      require('hex').setup({})
    end
  },
  -- File Organization
  {"nvim-tree/nvim-tree.lua",
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.opt.termguicolors = true
      require'nvim-tree'.setup({
        view = {
          width = 30,
        },
        filters = {
          --git_ignored = true,
        },
      })
    end
  },
}
