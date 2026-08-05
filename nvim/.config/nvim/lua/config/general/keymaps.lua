-- keymaps.lua
-- All keymaps and Burrow menu registrations in one place

-- ─────────────────────────────────────────────
--  LSP
-- ─────────────────────────────────────────────
vim.keymap.set('i', '<C-Space>', vim.lsp.omnifunc,              { desc = "LSP Omnifunc" })
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover,             { desc = "LSP Hover info" })
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition,       { desc = "LSP Go to definition" })
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references,       { desc = "LSP Find references" })
vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>',      { desc = "LSP Definitions (Telescope)" })
vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>',       { desc = "LSP References (Telescope)" })
vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>',  { desc = "LSP Implementations (Telescope)" })
vim.keymap.set('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<cr>', { desc = "LSP Document symbols" })
vim.keymap.set('n', '<leader>ci', '<cmd>Telescope lsp_incoming_calls<CR>', { desc = "LSP Incoming calls" })
vim.keymap.set('n', '<leader>co', '<cmd>Telescope lsp_outgoing_calls<CR>', { desc = "LSP Outgoing calls" })
vim.keymap.set("n", "S", vim.lsp.buf.rename,                    { noremap = true, desc = "Smart rename (LSP)" })
vim.keymap.set('n', '<leader>w', function()
    vim.diagnostic.open_float({ scope = 'line' })
end, { desc = "Show line diagnostics" })

-- Codelens
vim.keymap.set("n", "<leader>cl", function() vim.lsp.codelens.run() end,     { desc = "Run Codelens" })
vim.keymap.set("n", "<leader>cL", function() vim.lsp.codelens.refresh() end, { desc = "Refresh Codelens" })

-- ─────────────────────────────────────────────
--  Telescope
-- ─────────────────────────────────────────────
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>',  { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>',   { desc = "Find text (live grep)" })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>',     { desc = "Find buffers" })
vim.keymap.set('n', '<leader>FF', function()
    require('telescope.builtin').find_files({ hidden = true })
end, { desc = "Find files (including hidden)" })
vim.keymap.set('n', '<leader>fh', function()
    require('telescope.builtin').find_files({ cwd = "~/", hidden = true })
end, { desc = "Find files from home" })
vim.keymap.set('n', '<leader>tm', function()
    require('telescope.builtin').builtin()
end, { desc = "Telescope built-in picker menu" })

-- ─────────────────────────────────────────────
--  File tree
-- ─────────────────────────────────────────────
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>',  { desc = "Toggle file tree" })
vim.keymap.set('n', '<M-F>', '<cmd>NvimTreeFindFile<CR>',    { desc = "Reveal file in tree" })

-- ─────────────────────────────────────────────
--  Git
-- ─────────────────────────────────────────────
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>',        { silent = true, desc = "Open LazyGit" })
vim.keymap.set('n', '<leader>g?', '<cmd>Gitsigns<CR>',       { silent = true, desc = "Gitsigns commands" })

-- ─────────────────────────────────────────────
--  Substitute (replace)
-- ─────────────────────────────────────────────
vim.keymap.set("n", "sw", require('substitute.range').word,     { noremap = true, desc = "Replace word (all instances)" })
vim.keymap.set("n", "s",  require('substitute.range').operator, { noremap = true, desc = "Replace in motion" })
vim.keymap.set("x", "s",  require('substitute.range').visual,   { noremap = true, desc = "Replace in visual" })
vim.keymap.set("n", "<leader>rs", function()
    require('substitute.range').operator({ confirm = true })
end, { noremap = true, desc = "Replace in motion (confirm)" })
vim.keymap.set("n", "<leader>rw", function()
    require('substitute.range').word({ confirm = true })
end, { noremap = true, desc = "Replace word (confirm)" })

-- ─────────────────────────────────────────────
--  Terminal
-- ─────────────────────────────────────────────
vim.keymap.set('t', '<leader><esc>', [[<C-\><C-n>]], { desc = "Detach terminal" })

