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

-- luasnip var and its "descendants" for config
local luasnip = require('luasnip')
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node

-- Custom Snippet Function
-- Define a function to get the current filename for the header guard
local function header_guard_filename()
    -- Get the current file's name, remove its extension, and replace slashes with underscores
    -- TODO  Think abouzt just doing this for actuall Header files. :r after :t would remove extension
    local filename = vim.fn.expand('%:t')                           -- %:t gives the file name,
    filename = filename:gsub("/", "_"):gsub("%.", "_"):upper()      -- Replace slashes and dots with underscores and make it uppercase
    return filename                                                 -- Return the formatted filename for header guard (single-line string)
    -- return filename .. "_HPP"        -- TODO In case decided to check file type concat here with ending
end

-- Custom snippets for C++
luasnip.add_snippets("cpp", {
    -- Header Guard Snippet (triggered by 'mhg')
    s("mhg", {
        t("#ifndef "),
        f(header_guard_filename, {}),
        t({"", "#define "}),                -- Newline is done by putting in Object and add empty string, otherwise failure
        f(header_guard_filename, {}),       
        i(0),                               -- Place insert currsor here
        t({"", "", "#endif // !"}),        
        f(header_guard_filename, {}),       
    }),
})
