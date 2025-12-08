local _ = require('config').setup()
local u = require('config.util')
local keymap = vim.keymap.set
local delkey = function(mode, lhs) vim.keymap.set(mode, lhs, '<nop>', { noremap=true, silent=true }) end

-- LSP Config: {{{
  vim.lsp.config('*', {
    root_markers = { '.git/', 'Makefile', '.editorconfig' },
    -- :h lsp-root_dir()
    --root_dir = function(bufnr, on_dir)
    --  -- fallback to the directory of the current buffer
    --  return vim.fn.expand("%:p:h")
    --end
  })
  -- Keymaps:
  -- unmap some hideous defaults first
  delkey('n', 'H')
  delkey('n', '<C-e>')
  delkey('n', '<C-q>')
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.diagnostic.config({ virtual_text = true })
  keymap('n', '<C-e>', function() vim.diagnostic.open_float()                 end)
  keymap('n', '[d',    function() vim.diagnostic.jump({count=1, float=true})  end)
  keymap('n', ']d',    function() vim.diagnostic.jump({count=-1, float=true}) end)
  keymap('n', '<C-q>', function() vim.diagnostic.setloclist()                 end)
  -- only apply these after lsp is attached
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local opts = { buffer = ev.buf }
      keymap('n', 'gD', vim.lsp.buf.declaration, opts)
      keymap('n', 'gd', vim.lsp.buf.definition, opts)
      keymap('n', 'H', vim.lsp.buf.hover, opts)
      keymap('n', 'gi', vim.lsp.buf.implementation, opts)
      keymap('n', '<A-h>', vim.lsp.buf.signature_help, opts)
      keymap('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
      keymap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
      keymap('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      keymap('n', '<space>D', vim.lsp.buf.type_definition, opts)
      keymap('n', '<space>rn', vim.lsp.buf.rename, opts)
      keymap({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
      keymap('n', 'gr', vim.lsp.buf.references, opts)
      keymap('n', '<space>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end,
  })
--}}}
-- Options: (:help lua-guide-options) {{{
vim.cmd('filetype plugin indent on')
vim.cmd('packadd! matchit')

vim.opt.syntax='on'
vim.opt.shortmess='a'-- short message, see :h 'shm'
vim.opt.errorbells=true
vim.opt.timeoutlen=800
vim.opt.splitbelow=true
vim.opt.splitright=true
vim.opt.mouse=''
-- Command
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
-- Navigation
vim.opt.scrolloff=8
vim.opt.sidescrolloff=6
vim.opt.relativenumber=true
vim.opt.number=true
vim.opt.wrap=false
vim.opt.signcolumn='yes'
vim.opt.foldcolumn='auto'
vim.opt.foldmethod='marker'
vim.opt.colorcolumn='100'
vim.opt.cmdheight=2
-- Search
vim.opt.magic=true
vim.opt.smartcase=true
vim.opt.ignorecase=true
vim.opt.hlsearch=true
vim.opt.incsearch=true
vim.opt.showmatch=true
-- Text Stuffs
vim.opt.virtualedit:append('block')
vim.opt.autoindent=true
vim.opt.shiftround=true
vim.opt.tabstop=2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2
vim.opt.expandtab=true
vim.opt.smarttab=true
-- colorize hardtabs and trailing spaces
vim.api.nvim_set_hl(0, 'TabHighlight', { bg = '#a6a6a6', fg = 'white' })
-- Files
vim.opt.autochdir=true
vim.opt.exrc=true
vim.opt.hidden=true
vim.opt.autoread=true
vim.opt.swapfile=false
vim.opt.backup=false
vim.opt.writebackup=false
vim.opt.undodir=vim.fn.stdpath('data') .. '/undo'
vim.opt.undofile=true
--}}}
-- Keymaps: {{{
-- Delete Keys:
delkey('n', '<C-y>') --> K
delkey('n', '<C-e>') --> J

-- set the leader key
vim.g.leader=' '

-- ESC terminal mode
keymap('t', '<C-[>', '<C-\\><C-n>')

-- Scroll Buffer
keymap('n', 'J', '<C-e>')
keymap('n', 'K', '<C-y>')

-- Command Mode Bindings
keymap('c', '<C-a>', '<HOME>')-- goto start of text
keymap('c', '<C-e>', '<END>')-- goto end of line

-- Insert Mode Bindings
--- movement
keymap('i', '<C-a>', '<Esc>^i')-- goto start of text
keymap('i', '<C-e>', '<Esc>$a')-- goto end of line
keymap('i', '<C-f>', '<C-right>')-- skip to end of word
keymap('i', '<C-b>', '<C-left>')-- go back a word
keymap('i', '<C-k>', '<Esc>lv$hda')-- delete to end of text
--- completion
keymap('i', '<C-i>', '')-- request completion
keymap('i', '<C-/>', '')-- digraph menu, set to <C-k> by default

-- Navigate Buffers
keymap('n', '<C-h>', '<C-w>h')
keymap('n', '<C-j>', '<C-w>j')
keymap('n', '<C-k>', '<C-w>k')
keymap('n', '<C-l>', '<C-w>l')

-- Resize Buffers
keymap('n', '<C-Up>', ':resize -2<CR>')
keymap('n', '<C-Down>', ':resize +2<CR>')
keymap('n', '<C-Left>', ':vertical resize -2<CR>')
keymap('n', '<C-Right>', ':vertical resize +2<CR>')

-- Toggle Buffer Maximized
keymap('n', '<C-w>m', function() ToggleBufferMaximized() end, {silent = true})

-- Append Line
keymap('n', ',o', 'o<ESC>')
keymap('n', ',O', 'O<ESC>')

-- Use Sys Cliboard
vim.g.clipboard = {'unamedplus'}
keymap('n', '<leader>Y', '\'+yg_')
keymap({'n', 'v'}, '<leader>y', '\'+y')
keymap({'n', 'v'}, '<leader>p', '\'+p')
keymap({'n', 'v'}, '<leader>P', '\'+P')

-- Misc.
-- clear highlight and update diff mode
keymap('n', '<C-[>', ':nohlsearch<CR>:diffupdate<CR><C-L>', { noremap = true, silent = true })
keymap('n', '<space><space>', function() PingCursor() end)
--}}}
-- Commands, Functions, & and Augroups: {{{
vim.cmd([[
com! Q q!
com! Qa qa!
com! W w!
com! MKS
com! Reload source $MYVIMRC
]])

vim.api.nvim_create_autocmd('BufWinLeave', {
  pattern = '*',
  callback = function()
    if vim.bo.modified and vim.fn.bufname() ~= '' then
      vim.cmd('silent write')
    end
  end,
})

vim.api.nvim_create_autocmd('TermClose', {
  pattern = '',
  callback = function()
    vim.api.nvim_buf_delete(0, { force=true })
  end
})

vim.cmd('com! TrimTrailingWhitespace lua TrimTrailingWhitespace()')
vim.cmd('com! Ttw TrimTrailingWhitespace')
function TrimTrailingWhitespace()
  local curpos = vim.api.nvim_win_get_cursor(0)
  vim.cmd([[keeppatterns %s/\\s\\+$//e]])
  vim.api.nvim_win_set_cursor(0, curpos)
end

function PingCursor()
  -- Enable highlighting
  vim.opt.cursorline = true
  vim.opt.cursorcolumn = true
  local flashes = 3
  local delay = 175
  local count = 0
  local timer = vim.loop.new_timer()
  timer:start(0, delay, function()
    vim.schedule(function()
      -- Toggle cursor line/column
      local on = (count % 2 == 0)
      vim.opt.cursorline = on
      vim.opt.cursorcolumn = on

      count = count + 1
      if count >= flashes * 2 then
        timer:stop()
        timer:close()
        -- Restore to default (off)
        vim.opt.cursorline = false
        vim.opt.cursorcolumn = false
      end
    end)
  end)
end

local bufferMaximized = 0
function ToggleBufferMaximized()
  if bufferMaximized == 0 then
    vim.cmd('vertical resize')
    vim.cmd('resize')
    bufferMaximized = 1
  else
    vim.cmd('exe "normal \\<C-w>="')
    bufferMaximized = 0
  end
end
--}}}
