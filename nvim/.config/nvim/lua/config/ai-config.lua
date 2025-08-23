-- Ai-Config.lua 
-- Holds default configuration and setup of nvim AI tools

local function load_env_config(path)
    local status = vim.loop.fs_stat(path)
    if status then
        local env_config = dofile(path)
        return env_config
    end
    return {}
end

local base_config = {
    extensions = {
        history = {
            enabled = true,
            opts = {
                auto_save = false,
                save_chat_keymap = "sC",
                auto_generate_title = false,
            }
        }
    },
    strategies = {
        chat = {
            keymaps = {
                close = {
                    modes = {
                        n = "<C-c>",
                        i = "<C-c>",
                    },
                    index = 3,
                    callback = function()
                        require("codecompanion").toggle()
                    end,
                    description = "Toggle Chat",
                },
                next_chat = {
                    modes = {
                        n = "<leader>>",
                    },
                    index = 11,
                    callback = "keymaps.next_chat",
                    description = "Next Chat",
                },
                previous_chat = {
                    modes = {
                        n = "<leader><",
                    },
                    index = 12,
                    callback = "keymaps.previous_chat",
                    description = "Previous Chat",
                },
            },
            adapter = "copilot",
        },
        inline = {
            adapter = "copilot",
        },
    },
}


-- Load environment-specific configuration
local env_config_path = "/opt/ai-configs/localaiconfig.lua"
local env_config = load_env_config(env_config_path)

------------------------------------------------------------------------
-- Custom config for history plugin to always ASK for a new title
-- on sc, keep sC to save under default title
------------------------------------------------------------------------
local function save_chat_with_title()
    vim.ui.input({ prompt = "Enter chat title: " }, function(input)
        if input and input ~= "" then
            require("codecompanion-history").save_chat({ title = input })
        else
            vim.notify("Save cancelled (no title entered)", vim.log.levels.INFO)
        end
    end)
end

-- Remap `sc` in chat buffers to use custom save
vim.api.nvim_create_autocmd("FileType", {
    -- only inside CodeCompanion chat buffers
    pattern = "codecompanion", 
    callback = function(event)
        vim.keymap.set("n", "sc", save_chat_with_title, { buffer = event.buf, desc = "Save chat with title" })
    end,
})

------------------------------------------------------------------------
-- Save/Restore for CodeCompanionchats - Will not restore in buffer 
-- and will not continue chat, but good for sharing
-- For continue we use the history plugin
-- https://gist.github.com/itsfrank/942780f88472a14c9cbb3169012a3328
------------------------------------------------------------------------
-- create a folder to store our chats
local Path = require("plenary.path")
local data_path = vim.fn.stdpath("data")
local save_folder = Path:new(data_path, "cc_saves")
if not save_folder:exists() then
    save_folder:mkdir({ parents = true })
end

-- telescope picker for our saved chats
vim.api.nvim_create_user_command("CodeCompanionLoad", function()
    local t_builtin = require("telescope.builtin")
    local t_actions = require("telescope.actions")
    local t_action_state = require("telescope.actions.state")

    local function start_picker()
        t_builtin.find_files({
            prompt_title = "Saved CodeCompanion Chats | <c-d>: delete",
            cwd = save_folder:absolute(),
            attach_mappings = function(_, map)
                map("i", "<c-d>", function(prompt_bufnr)
                    local selection = t_action_state.get_selected_entry()
                    local filepath = selection.path or selection.filename
                    os.remove(filepath)
                    t_actions.close(prompt_bufnr)
                    start_picker()
                end)
                return true
            end,
        })
    end
    start_picker()
end, {})

-- save current chat, `CodeCompanionSave foo bar baz` will save as 'foo-bar-baz.md'
vim.api.nvim_create_user_command("CodeCompanionSave", function(opts)
    local codecompanion = require("codecompanion")
    local success, chat = pcall(function()
        return codecompanion.buf_get_chat(0)
    end)
    if not success or chat == nil then
        vim.notify(
            "CodeCompanionSave should only be called from CodeCompanion chat buffers",
            vim.log.levels.ERROR
        )
        return
    end
    if #opts.fargs == 0 then
        vim.notify("CodeCompanionSave requires at least 1 arg to make a file name", vim.log.levels.ERROR)
    end
    local save_name = table.concat(opts.fargs, "-") .. ".md"
    local save_path = Path:new(save_folder, save_name)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    save_path:write(table.concat(lines, "\n"), "w")
end, { nargs = "*" })
------------------------------------------------------------------------

-- Merge environment-specific config into base config
local final_config = vim.tbl_deep_extend("force", base_config, env_config)

return final_config
