-- cmp-config.lua
-- Central setup of cmp plugins. Also includes some AI Features like Copilot

local cmp = require('cmp')

cmp.setup({
    window = {
        documentation = {
            border = "rounded",
            winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
        },
        completion = {
            border = "rounded",
            winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
        },
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Enter to confirm
        ['<Tab>'] = cmp.mapping.select_next_item(),         -- Tab to cycle forward
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),       -- Shift-Tab to cycle backward
        ['<C-n>'] = cmp.mapping.select_next_item(),         -- Ctrl-n to mirror tab
        ['<C-p>'] = cmp.mapping.select_prev_item(),         -- Ctrl-p to mirror S-Tab
    }),
    sources = cmp.config.sources({
        { name = 'copilot', priority = 1100 },
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'luasnip', priority = 750 },
        { name = 'buffer', priority = 500 },
    }),
    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            function(entry1, entry2)
                local source1 = entry1.source.name
                local source2 = entry2.source.name

                -- If both entries have the same label and one is from luasnip and one from LSP
                -- use the one provided by luasnip
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
                copilot = "[Copilot]",      -- Okay to add here. No matter that its optional, luasnip checks wheter it is loaded first
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
        end,
    },
})

-- Load VSCode-style snippets
require('luasnip.loaders.from_vscode').lazy_load()
