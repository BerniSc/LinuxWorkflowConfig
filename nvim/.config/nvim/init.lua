-- Set leader key to space (We can call "Space" plus Regular Key for new Mapping meaning
vim.g.mapleader = " "

require('packer').startup(function()
    -- PLUGIN manager
    use 'wbthomason/packer.nvim'

    -- The Fuzzy Finder and its Dependency
    use 'nvim-lua/plenary.nvim'                 -- required by telescope, gitsigns etc
    use 'nvim-telescope/telescope-ui-select.nvim' -- required by telescope for CodeActions
    use 'nvim-telescope/telescope.nvim'  		-- fuzzy finder (Files) (Search like find and Grep) Usage :Telescope find_files

    -- LSP and Completion
    use 'nvim-treesitter/nvim-treesitter'  		-- better syntax highlighting (Syntax Highlighting, Better Code Understanding/Parsing etc)
    use 'neovim/nvim-lspconfig'  			    -- LSP support (Lang Server Protocoll; Code Completion, GoTo Definition, find References, Errorchecks)
    use 'williamboman/mason.nvim'               -- LSP package manager
    use 'williamboman/mason-lspconfig.nvim'     -- Mason LSP config bridge

    -- For TMux Integration (switch using <C-h> etc...)
    use 'christoomey/vim-tmux-navigator'     

    -- Nicer Fold
    use { 'anuvyklack/pretty-fold.nvim',
        config = function()
            require('pretty-fold').setup()
        end
    }

    -- Reaplace/Rename
    use {
        'gbprod/substitute.nvim',
        config = function()
            require("substitute").setup({
                highlight_substituted_text = {
                    enabled = true,
                    timer = 5,
                }
            })
        end
    }

    -- Code Actions
    use {
        'aznhe21/actions-preview.nvim',
        config = function()
            require("actions-preview").setup({
                backend = { "telescope" },
                -- new diagnostic API
                telescope = {
                    sorting_strategy = "ascending",
                    layout_strategy = "vertical",
                    layout_config = { height = 0.5, width = 0.8 }
                }
            })
            vim.keymap.set({ "n", "v" }, "<leader>ca", require("actions-preview").code_actions)
        end
    }

    use {
        "olimorris/codecompanion.nvim",
        config = function()
            local ai_config = require("config.ai-config")
            require("codecompanion").setup(ai_config)
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    }

    -- For Copilot integration into codecompanion
    use {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        -- event = "InsertEnter",  -- Would lazyload on first enter
        config = function()
            require("copilot").setup({
                -- Kill copilot autocomplete to pass its functions to copilot_cmp
                suggestion = { enabled = false },
                panel = { enabled = false },
            })
        end,
    }

    -- Add copilot-stuff as possible cpm suggestions
    use {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function ()
            require("copilot_cmp").setup()
        end
    }

    -- Completion Engine and Sources
    use 'hrsh7th/nvim-cmp'                      -- Completion Plugin
    use 'hrsh7th/cmp-nvim-lsp'                  -- LSP-Completion
    use 'hrsh7th/cmp-buffer'                    -- Buffer-Completion
    use 'hrsh7th/cmp-cmdline'                   -- Cmdline-Completions
    use 'L3MON4D3/LuaSnip'                      -- snippet engine
    use 'saadparwaiz1/cmp_luasnip'              -- snippet completions
    use 'rafamadriz/friendly-snippets'          -- template-sample-snippets for the different languages

    -- File-Tree and Icons
    use 'nvim-tree/nvim-web-devicons'
    use {
        'nvim-tree/nvim-tree.lua',              -- File Explorer VSC Style
        requires = 'nvim-tree/nvim-web-devicons'
    }

    -- Git Integration
    use 'lewis6991/gitsigns.nvim'               -- git changes in gutter
    use 'sindrets/diffview.nvim'                -- git Diff Viewer
    use 'kdheepak/lazygit.nvim'                 -- git UI <space>gg

    -- Theme
    use 'navarasu/onedark.nvim'

    -- Highlighting of ToDo notes etc
    use {
        'folke/todo-comments.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup{
                highlight = {
                    pattern = [[.*<(KEYWORDS)\s*]],
                    multiline = true,
                },
                search = {
                    pattern = [[\b(KEYWORDS)]],
                }
            }
        end
    }

    -- Banner to display f.E. current Gitbranch
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons' }
    }

    -- UI Improvements - like interaktive Filter in Mason-Config and f.e. rename-menu for vars etc.
    use {'stevearc/dressing.nvim'}
