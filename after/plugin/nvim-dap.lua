local dap, dapui = require('dap'), require('dapui')

dapui.setup()
require('dap-python').setup('~/.virtualenvs/debug_py/bin/python3.10')
require('neodev').setup({
    library = { plugins = { "nvim-dap-ui"}, types = true },
})
require("nvim-dap-virtual-text").setup {
    enabled = true,                        -- enable this plugin (the default)
    enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true,               -- show stop reason when stopped for exceptions
    commented = false,                     -- prefix virtual text with comment string
    only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
    all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
    clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)
    --- A callback that determines how a variable is displayed or whether it should be omitted
    --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
    --- @param buf number
    --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
    --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
    --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
    --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
    display_callback = function(variable, buf, stackframe, node, options)
      if options.virt_text_pos == 'inline' then
        return ' = ' .. variable.value
      else
        return variable.name .. ' = ' .. variable.value
      end
    end,
    -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
    virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

    -- experimental features:
    all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
                                           -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}

vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })

vim.fn.sign_define('DapBreakpoint', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl= 'DapBreakpoint' })
vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

vim.keymap.set( "n", "<F4>", function() require('dapui').toggle() end)
vim.keymap.set( "n", "<Leader>b", function() require('dap').toggle_breakpoint() end)
vim.keymap.set( "n", "<F5>", function() require('dap').toggle_breakpoint() end)
vim.keymap.set( "n", "<F9>", ":lua require('dap').continue()<CR>" )
vim.keymap.set( "n", "<F9>", function() require('dap').terminate() end )

vim.keymap.set( "n", "<F1>", function() dap.step_over() end )
vim.keymap.set( "n", "<F2>", function() dap.step_into() end )
vim.keymap.set( "n", "<F3>", function() dap.step_out() end )

vim.keymap.set( "n", "<Leader>dd", function() require('dap').continue() end)
--vim.keymap.set( "n", "<Leader>dsv", ":lua require('dap').step_over()<CR>" )
--vim.keymap.set( "n", "<Leader>dsi", ":lua require('dap').step_into()<CR>" )
--vim.keymap.set( "n", "<Leader>dso", ":lua require('dap').step_out()<CR>" )

vim.keymap.set( "n", "<Leader>dhh", ":lua require('dap.ui.variables').hover()<CR>" )
vim.keymap.set( "v", "<Leader>dhv", ":lua require('dap.ui.variables').visual_hover()<CR>" )

vim.keymap.set( "n", "<Leader>duh", ":lua require('dap.ui.widgets').hover()<CR>" )
vim.keymap.set( "n", "<Leader>duf", ":lua local widgets=require('dap.ui.widgets');widgets.centered_float(widgets.scopes)<CR>" )

vim.keymap.set( "n", "<Leader>dro", function() dap.repl.open() end)
--vim.keymap.set( "n", "<Leader>dro", ":lua require('dap').repl.open()<CR>" )
vim.keymap.set( "n", "<Leader>dro", ":lua require('dap').repl.open()<CR>" )
vim.keymap.set( "n", "<Leader>drl", ":lua require('dap').repl.run_last()<CR>" )

vim.keymap.set( "n", "<Leader>dbc", ":lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>" )
vim.keymap.set( "n", "<Leader>dbm", ":lua require('dap').set_breakpoint({ nil, nil, vim.fn.input('Log point message: ') )<CR>")
vim.keymap.set( "n", "<Leader>dbt", ":lua require('dap').toggle_breakpoint()<CR>" )

vim.keymap.set( "n", "<Leader>dc", ":lua require('dap.ui.variables').scopes()<CR>" )
vim.keymap.set( "n", "<Leader>di", ":lua require('dapui').toggle()<CR>" )

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
