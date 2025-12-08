return {
  'mfussenegger/nvim-dap', main = 'dap',
  config = function()
    local dap = require('dap')
    local widgets = require('dap.ui.widgets')
    --vim.keymap.set('n', '<F5>', function() dap.continue() end)
    --vim.keymap.set('n', '<F10>', function() dap.step_over() end)
    --vim.keymap.set('n', '<F11>', function() dap.step_into() end)
    --vim.keymap.set('n', '<F12>', function() dap.step_out() end)
    vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end)
    vim.keymap.set('n', '<Leader>B', function() dap.set_breakpoint() end)
    vim.keymap.set('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
    vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end)
    vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end)
    vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
      require('dap.ui.widgets').hover()
    end)
    vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
     widgets.preview()
    end)
    vim.keymap.set('n', '<Leader>df', function()
      widgets.centered_float(widgets.frames)
    end)
    vim.keymap.set('n', '<Leader>ds', function()
      widgets.centered_float(widgets.scopes)
    end)
    -- Signs
    vim.fn.sign_define('DapBreakpoint',          {text='B', texthl='Error', linehl='', numhl=''})
    vim.fn.sign_define('DapBreakpointCondition', {text='C', texthl='Error', linehl='', numhl=''})
    vim.fn.sign_define('DapLogPoint',            {text='L', texthl='WarningMsg', linehl='', numhl=''})
    vim.fn.sign_define('DapStopped',             {text='→', texthl='WarningMsg', linehl='', numhl=''})
    vim.fn.sign_define('DapBreakpointRejected',  {text='R', texthl='Error', linehl='', numhl=''})
    -- Repl Completion
    vim.api.nvim_create_autocmd({'FileType'}, {
      pattern = 'dap-repl',
      callback = function()
        require('dap.ext.autocompl').attach()
      end
    })
  end
}