-- ─────────────────────────────────────────────
--  Treesitter / Tree context / Treewalker
-- ─────────────────────────────────────────────
vim.keymap.set('n', '<leader>tc', '<cmd>TSContext<CR>',          { desc = "Toggle Treesitter context" })
-- Move
vim.keymap.set({ 'n', 'v' }, '<M-h>', '<cmd>Treewalker Left<cr>',  { silent = true })
vim.keymap.set({ 'n', 'v' }, '<M-j>', '<cmd>Treewalker Down<cr>',  { silent = true })
vim.keymap.set({ 'n', 'v' }, '<M-k>', '<cmd>Treewalker Up<cr>',    { silent = true })
vim.keymap.set({ 'n', 'v' }, '<M-l>', '<cmd>Treewalker Right<cr>', { silent = true })
-- Swap
vim.keymap.set('n', '<M-H>', '<cmd>Treewalker SwapLeft<cr>',  { silent = true })
vim.keymap.set('n', '<M-J>', '<cmd>Treewalker SwapDown<cr>',  { silent = true })
vim.keymap.set('n', '<M-K>', '<cmd>Treewalker SwapUp<cr>',    { silent = true })
vim.keymap.set('n', '<M-L>', '<cmd>Treewalker SwapRight<cr>', { silent = true })
-- Fold treesitter node
vim.keymap.set('n', 'zF', function()
    local node = vim.treesitter.get_node()
    if node then
        local start_row = node:start()
        local end_row = node:end_()
        vim.cmd(start_row + 1 .. ',' .. end_row + 1 .. 'fold')
    end
end, { desc = "Fold treesitter node" })

-- ─────────────────────────────────────────────
--  Tabs
-- ─────────────────────────────────────────────
vim.keymap.set("n", "<M-t>", function()
    local char = vim.fn.getchar()
    local num = tonumber(vim.fn.nr2char(char))
    if num and num >= 1 and num <= 9 then
        vim.cmd("tabnext " .. num)
    else
        print("Invalid tab number. Use 1-9.")
    end
end, { desc = "Go to tab by number (1-9)" })
vim.keymap.set("n", "<M-t>n", "<cmd>tabnew<cr>",   { desc = "New tab" })
vim.keymap.set("n", "<M-t>c", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "<M-t>o", "<cmd>tabonly<cr>",  { desc = "Close all other tabs" })

-- ─────────────────────────────────────────────
--  AI (CodeCompanion)
-- ─────────────────────────────────────────────
vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = "CodeCompanion actions" })
vim.keymap.set({ "n", "v" }, "<leader>a",  "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true, desc = "Toggle CodeCompanion chat" })
vim.keymap.set("v", "<leader>ga", ":'<,'>CodeCompanionChat Add<cr>", { noremap = true, silent = true, desc = "Add selection to CodeCompanion chat" })
vim.cmd([[cab cc CodeCompanion]])

-- ─────────────────────────────────────────────
--  Calltrace
-- ─────────────────────────────────────────────
vim.keymap.set('n', '<leader>sr', '<cmd>CalltraceSetReference<cr>', { desc = "Calltrace: set reference" })
vim.keymap.set('n', '<leader>tf', '<cmd>CalltraceTrace<cr>',        { desc = "Calltrace: trace" })

-- ─────────────────────────────────────────────
--  Markdown
-- ─────────────────────────────────────────────
vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { noremap = true, desc = "Toggle RenderMarkdown" })

-- ─────────────────────────────────────────────
--  Misc
-- ─────────────────────────────────────────────
vim.keymap.set('n', 'K', '<cmd>Man<CR>',                         { desc = "Open man page" })
vim.keymap.set('i', '<C-c>', '<Esc>',                            { desc = "Ctrl-C acts as Esc" })
vim.keymap.set('n', '<leader>qq', '<cmd>q!<CR>',                 { noremap = true, desc = "Force quit" })
vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>w<CR>',              { noremap = true, desc = "Save" })
vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>",             { desc = "Toggle outline" })

local function toggle_whitespace()
    if vim.o.list then
        vim.cmd("set nolist")
    else
        vim.cmd("set listchars=space:␣,tab:→·")
        vim.cmd("set list")
    end
end
vim.keymap.set({"n", "v"}, "<leader>ds", toggle_whitespace, { noremap = true, silent = true, desc = "Toggle display spaces" })

-- ─────────────────────────────────────────────
--  Debugging (DAP)
--  Note: <leader>d also opens the Hydra debug menu (see dap-config.lua)
-- ─────────────────────────────────────────────
local dap = require('dap')
local dapui = require('dapui')
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint,  { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue,           { desc = 'Continue / start debugging' })
vim.keymap.set('n', '<leader>di', dap.step_into,          { desc = 'Step into' })
vim.keymap.set('n', '<leader>do', dap.step_over,          { desc = 'Step over' })
vim.keymap.set('n', '<leader>du', dap.step_out,           { desc = 'Step out' })
vim.keymap.set('n', '<leader>dr', dap.repl.open,          { desc = 'Open REPL' })
vim.keymap.set('n', '<leader>dl', dap.run_last,           { desc = 'Run last' })
vim.keymap.set('n', '<leader>dt', dapui.toggle,           { desc = 'Toggle DAP UI' })

