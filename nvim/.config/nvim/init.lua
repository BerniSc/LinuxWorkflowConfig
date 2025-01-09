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

    -- Completion Engine and Sources
    use 'hrsh7th/nvim-cmp'                      -- Completion Plugin
    use 'hrsh7th/cmp-nvim-lsp'                  -- LSP-Completion
    use 'hrsh7th/cmp-buffer'                    -- Buffer-Completion

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

    -- UI Improvements - like interaktive Filter in Mason-Config and f.e. rename-menu for vars etc.
    use {'stevearc/dressing.nvim'}
end)

require('onedark').setup()
vim.cmd[[colorscheme onedark]]

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
end

-- Install the LSP's
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { 
        "svelte", 
        "marksman", 
        "clangd",
    },
    automatic_installation = true
})

local cmp = require('cmp')
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
        ['<Tab>'] = cmp.mapping.select_next_item(),        -- Tab to cycle forward
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),      -- Shift+Tab to cycle backward
        ['<C-n>'] = cmp.mapping.select_next_item(),        -- Ctrl+n alternative
        ['<C-p>'] = cmp.mapping.select_prev_item(),        -- Ctrl+p alternative
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    })
})

require'lspconfig'.clangd.setup{
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),  -- for Code Actions
    on_attach = function(client, bufnr)
        -- Call common setup
        on_attach(client, bufnr)
        -- Clangd specific setup
        vim.notify("Clangd LSP started for " .. vim.api.nvim_buf_get_name(bufnr))
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    end,
    flags = {
        debounce_text_changes = 150,
    }
}

require'lspconfig'.svelte.setup{
    filetypes = { "svelte", "css", "js", "ts" },
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client, bufnr)
        -- Call common setup
        on_attach(client, bufnr)
        vim.notify("Svelte LSP started for " .. vim.api.nvim_buf_get_name(bufnr))
    end
}

require'lspconfig'.marksman.setup{
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = on_attach,
}
--
--

require'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "cpp", "svelte", "html", "css", "javascript", "markdown", "yaml" },
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

on_attach = function(client, bufnr)
    -- Force TreeSitter to re-highlight after changes, otherwise the highlighting breaks on fixes like automimport
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function()
            vim.cmd("TSBufEnable highlight")
        end,
    })
end

-----------------------
--  Remaps
-----------------------

-- LSP mappings that don't override defaults
vim.keymap.set('i', '<C-Space>', vim.lsp.omnifunc)		        -- Our Autocomplete
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover)      	    -- hover info (Use "Space" as K opens manpage)
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition) 	    -- go to definition
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references) 	    -- find references

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')  -- find files
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')   -- find text
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
