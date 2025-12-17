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

  -- enable lsp configs in $XDG_CONFIG_HOME/nvim/lsp/ based on filetype
  --M.util.run_on_each_file(vim.fn.stdpath("config").."/lsp", function(dir, file)
  --  local lsp_name = file:match("^(.*)%.") or file -- remove file extention (i.e. *.lua)
  --  local config=dofile(dir..'/'..file)
  --  local filetypes=config.filetypes
  --  if filetypes then
  --    vim.api.nvim_create_autocmd('FileType', {
  --      pattern=filetypes,
  --      callback=function()
  --        vim.lsp.enable(lsp_name)
  --      end
  --    })
  --  end
  --end)
end

return M