-- ─────────────────────────────────────────────
--  Burrow menus
-- ─────────────────────────────────────────────
local burrow = require('burrow')

burrow.register('<leader>gs', {
    name = 'Git',
    h = {
        name = 'Hunks',
        s = { '<cmd>Gitsigns stage_hunk<cr>',   'Stage hunk' },
        r = { '<cmd>Gitsigns reset_hunk<cr>',   'Reset hunk' },
        p = { '<cmd>Gitsigns preview_hunk<cr>', 'Preview hunk' },
        S = { '<cmd>Gitsigns stage_buffer<cr>', 'Stage buffer' },
        R = { '<cmd>Gitsigns reset_buffer<cr>', 'Reset buffer' },
    },
    b = {
        name = 'Blame',
        l = { '<cmd>Gitsigns blame_line<cr>',   'Blame line (full)' },
        s = { '<cmd>Gitsigns blame<cr>',        'Blame sidepanel' },
        t = { '<cmd>GitBlameToggle<cr>',        'Toggle inline blame' },
    },
    d = {
        name = 'Diff',
        d = { '<cmd>Gitsigns diffthis<cr>',         'Diff current file' },
        w = { '<cmd>Gitsigns toggle_word_diff<cr>', 'Toggle word diff' },
        x = { '<cmd>Gitsigns toggle_deleted<cr>',   'Toggle deleted lines' },
    },
    q = {
        name = 'Quickfix',
        b = { '<cmd>Gitsigns setqflist<cr>',                        'QF hunks (buffer)' },
        a = { '<cmd>lua require("gitsigns").setqflist("all")<cr>',  'QF hunks (all)' },
    },
})

burrow.register('<leader>l', {
    name = 'LSP',
    n = {
        name = 'Navigate',
        d = { '<cmd>Telescope lsp_definitions<cr>',      'Definition' },
        r = { '<cmd>Telescope lsp_references<cr>',       'References' },
        i = { '<cmd>Telescope lsp_implementations<cr>',  'Implementations' },
        t = { '<cmd>Telescope lsp_type_definitions<cr>', 'Type definition' },
    },
    c = {
        name = 'Calls',
        i = { '<cmd>Telescope lsp_incoming_calls<cr>',   'Incoming calls' },
        o = { '<cmd>Telescope lsp_outgoing_calls<cr>',   'Outgoing calls' },
    },
    a = {
        name = 'Actions',
        r = { '<cmd>lua vim.lsp.buf.rename()<cr>',                      'Rename symbol' },
        a = { '<cmd>lua require("actions-preview").code_actions()<cr>', 'Code actions' },
        l = { '<cmd>lua vim.lsp.codelens.run()<cr>',                    'Run codelens' },
        L = { '<cmd>lua vim.lsp.codelens.refresh()<cr>',                'Refresh codelens' },
    },
    s = {
        name = 'Symbols',
        d = { '<cmd>Telescope lsp_document_symbols<cr>',  'Document symbols' },
        w = { '<cmd>Telescope lsp_workspace_symbols<cr>', 'Workspace symbols' },
    },
})

-- CodeCompanion menu
burrow.register('<leader>A', {
    name = 'AI',
    l = { '<cmd>CodeCompanionLoad<cr>',    'Load saved chat' },
    n = { '<cmd>CodeCompanionChat<cr>',    'New chat' },
    p = { '<cmd>CodeCompanionPrompt<cr>',  'Reset system prompt' },
    a = { '<cmd>CodeCompanionActions<cr>', 'Actions menu' },
})

-- Todo Comments menu
burrow.register('<leader>T', {
    name = 'Todo',
    t = { '<cmd>TodoTelescope<cr>', 'Find todos (Telescope)' },
    q = { '<cmd>TodoQuickFix<cr>',  'Todos to quickfix' },
    l = { '<cmd>TodoLocList<cr>',   'Todos to loclist' },
})

-- DiffView menu
burrow.register('<leader>GG', {
    name = 'DiffView',
    o = { '<cmd>DiffviewOpen<cr>',                      'Open diff (working tree)' },
    c = { '<cmd>DiffviewClose<cr>',                     'Close diffview' },
    h = {
        name = 'History',
        f = { '<cmd>DiffviewFileHistory %<cr>',          'File history (current file)' },
        r = { '<cmd>DiffviewFileHistory<cr>',            'File history (whole repo)' },
    },
    r = {
        name = 'Review',
        m = { '<cmd>DiffviewOpen HEAD~1<cr>',            'Diff last commit' },
        s = { '<cmd>DiffviewOpen --staged<cr>',          'Diff staged changes' },
    },
})
