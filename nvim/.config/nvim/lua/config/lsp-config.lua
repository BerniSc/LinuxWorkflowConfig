-- LSP Setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Can just add new servers below, if they are not isntalled but a config is there it is handled gracefully and ignored

-- Common on_attach function
local on_attach = function(client, bufnr)
    -- TODO RETRANSFER
    -- Enable codelens if supported
    if client.supports_method("textDocument/codeLens") then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
        })
    end
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

-- Helper function to enable LSP servers directly after opening file
local function enable_lsp_server(name, config)
    vim.lsp.config[name] = config
    vim.lsp.enable(name)
end

-- Clangd setup
-- see https://github.com/espressif/esp-idf/issues/6721#issuecomment-2231830343
-- GIST: As soon as we export get_idf for our nvim shell instance we go into special esp compiler mode
local esp_idf_path = os.getenv("IDF_PATH")

if esp_idf_path then
    enable_lsp_server("clangd", {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = { "/home/berni/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd", "--background-index", "--query-driver=**" },
        filetypes = { 'c', 'cpp' },
    })
else
    enable_lsp_server("clangd", {
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
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
enable_lsp_server("svelte", {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "svelte", "css", "js", "ts" },
    -- filetypes = { "svelte" }, -- No css, js, ts -> should use dedicated servers?
})

-- Kotlin Setup
enable_lsp_server("kotlin_language_server", {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "kotlin" },
})

-- Pyright setup
enable_lsp_server("pyright", {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "python" },
})

-- TSServer setup (for JavaScript and TypeScript)
enable_lsp_server("ts_ls", {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    cmd = { "typescript-language-server", "--stdio" }
})

-- Marksman setup (Markdown LSP)
enable_lsp_server("marksman", {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "markdown" },
})

enable_lsp_server("lua_ls", {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "lua" },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            -- Don't warn about 'vim' being undefined
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                -- Load Neovim's Lua API definitions and dont ask about configuring other libs
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

-- Completion setup in cmp-config.lua
