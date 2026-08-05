local dap = require('dap')
local dapui = require('dapui')
local Hydra = require('hydra')

-- Setup DAP UI
dapui.setup({
    icons = { expanded = "▾", collapsed = "▸" },
    layouts = {
        {
            elements = {
                "scopes",
                "breakpoints",
                "stacks",
                "watches",
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                "repl",
                "console",
            },
            size = 10,
            position = "bottom",
        },
    },
})

-- Virtual text for variables
require('nvim-dap-virtual-text').setup()

-- Auto-open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

local function big_scopes()
    dapui.float_element('scopes', {
        enter = true,
        width = math.floor(vim.o.columns * 0.85),
        height = math.floor(vim.o.lines * 0.80),
        position = 'center',
        border = 'rounded',
    })
end

Hydra({
    name = 'Debug',
    mode = { 'n' },
    body = '<leader>d',
    hint = [[
 _c_: continue/start   _n_: step over   _s_: step into   _f_: step out
 _b_: breakpoint       _r_: repl        _t_: ui toggle   _v_: big scopes
 _x_: terminate        _q_: quit hydra
    ]],
    config = {
        color = 'red',
        invoke_on_body = true,
    },
    heads = {
        { 'c', function() dap.continue() end },
        { 'n', function() dap.step_over() end },
        { 's', function() dap.step_into() end },
        { 'f', function() dap.step_out() end },
        { 'b', function() dap.toggle_breakpoint() end },
        { 'r', function() dap.repl.open() end },
        { 't', function() dapui.toggle() end },
        { 'v', big_scopes },
        { 'x', function() dap.terminate() end, { exit = true } },
        { 'q', nil, { exit = true } },
    }
})

vim.keymap.set('n', '<leader>dS', function()
    dapui.float_element('scopes', {
        enter = true,
        width = math.floor(vim.o.columns * 0.85),
        height = math.floor(vim.o.lines * 0.80),
        position = 'center',
        border = 'rounded',
    })
end, { desc = 'Large floating DAP scopes' })

-- Python Debug Adapter (debugpy)
dap.adapters.python = {
    type = 'executable',
    command = 'debugpy-adapter',
}
dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
            local venv = os.getenv('VIRTUAL_ENV')
            if venv then
                return venv .. '/bin/python'
            end
            return '/usr/bin/python3'
        end,
        console = 'integratedTerminal',
    },
}
