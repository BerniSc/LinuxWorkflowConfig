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

-- Merge environment-specific config into base config
local final_config = vim.tbl_deep_extend("force", base_config, env_config)

return final_config
