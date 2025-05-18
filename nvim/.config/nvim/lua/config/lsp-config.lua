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
-- see https://github.com/espressif/esp-idf/issues/6721#issuecomment-2231830343
-- Gist is: As soon as we export get_idf for our nvim shell instance we go into special esp compiler mode
local esp_idf_path = os.getenv("IDF_PATH")
if esp_idf_path then
  -- for esp-idf
    lspconfig.clangd.setup({
        handlers = handlers,
        capabilities = capabilities;
        cmd = { "/home/berni/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd", "--background-index", "--query-driver=**", },
        root_dir = function()
            -- leave empty to stop nvim from cd'ing into ~/ due to global .clangd file
        end
    })
else
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
end

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
