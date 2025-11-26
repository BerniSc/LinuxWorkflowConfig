
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    -- Theme, should be available on start
    {
        'navarasu/onedark.nvim',
        tag = "v0.1.0",  -- TODO Update once fix is in
        lazy = false,    -- Ensure loading at start
        priority = 1000, -- Ensure loading first
        config = function()
            require('onedark').setup()
            vim.cmd.colorscheme("onedark")
        end,
    },


    -- The Fuzzy Finder and its Dependency
    'nvim-lua/plenary.nvim',                  -- required by telescope, gitsigns etc
    'nvim-telescope/telescope-ui-select.nvim',-- required by telescope for CodeActions
    'nvim-telescope/telescope.nvim',          -- fuzzy finder (Files) (Search like find and Grep) Usage :Telescope find_files

    -- Message Management (Toasts)
    'rcarriga/nvim-notify',

    -- LSP and Completion
    {
        -- better syntax highlighting (Syntax Highlighting, Better Code Understanding/Parsing etc)
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ":TSUpdate"
    },

    {
        'nvim-treesitter/nvim-treesitter-context',  -- display current function/context on top of screen
        config = function()
            require'treesitter-context'.setup{}
        end
    },

    {
        'mason-org/mason.nvim',                 -- LSP package manager
        dependencies = {
            'mason-org/mason-lspconfig.nvim',   -- Mason LSP config bridge
            'neovim/nvim-lspconfig'             -- LSP support (Lang Server Protocoll; Code Completion, GoTo Definition, find References, Errorchecks)
        }
    },

    -- For development
    -- vim.opt.runtimepath:append("/home/berni/Projects/calltrace.nvim"),

    -- {
    --     'BerniSc/calltrace.nvim',
    --     config=function()
            -- require("calltrace").setup({
            --     display = {
            --         backend = "telescope",
            --     },
            --     loop_detection = {
                    -- "per_branch" | "global"
                    --      global: faster, better if memory is a constraint, prevents revisiting same function->function transition globally
                    --      per_branch: slower, memory-intensive for deep calls, allows same function in different paths, only prevents loops within single branch
            --         mode = "complete",
            --     },
            -- }),
    --     end
    -- },

    -- For TMux Integration (switch using <C-h> etc...)
    'christoomey/vim-tmux-navigator',

    -- Nicer Fold
    -- { 'anuvyklack/pretty-fold.nvim',
    -- Use this fork as other one is stale and has an issue
    {
        'bbjornstad/pretty-fold.nvim',
        config = function()
            require('pretty-fold').setup()
        end
    },

    -- Nice Markdown Display/Preview^^
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('render-markdown').setup({
                file_types = { 'markdown', 'codecompanion' },
                html = {
                    enabled = true,
                    tag = {
                        buf         = { icon = ' ',  highlight = 'CodeCompanionChatVariable' },
                        file        = { icon = ' ',  highlight = 'CodeCompanionChatVariable' },
                        help        = { icon = '󰘥 ',  highlight = 'CodeCompanionChatVariable' },
                        image       = { icon = ' ',  highlight = 'CodeCompanionChatVariable' },
                        symbols     = { icon = ' ',  highlight = 'CodeCompanionChatVariable' },
                        url         = { icon = '󰖟 ',  highlight = 'CodeCompanionChatVariable' },
                        var         = { icon = ' ',  highlight = 'CodeCompanionChatVariable' },
                        tool        = { icon = ' ',  highlight = 'CodeCompanionChatTool' },
                        user_prompt = { icon = ' ',  highlight = 'CodeCompanionChatTool' },
                        group       = { icon = ' ',  highlight = 'CodeCompanionChatToolGroup' },
                    },
                },
            })
        end,
    },

    -- Reaplace/Rename
    {
        'gbprod/substitute.nvim',
        config = function()
            require("substitute").setup({
                highlight_substituted_text = {
                    enabled = true,
                    timer = 5,
                }
            })
        end
    },

    -- Movement
    {
        'aaronik/treewalker.nvim',
        config = function()
            require('treewalker').setup({
                highlight_duration=400
            })
        end
    },

    -- Marks
    {
        'chentoast/marks.nvim',
        config = function()
            require('marks').setup()
            require('config.marks-config')
        end
    },

    -- Code Actions
    {
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
    },

    { "ravitemer/codecompanion-history.nvim" },
    { "franco-ruggeri/codecompanion-spinner.nvim" },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "ravitemer/codecompanion-history.nvim",
        },
        config = function()
            local ai_config = require("config.ai-config")
            require("codecompanion").setup(ai_config)
        end,
    },

    -- For Copilot integration into codecompanion
    {
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
    },

    -- Add copilot-stuff as possible cpm suggestions
    {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end
    },

    -- Completion Engine and Sources
    'hrsh7th/nvim-cmp',                     -- Completion Plugin
    'hrsh7th/cmp-nvim-lsp',                 -- LSP-Completion
    'hrsh7th/cmp-buffer',                   -- Buffer-Completion
    'hrsh7th/cmp-cmdline',                  -- Cmdline-Completions
    'L3MON4D3/LuaSnip',                     -- snippet engine
    'saadparwaiz1/cmp_luasnip',             -- snippet completions
    'rafamadriz/friendly-snippets',         -- template-sample-snippets for the different languages

    -- File-Tree and Icons
    'nvim-tree/nvim-web-devicons',
    {
        'nvim-tree/nvim-tree.lua',              -- File Explorer VSC Style
        dependencies = 'nvim-tree/nvim-web-devicons'
    },

    -- Git Integration
    'lewis6991/gitsigns.nvim',              -- git changes in gutter
    'sindrets/diffview.nvim',               -- git Diff Viewer
    'kdheepak/lazygit.nvim',                -- git UI <space>gg
    {                                       -- togglable git Blame view, start via :GitBlameToggle
        'f-person/git-blame.nvim',
        config = function()
            require('gitblame').setup {
                enabled = false,
                date_format = "%d.%m.%y %H:%M",
            }
        end
    },

    -- Highlighting of ToDo notes etc
    {
        'folke/todo-comments.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup {
                highlight = {
                    pattern = [[.*<(KEYWORDS)\s*]],
                    multiline = true,
                },
                search = {
                    pattern = [[\b(KEYWORDS)]],
                }
            }
        end
    },

    -- Banner to display f.E. current Gitbranch
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },


    -- UI Improvements - like interaktive Filter in Mason-Config and f.e. rename-menu for vars etc.
    { 'stevearc/dressing.nvim' }
}

return plugins
