return {
{
'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    -- Css
    'roginfarrer/cmp-css-variables',
    'Jezda1337/nvim-html-css',
  },
  config = function()
    local cmp = require('cmp')
    -- TODO:
    -- only use <C-n> & <C-p> to request & navigate completion menu
    -- completion will automatically finish when you start typing again
    -- <C-[> or <ESC> will abort completion
    cmp.setup {
      mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'buffer' },
        { name = 'css-variables' },
        { name = 'nvim-html-css' },
      },
    }
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local servers = vim.lsp.get_clients()
    for _, server in pairs(servers) do
      require('lspconfig')[server].setup {
        capabilities = capabilities,
      }
    end
  end
},
{
  'windwp/nvim-autopairs', event = "InsertEnter", config = function()
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

    local cmp_autopairs = require'nvim-autopairs.completion.cmp'
    local cmp_status_ok, cmp = pcall(require, 'cmp')
    if not cmp_status_ok then
      return
    end
    cmp.event:on('confirm_don', cmp_autopairs.on_confirm_done {map_char = {tex = ''}})
  end
},
}
