-- Set leader-key to space (We can call "Space" plus Regular Key for new Mapping meaning)
vim.g.mapleader = " "

local plugins = require("config.lazy.lazy")
require("lazy").setup(plugins)

-- LSP Setup
require('config/lsp-config')

-- Completion Setup
require('config/cmp-config')

-- Treesitter-setup
require('config/ts-config')

-- Options (vim.opt settings + diagnostic config)
require('config/general/options')

-- Global autocommands
require('config/general/autocmds')

-- Keymaps and Burrow menus
require('config/general/keymaps')
