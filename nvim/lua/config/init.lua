local M={}
M.util=require('config.util')

M.setup = function()
  -- Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)

  -- Make sure to setup `mapleader` and `maplocalleader` before
  -- loading lazy.nvim so that mappings are correct.
  -- This is also a good place to setup other settings (vim.opt)
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  -- Setup lazy.nvim
  require('lazy').setup({
    lockfile = vim.fn.stdpath("config") .. "/lua/plugins/lazy-lock.json",
    spec = {
      { import = 'plugins' },
    },
    install = { colorscheme = { "nordic" } },
    checker = { enabled = false },
    change_detection = { notify = false },
    browser = nil,
  })

  local get_root_dir = function(markers)
    local cwd = vim.fn.expand('%:p:h')  -- Get the current file's directory
    local path = cwd
    while path ~= '/' do
      for _, marker in ipairs(markers) do
        if vim.fn.glob(path .. '/' .. marker) ~= '' then
          print(path)
          return path  -- Return the root directory if the marker is found
        end
      end
      -- Move up to the parent directory
      path = vim.fn.fnamemodify(path, ':h')
    end
    return cwd
  end

  -- Enable all LSP servers in ~/.config/nvim/after/lsp/
  local f = function(dir, file)
    local lsp_name = file:match("^(.*)%.") or file
    vim.lsp.enable(lsp_name)
  end
  local dir = vim.fn.stdpath("config")..'/after/lsp'
  if M.util.is_dir(dir) then
    M.util.run_on_each_file(dir, f)
  end
end

return M