end)

require('onedark').setup()
vim.cmd[[colorscheme onedark]]

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
require('lualine').setup {
    options = {
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
        -- Disable for NvimTree and other file types that dont require it
        disabled_filetypes = {
            'NvimTree',
            'packer',
            'help'
        },
        -- We could set this if we just want one Status, for now leave it of and see how much it bothers
        globalstatus = false,
        -- Only display if it fits...
        cond = function()
            return vim.o.columns > 50
        end
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {
            {'branch'},
            {'diff'},
        },
        lualine_c = {{'filename', path = 1}},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    }
}


-- LSP Setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Common on_attach function
local on_attach = function(client, bufnr)
    -- LSP keymaps
    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    
    -- Force TreeSitter to re-highlight after changes, otherwise the highlighting breaks on fixes like automimport
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function()
            vim.cmd("TSBufEnable highlight")
        end,
    })

    -- Notify on attach
    vim.notify("LSP started for " .. vim.api.nvim_buf_get_name(bufnr))
end

-- Install the LSP's
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { 
        "svelte", 
        "marksman", 
        "clangd",
    },
    automatic_installation = true,
})

require("mason-lspconfig").setup_handlers({
    -- Default handler
    function(server_name)
        require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            root_dir = function(fname)
                return require('lspconfig.util').root_pattern(
                    -- Common root Pattern
                    '.git',
                    'package.json',
                    'Makefile',
                    'CMakeLists.txt'
                )(fname) or vim.fn.getcwd()
            end
        })
    end,
    
    -- Special configs for specific LSPs 
    ["clangd"] = function()
        require("lspconfig").clangd.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            root_dir = function(fname)
                return require('lspconfig.util').root_pattern(
                    'compile_commands.json',
                    'compile_flags.txt',
                    '.clangd',
                    'CMakeLists.txt',
                    'Makefile',
                    '.git'
                )(fname) or vim.fn.getcwd()
            end,
            cmd = { 
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders=false"     -- Do not put stuff in the brackets of autocompleted functions
            }
        })
    end,

    ["svelte"] = function()
        require("lspconfig").svelte.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = { "svelte", "css", "js", "ts" },
            root_dir = require('lspconfig.util').root_pattern('package.json', 'svelte.config.js', '.git')
        })
    end,

    ["pyright"] = function()
        require("lspconfig").pyright.setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
    end
})

local cmp = require('cmp')
cmp.setup({
    -- window = {
    --     documentation = {
    --         border = "rounded",
    --         winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
    --     },
    --     completion = {
    --         border = "rounded",
    --         winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
    --     },
    -- },
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
    -- sources = cmp.config.sources({
    --     { name = 'nvim_lsp' },
    --     { name = 'luasnip' },
    --     { name = 'buffer' },
    -- }),
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
            -- Prefer LuaSnip over LSP for snippets to avoid duplicates
            function(entry1, entry2)
                local source1 = entry1.source.name
                local source2 = entry2.source.name
                
                -- If both entries have the same label and one is from luasnip and one from LSP
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
                copilot = "[Copilot]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
        end
    },
})
require('luasnip.loaders.from_vscode').lazy_load()

require'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "vim", "cpp", "svelte", "html", "css", "javascript", "markdown", "yaml", "python" },
    highlight = {
        enable = true,
        force_enable = true,
    },
}

