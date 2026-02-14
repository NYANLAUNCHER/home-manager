return {
{'L3MON4D3/LuaSnip',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = "v2.*",
  --build = "make install_jsregexp"
},
{'saghen/blink.cmp',
  version = '1.*',
  opts = {
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      menu = { auto_show = true },
      documentation = { auto_show = false }
    },

    -- see :h blink-cmp-config-keymap
    keymap = {
      preset = 'none',
      ['<C-y>'] = { 'show_and_insert', 'accept' },
      ['<C-n>'] = { 'show_and_insert', 'select_next' },
      ['<C-p>'] = { 'show_and_insert', 'select_prev' },
      ['<C-e>'] = { 'cancel' },
    },
    cmdline = {
      keymap = {
        ['<C-y>'] = { 'show_and_insert', 'accept' },
        ['<C-n>'] = { 'show_and_insert', 'select_next' },
        ['<C-p>'] = { 'show_and_insert', 'select_prev' },
        ['<Left>'] = { 'fallback' },
        ['<Right>'] = { 'fallback' },
      },
      completion = {
        menu = { auto_show = false },
        ghost_text = { enabled = true };
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
},
{'windwp/nvim-autopairs',
  event = "InsertEnter", config = function()
    local npairs = require'nvim-autopairs'
    local Rule = require'nvim-autopairs.rule'
    local cond = require 'nvim-autopairs.conds'

    npairs.setup {
      map_cr = true,
    }

    local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
    npairs.add_rules {
      -- Rule for a pair with left-side ' ' and right side ' '
      Rule(' ', ' ')
        -- Pair will only occur if the conditional function returns true
        :with_pair(function(opts)
          -- We are checking if we are inserting a space in (), [], or {}
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({
            brackets[1][1] .. brackets[1][2],
            brackets[2][1] .. brackets[2][2],
            brackets[3][1] .. brackets[3][2]
          }, pair)
        end)
        :with_move(cond.none())
        :with_cr(cond.none())
        -- We only want to delete the pair of spaces when the cursor is as such: ( | )
        :with_del(function(opts)
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local context = opts.line:sub(col - 1, col + 2)
          return vim.tbl_contains({
            brackets[1][1] .. '  ' .. brackets[1][2],
            brackets[2][1] .. '  ' .. brackets[2][2],
            brackets[3][1] .. '  ' .. brackets[3][2]
          }, context)
        end)
    }
    -- For each pair of brackets we will add another rule
    for _, bracket in pairs(brackets) do
      npairs.add_rules {
        -- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
        Rule(bracket[1] .. ' ', ' ' .. bracket[2])
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == bracket[2] end)
          :with_del(cond.none())
          :use_key(bracket[2])
          -- Removes the trailing whitespace that can occur without this
          :replace_map_cr(function(_) return '<C-c>2xi<CR><C-c>O' end)
      }
    end
  end
},
}
