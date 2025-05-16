-- LSP Setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Common on_attach function
local on_attach = function(client, bufnr)
    -- TODO RETRANSFER
end

-- Set up mason
require("mason").setup({
    ui = {
        border = "rounded"
    }
})

require("mason-lspconfig").setup({
    -- list of servers to automatically install if they're not already installed
    ensure_installed = { "rust_analyzer", "lua_ls", "svelte", "marksman", "clangd" },
    automatic_enable = false,
    
})

local lspconfig = require('lspconfig')

-- Clangd setup
lspconfig.clangd.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { 
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders=false"
    }
})

-- Svelte setup
lspconfig.svelte.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "svelte", "css", "js", "ts" }
})

-- Pyright setup
lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach
})

-- Completion setup in cmp-config.lua
