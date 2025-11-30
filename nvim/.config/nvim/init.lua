-- Set leader-key to space (We can call "Space" plus Regular Key for new Mapping meaning)
vim.g.mapleader = " "

-- vim.opt.runtimepath:append("/home/berni/Projects/calltrace.nvim")

local plugins = require("config.lazy.lazy")
require("lazy").setup(plugins)

-- Vim Tips
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

-- Wrap the Diagnosit Messages like Errormessages and warning so they Fit
-- Configure diagnostic display
vim.diagnostic.config({
    float = {
        max_width = 80,         -- Maximum width of floating window
        max_height = 20,        -- Maximum height of floating window
        border = "rounded",
    },
    virtual_text = {
        prefix = '●',
        source = "if_many",
        spacing = 4,
        severity_sort = true,
    },
    severity_sort = true,
    signs = true,
    underline = true,
    update_in_insert = false,
})
-- Nicer UI for diagnostics float on <LEADER>w
vim.keymap.set('n', '<leader>w', function()
    vim.diagnostic.open_float({ scope = 'line' })
end)

-- Setup the Banner to display relevant Stuff under the Editor
require('config/banner-config')

-- LSP Setup
require('config/lsp-config')

-- Completion Setup
require('config/cmp-config')

-- TODO Check
require('nvim-treesitter.configs').setup {
    ensure_installed = { "c", "lua", "vim", "cpp", "svelte", "html", "css", "javascript", "markdown", "yaml", "python" },
    highlight = {
        enable = true,
        force_enable = true,
    },
}

require('telescope').setup {
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown()
        }
    },
    defaults = {
        mappings = {
            i = {
                -- absolute
                ["<C-y>"] = function(prompt_bufnr)
                    local selection = require('telescope.actions.state').get_selected_entry()
                    vim.fn.setreg('+', selection.value)
                    require('telescope.actions').close(prompt_bufnr)
                end,
                -- relative
                ["<C-r>"] = function(prompt_bufnr)
                    local entry = require('telescope.actions.state').get_selected_entry()
                    vim.fn.setreg('+', entry.path:gsub(vim.loop.cwd() .. '/', ''))
                end,
            }
        }
    }
}
require('telescope').load_extension('ui-select')

require('nvim-web-devicons').setup()
require('nvim-tree').setup()

----------------------
-- function for autogenerating a Makefile from the current dir in nvim-tree
----------------------
local makefile_template = require('MakefileGen')

-- Add to NvimTree keymaps
vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
        vim.keymap.set('n', '<leader>gm', makefile_template.create_makefile_template, {buffer=true, desc="Create Makefile"})
        vim.keymap.set('n', '<leader>gc', function()
            vim.fn.system('compiledb make')
            print("compile_commands.json generated with compiledb make")
        end, {buffer=true, desc="Run compiledb make"})
    end
})

-----------------------
--  Remaps
-----------------------

-- LSP mappings that don't override defaults
vim.keymap.set('i', '<C-Space>', vim.lsp.omnifunc)              -- Our Autocomplete
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover)             -- hover info (Use "Space" as K opens manpage)
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)       -- go to definition
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references)       -- find references

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')  -- find files
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')   -- find text (live grep)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')     -- find buffers

-- Tree-Setup and Shortcut
require('nvim-tree').setup()
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')  -- <space>e to toggle
-- Toggle Tree-Context Display
vim.keymap.set('n', '<leader>tc', ':TSContext<CR>', { desc = "Toggle Treesitter Context" })

-- Git Integration
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { silent = true })

-- Auto-import via code action - 
-- vim.keymap.set('n', '<leader>ca', function()
--     vim.lsp.buf.code_action()
    -- Small delay to let the action complete
    -- vim.defer_fn(function()
    --     vim.cmd("TSBufEnable highlight")
    --     vim.cmd("e")
    -- end, 100)
-- end, { desc = 'Code actions with highlight refresh' })

-- Remap C-c to Esc to use multiline insert in VMode
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Find from Home - f.e. Edit Config for NVIM
vim.keymap.set('n', '<leader>fh', function()
    require('telescope.builtin').find_files({
        cwd = "~/",     -- search from home directory
        hidden=true     -- show hidden File as well
    })
end)

-- Telescope full options select 
vim.keymap.set('n', '<leader>tm', function()
    require('telescope.builtin').builtin()
end, { desc = "Telescope built-in picker menu" })

-- Open Manpage
vim.keymap.set('n', 'K', function()
    vim.cmd('Man')
end)

-- calltrace
vim.keymap.set('n', '<leader>sr', '<cmd>CalltraceSetReference<cr>')
vim.keymap.set('n', '<leader>tf', '<cmd>CalltraceTrace<cr>')

-- Better keymaps for LSP navigation
vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>')
vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>')
vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>')
vim.keymap.set('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<cr>')

