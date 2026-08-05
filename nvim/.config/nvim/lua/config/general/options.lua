-- options.lua
-- All vim.opt settings in one place

vim.opt.number = true               -- line numbers
vim.opt.relativenumber = false      -- relative line numbers
vim.opt.tabstop = 4                 -- tab width
vim.opt.shiftwidth = 4              -- indent width
vim.opt.expandtab = true            -- spaces instead of tabs
vim.opt.smartindent = true          -- smart indenting
vim.opt.clipboard = "unnamedplus"   -- use system clipboard
vim.opt.signcolumn = "yes"          -- allow addons to set signs (breakpoints etc.)

-- Folds
vim.opt.foldenable = true
vim.opt.foldlevel = 99              -- high foldlevel to keep folds open by default

-- Diagnostics display
vim.diagnostic.config({
    float = {
        max_width = 80,
        max_height = 20,
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