require('telescope').setup{
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown()
        }
    },
    defaults = {
        mappings = {
            i = {
                -- absolute
                ["<C-y>"] = function(prompt_bufn)
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
local function create_makefile_template()
    -- Get selected node from NvimTree
    local node = require('nvim-tree.api').tree.get_node_under_cursor()
    if not node then return end
    
    -- Get the directory path (if file is selected, use its parent)
    local path = node.type == 'directory' and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ':h')
    
    -- Find all cpp files recursively
    local cpp_files = vim.fn.glob(path .. "/**/*.cpp", false, true)
    local sources = {}
    for i, file in ipairs(cpp_files) do
        sources[i] = file:gsub(path .. "/", "")
    end
    
    local makefile = [[
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17
INCLUDES = -I./include
TARGET = main

# Source files
SRCS = ]] .. table.concat(sources, " \\\n\t") .. [[

# Object files
OBJS = $(SRCS:.cpp=.o)

# Main target
$(TARGET): $(OBJS)
    $(CXX) $(OBJS) -o $(TARGET)

# Compile source files
%.o: %.cpp
    $(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

run:
    ./$(TARGET)

# Create include directory if it doesn't exist
create_dirs:
    @mkdir -p include

# Clean build files
clean:
    rm -f $(OBJS) $(TARGET)

.PHONY: clean create_dirs run
]]

    -- Create include directory
    vim.fn.mkdir("include", "p")
    
    -- Replace leading spaces with tabs
    makefile = makefile:gsub("\n    ", "\n\t")

    -- Write Makefile
    local file = io.open(path .. "/Makefile", "w")
    file:write(makefile)
    file:close()
end

-- Add to NvimTree keymaps
vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
        vim.keymap.set('n', '<leader>gm', create_makefile_template, {buffer=true, desc="Create Makefile"})
    end
})
----------------------
-- END OF Makefile-Generator
----------------------

-----------------------
--  Remaps
-----------------------

-- LSP mappings that don't override defaults
vim.keymap.set('i', '<C-Space>', vim.lsp.omnifunc)		        -- Our Autocomplete
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover)      	    -- hover info (Use "Space" as K opens manpage)
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition) 	    -- go to definition
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references) 	    -- find references

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')  -- find files
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')   -- find text (live grep)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')     -- find buffers

-- Tree-Setup and Shortcut
require('nvim-tree').setup()
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')  -- <space>e to toggle

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
        cwd = "~/",  	-- search from home directory
        hidden=true	    -- show hidden File as well
    })
end)

-- Open Manpage
vim.keymap.set('n', 'K', function()
    vim.cmd('Man')
end)

-- Better keymaps for LSP navigation
vim.keymap.set('n', 'gd', ':Telescope lsp_definitions<CR>')
vim.keymap.set('n', 'gr', ':Telescope lsp_references<CR>')
vim.keymap.set('n', 'gi', ':Telescope lsp_implementations<CR>')
vim.keymap.set('n', '<leader>s', ':Telescope lsp_document_symbols<CR>')

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
vim.keymap.set('n', '<leader>qq', ':q!<CR>', { noremap = true })
-- Quick save
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true })

-- AI
vim.keymap.set({ "n", "v" }, "<leader><C-a>",
    "<cmd>CodeCompanionActions<cr>", { 
        noremap = true, silent = true, desc = "Open CodeCompanion Actions" 
})
vim.keymap.set({ "n", "v" }, "<leader>a",
    "<cmd>CodeCompanionChat Toggle<cr>", {
        noremap = true, silent = true, desc = "Toggle CodeCompanion Chat"
})
vim.keymap.set("v", "<leader>ga",
    "<cmd>CodeCompanionChat Add<cr>", {
        noremap = true, silent = true, desc = "Add visual selection to CodeCompanion Chat"
})

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

