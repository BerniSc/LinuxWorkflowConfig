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

-- require("mason-lspconfig").setup({
    -- list of servers to automatically install if they're not already installed
    -- ensure_installed = { "lua_ls", "svelte", "marksman", "clangd" }
-- })
local servers = { "lua-language-server", "svelte-language-server", "marksman", "clangd" }

-- Manually ensure servers are installed
-- for _, server in ipairs(servers) do
--     local cmd = string.format(":MasonInstall %s", server)
--     vim.cmd(cmd)
-- end

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

-- Completion setup
local cmp = require('cmp')
cmp.setup({
    snippet = {                     -- Add snippet configuration
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
        ['<Tab>'] = cmp.mapping.select_next_item(),        -- Tab to cycle forward
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),      -- Shift+Tab to cycle backward
        ['<C-n>'] = cmp.mapping.select_next_item(),        -- Ctrl+n alternative
        ['<C-p>'] = cmp.mapping.select_prev_item(),        -- Ctrl+p alternative
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'luasnip', priority = 750 },
        { name = 'buffer', priority = 500 },
    }),
    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            -- Prefer LuaSnip over LSP for snippets to avoid duplicates
            function(entry1, entry2)
                local source1 = entry1.source.name
                local source2 = entry2.source.name
                
                if entry1.completion_item.label == entry2.completion_item.label then
                    if source1 == 'luasnip' and source2 == 'nvim_lsp' then
                        return true
                    end
                    if source2 == 'luasnip' and source1 == 'nvim_lsp' then
                        return false
                    end
                end
                
                return nil
            end,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.menu = ({
                -- TODO Copilot here as well?
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
        end
    },
})

-- Load snippets
require('luasnip.loaders.from_vscode').lazy_load()
