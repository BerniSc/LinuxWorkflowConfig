-- autocmds.lua
-- Global autocommands that don't belong to a specific plugin config

-- Vim Tips - fetches a random tip on startup and displays it as a notification
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.schedule(function()
            local job = require('plenary.job')
            job:new({
                command = 'curl',
                args = { '-L', 'https://vtip.43z.one' },
                on_exit = function(j, exit_code)
                    vim.schedule(function()
                        local res = table.concat(j:result())
                        if exit_code ~= 0 then
                            res = 'Error fetching tip: ' .. res
                        end
                        require("notify")(res, "info", {
                            title = "Vim Tip!",
                            render = "simple",
                            stages = "static",
                            timeout = 6000
                        })
                    end)
                end,
            }):start()
        end)
    end,
})

----------------------
-- MakefileGen: autogenerate a Makefile from the current dir in nvim-tree
-- Keymaps are only active inside the NvimTree buffer
----------------------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
        local makefile_template = require('tools.MakefileGen')
        vim.keymap.set('n', '<leader>gm', makefile_template.create_makefile_template, { buffer = true, desc = "Create Makefile" })
        vim.keymap.set('n', '<leader>gc', function()
            vim.fn.system('compiledb make')
            print("compile_commands.json generated with compiledb make")
        end, { buffer = true, desc = "Run compiledb make" })
    end
})

------------------------------------------------------------------------
-- Custom config for history plugin to always ASK for a new title
-- on sc, keep sC to save under the default auto-generated title
------------------------------------------------------------------------
local function save_chat_with_title()
    vim.ui.input({ prompt = "Enter chat title: " }, function(input)
        if input and input ~= "" then
            local codecompanion = require("codecompanion")
            local success, chat = pcall(function()
                return codecompanion.buf_get_chat(0)
            end)
            if success and chat then
                vim.schedule(function()
                    if not chat.opts then chat.opts = {} end
                    chat.opts.title = input
                    local ok, history_ext = pcall(require, "codecompanion._extensions.history")
                    if ok and history_ext and history_ext.exports and history_ext.exports.save_chat then
                        history_ext.exports.save_chat(chat)
                        vim.notify("Chat saved with title: " .. input, vim.log.levels.INFO)
                    else
                        vim.notify("History extension not available", vim.log.levels.ERROR)
                    end
                end)
            else
                vim.notify("No active CodeCompanion chat found", vim.log.levels.ERROR)
            end
        else
            vim.notify("Save cancelled (no title entered)", vim.log.levels.INFO)
        end
    end)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "codecompanion",
    callback = function(event)
        vim.keymap.set("n", "sc", save_chat_with_title, { buffer = event.buf, desc = "Save chat with title" })
    end,
})
