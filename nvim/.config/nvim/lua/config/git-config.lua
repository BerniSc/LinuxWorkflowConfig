local M = {}

function M.gitsigns_picker()
    local has_telescope, pickers = pcall(require, "telescope.pickers")
    local has_finders, finders = pcall(require, "telescope.finders")
    local has_conf, conf = pcall(require, "telescope.config")
    local has_actions, actions = pcall(require, "telescope.actions")
    local has_action_state, action_state = pcall(require, "telescope.actions.state")

    if not (has_telescope and has_finders and has_conf and has_actions and has_action_state) then
        vim.notify("Telescope is not available", vim.log.levels.ERROR)
        return
    end

    local gitsigns = require("gitsigns")

    local items = {
        {
            name = "QF Hunks Current buffer",
            desc = "Send hunks in current Buffer to QF List",

            action = function()
                gitsigns.setqflist(0)
            end,
        },
        {
            name = "QF Hunks All",
            desc = "Send all hunks to QF List",

            action = function()
                gitsigns.setqflist('all')
            end,
        },
        {
            name = "Blame Line",
            desc = "Show blame for current line",
            action = function()
                gitsigns.blame_line({ full = true })
            end,
        },
        {
            name = "Blame Sidepanel",
            desc = "Toggle sidepanel blame",
            action = function()
                gitsigns.blame()
            end,
        },
        {
            name = "Blame currentline",
            desc = "Toggle inline blame",
            action = function()
                gitsigns.toggle_current_line_blame(nil)
            end,
        },
        {
            name = "Hunk Stage",
            desc = "Stage current hunk",
            action = function()
                gitsigns.stage_hunk()
            end,
        },
        {
            name = "Hunk Reset",
            desc = "Reset current hunk",
            action = function()
                gitsigns.reset_hunk()
            end,
        },
        {
            name = "Hunk Preview",
            desc = "Preview current hunk diff",
            action = function()
                gitsigns.preview_hunk()
            end,
        },
        {
            name = "Diff current file",
            desc = "Diff current file",
            action = function()
                gitsigns.diffthis()
            end,
        },
        {
            name = "Buffer Stage",
            desc = "Stage all hunks in current buffer",
            action = function()
                gitsigns.stage_buffer()
            end,
        },
        {
            name = "Buffer Reset",
            desc = "Reset all hunks in current buffer",
            action = function()
                gitsigns.reset_buffer()
            end,
        },
        {
            name = "Toggle Word diff",
            desc = "Toggle diff of words and letters",
            action = function()
                gitsigns.toggle_word_diff()
            end,
        },
        {
            name = "Toggle deleted lines",
            desc = "Toggle deleted lines",
            action = function()
                gitsigns.toggle_deleted()
            end,
        },
    }

    pickers.new({}, {
        prompt_title = "Gitsigns Actions",
        finder = finders.new_table({
            results = items,
            entry_maker = function(item)
                return {
                    value = item,
                    display = string.format("%-28s %s", item.name, item.desc),
                    ordinal = item.name .. " " .. item.desc,
                }
            end,
        }),
        sorter = conf.values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            local run_selected = function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection and selection.value and selection.value.action then
                    selection.value.action()
                end
            end

            map("i", "<CR>", run_selected)
            map("n", "<CR>", run_selected)
            return true
        end,
    }):find()
end

return M
