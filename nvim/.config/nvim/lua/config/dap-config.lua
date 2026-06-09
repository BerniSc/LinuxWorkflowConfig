local dap = require('dap')
local dapui = require('dapui')

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

-- C/C++ Debug Adapter (using lldb via Mason)
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-mi', -- or adapt path if needed
    name = 'lldb'
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
}
dap.configurations.c = dap.configurations.cpp

-- Rust Debug Adapter
dap.adapters.rust = {
    type = 'executable',
    command = 'lldb-mi',
    name = 'rust'
}

dap.configurations.rust = {
    {
        name = 'Launch',
        type = 'rust',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
}

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
            -- For pipx installations, use the system python where debugpy is available
            return '/usr/bin/python3'
        end,
        console = 'integratedTerminal',
    },
}

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
            return '/usr/bin/python'
        end,
    },
}