-- LSP smart rename
vim.keymap.set("n", "S", vim.lsp.buf.rename, { noremap = true, desc = "Smart rename (LSP)" })

-- Fast replace without confirm
vim.keymap.set("n", "sw", require('substitute.range').word, {
    noremap = true, desc = "Replace word (all instances)"
})
vim.keymap.set("n", "s", require('substitute.range').operator, {
    noremap = true, desc = "Replace in motion"
})
vim.keymap.set("x", "s", require('substitute.range').visual, {
    noremap = true, desc = "Replace in visual"
})

-- With confirmation (using leader)
vim.keymap.set("n", "<leader>s", function()
    require('substitute.range').operator({ confirm = true })
end, {
    noremap = true, desc = "Replace in motion (confirm)"
})
vim.keymap.set("n", "<leader>ss", function()
    require('substitute.range').word({ confirm = true })
end, {
    noremap = true, desc = "Replace word (confirm)"
})

-- Quick exit without save
vim.keymap.set('n', '<leader>qq', '<cmd>q!<CR>', { noremap = true })
-- Quick save
vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>w<CR>', { noremap = true })

-- display spaces
vim.keymap.set("v", "<leader>ds", "<cmd>set listchars+=space:␣,tab:→· | set list<CR>", { noremap = true, silent = true, desc = "Display Spaces" })
vim.keymap.set("n", "<leader>ds", "<cmd>set listchars+=space:␣,tab:→· | set list<CR>", { noremap = true, silent = true, desc = "Display Spaces" })

-- AI
vim.keymap.set({ "n", "v" }, "<leader>cc",
    "<cmd>CodeCompanionActions<cr>", {
        noremap = true, silent = true, desc = "Open CodeCompanion Actions"
})
vim.keymap.set({ "n", "v" }, "<leader>a",
    "<cmd>CodeCompanionChat Toggle<cr>", {
        noremap = true, silent = true, desc = "Toggle CodeCompanion Chat"
})
vim.keymap.set("v", "<leader>ga",
    ":'<,'>CodeCompanionChat Add<cr>", {
        noremap = true, silent = true, desc = "Add visual selection to CodeCompanion Chat"
})

-- Tabs
-- Quick tab navigation with Alt+t followed by number
-- replicates <number>gt
vim.keymap.set("n", "<M-t>", function()
    -- Get the next character typed
    local char = vim.fn.getchar()
    local num = tonumber(vim.fn.nr2char(char))

    if num and num >= 1 and num <= 9 then
        -- Go to tab number
        vim.cmd("tabnext " .. num)
    else
        -- If not a valid number, show message
        print("Invalid tab number. Use 1-9.")
    end
end, { desc = "Go to tab by number (1-9)" })

-- Additional tab bindings - Important regular one is <C-w>T to move window in Tab
vim.keymap.set("n", "<M-t>n", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set("n", "<M-t>c", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "<M-t>o", "<cmd>tabonly<cr>", { desc = "Close all other tabs" })

-- Toggle Render-Markdown
vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", {
    noremap = true, desc = "Toggle RenderMarkdown display"
})

-- Movement - Treewalker
-- Move
vim.keymap.set({ 'n', 'v' }, '<M-k>', '<cmd>Treewalker Up<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<M-j>', '<cmd>Treewalker Down<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<M-h>', '<cmd>Treewalker Left<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<M-l>', '<cmd>Treewalker Right<cr>', { silent = true })
-- Swap
vim.keymap.set('n', '<M-K>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
vim.keymap.set('n', '<M-J>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
vim.keymap.set('n', '<M-H>', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
vim.keymap.set('n', '<M-L>', '<cmd>Treewalker SwapRight<cr>', { silent = true })

-- Codelense
vim.keymap.set("n", "<leader>cl", function() vim.lsp.codelens.run() end, { desc = "Run Codelens" })
vim.keymap.set("n", "<leader>cL", function() vim.lsp.codelens.refresh() end, { desc = "Refresh Codelens" })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- vim.keymap.set('n', 'K', function()
--     if vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c' then
--         vim.lsp.buf.hover()
--     else
--         vim.cmd('Man')
--     end
-- end)

-----------------------
--  Options
-----------------------
-- vim settings
vim.opt.number = true               -- line numbers
vim.opt.relativenumber = true       -- relative line numbers
vim.opt.tabstop = 4                 -- tab width
vim.opt.shiftwidth = 4              -- indent width
vim.opt.expandtab = true            -- spaces instead of tabs
vim.opt.smartindent = true          -- smart indenting
vim.opt.clipboard = "unnamedplus"   -- use system clipboard
vim.opt.signcolumn = "yes"          -- Allow addons etc to set "signs" -> Breakpoint in debugger etc

-- Folds
vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false                          -- Disable folding at startup
vim.opt.foldlevel = 99                              -- High foldlevel to keep folds open by default

