local _ = require('config').setup() -- initialize [lazy.nvim](https://github.com/folke/lazy.nvim)
local u = require('config.util')

-- Options: (:help lua-guide-options) {{{
vim.cmd("filetype plugin indent on")
vim.cmd("packadd! matchit")

vim.opt.syntax="on"
vim.opt.shortmess="a"-- short message, see :h "shm"
vim.opt.errorbells=true
vim.opt.timeoutlen=800
vim.opt.splitbelow=true
vim.opt.splitright=true
vim.opt.mouse=""
-- Navigation
vim.opt.scrolloff=8
vim.opt.sidescrolloff=6
vim.opt.relativenumber=true
vim.opt.number=true
vim.opt.wrap=false
vim.opt.signcolumn="yes"
vim.opt.foldcolumn="auto"
vim.opt.foldmethod="marker"
vim.opt.colorcolumn="100"
vim.opt.cmdheight=2
-- Search
vim.opt.magic=true
vim.opt.smartcase=true
vim.opt.ignorecase=true
vim.opt.hlsearch=true
vim.opt.incsearch=true
vim.opt.showmatch=true
-- Text Stuffs
vim.opt.virtualedit:append("block")
vim.opt.tabstop=2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2
vim.opt.expandtab=true
vim.opt.smarttab=true
vim.opt.autoindent=true
vim.opt.shiftround=true
-- Files
vim.opt.autochdir=true
vim.opt.exrc=true
vim.opt.hidden=true
vim.opt.autoread=true
vim.opt.swapfile=false
vim.opt.backup=false
vim.opt.writebackup=false
vim.opt.undodir=vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile=true
--}}}
-- Keymaps: {{{
local keymap = vim.keymap.set
local delkey = vim.keymap.del
-- set the leader key
vim.g.leader=" "

-- ESC terminal mode
keymap("t", "<C-[>", "<C-\\><C-n>")

-- Scroll Buffer
keymap("n", "J", "<C-e>")
keymap("n", "K", "<C-y>")

-- (Readline) Insert Mode Bindings
--- movement
keymap("i", "<C-j>", "<Cr>")-- newline
keymap("i", "<C-a>", "<Esc>^i")-- goto start of text
keymap("i", "<C-e>", "<Esc>$a")-- goto end of line
keymap("i", "<C-f>", "<C-right>")-- skip to end of word
keymap("i", "<C-b>", "<C-left>")-- go back a word
keymap("i", "<C-k>", "<Esc>lv$hda")-- delete to end of text
--- completion
keymap("i", "<C-i>", "")-- request completion
keymap("i", "<C-/>", "")-- digraph menu, set to <C-k> by default

-- Navigate Buffers
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

-- Resize Buffers
keymap("n", "<C-Up>", ":resize -2<CR>")
keymap("n", "<C-Down>", ":resize +2<CR>")
keymap("n", "<C-Left>", ":vertical resize -2<CR>")
keymap("n", "<C-Right>", ":vertical resize +2<CR>")

-- Toggle Buffer Maximized
keymap("n", "<C-w>m", function() ToggleBufferMaximized() end, {silent = true})

-- Append Line
keymap("n", ",o", "o<ESC>")
keymap("n", ",O", "O<ESC>")

-- Use Sys Cliboard
vim.g.clipboard = {"unamedplus"}
keymap("n", "<leader>Y", "\"+yg_")
keymap({"n", "v"}, "<leader>y", "\"+y")
keymap({"n", "v"}, "<leader>p", "\"+p")
keymap({"n", "v"}, "<leader>P", "\"+P")

-- Misc.
-- clear highlight and update diff mode
keymap("n", "<C-[>", ":nohlsearch<CR>:diffupdate<CR><C-L>", { noremap = true, silent = true })
keymap("n", "<space><space>", function() PingCursor() end)
--}}}
-- Commands, Functions, & and Augroups: {{{
vim.cmd([[
com! Q q!
com! Qa qa!
com! W w!
com! Reload source $MYVIMRC
]])

vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.fn.bufname() ~= "" then
      vim.cmd("silent write")
    end
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  pattern = "",
  callback = function()
    vim.api.nvim_buf_delete(0, { force=true })
  end
})

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
    vim.cmd("vertical resize")
    vim.cmd("resize")
    bufferMaximized = 1
  else
    vim.cmd('exe "normal \\<C-w>="')
    bufferMaximized = 0
  end
end
--}}}
