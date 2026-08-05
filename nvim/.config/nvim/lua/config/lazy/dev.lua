-- config/lazy/dev.lua
-- This file is merged into main plugin list at startup, wont fail if its not there so its safe to gitignore
-- Just taking an existing plugin from lazy, referencing it in here by "{ name="My/Plugin", dir="..." } should overwrite it

return {
    {
        dir = "/home/berni/Projects/calltrace.nvim",
        name = "calltrace.nvim",    -- needed when using dir= so lazy can identify the plugin
        config = function()
            require("calltrace").setup({
                display = {
                    backend = "telescope",
                },
                loop_detection = {
                    mode = "complete",
                },
            })
        end,
    },
}
