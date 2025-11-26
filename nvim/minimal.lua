local tmpdir = "/tmp/nvim-minimal"
local packer_dir = tmpdir .. "/site/pack/packer/start/packer.nvim"
local todo_dir = tmpdir .. "/site/pack/packer/start/todo-comments.nvim"
local plenary_dir = tmpdir .. "/site/pack/packer/start/plenary.nvim"

vim.opt.runtimepath:prepend(tmpdir .. "/site/pack/packer/start/packer.nvim")
vim.opt.runtimepath:prepend(tmpdir .. "/site/pack/packer/start/plenary.nvim")
vim.opt.runtimepath:prepend(tmpdir .. "/site/pack/packer/start/todo-comments.nvim")

-- Bootstrap packer if not present
if vim.fn.isdirectory(packer_dir) == 0 then
  vim.fn.system({
    "git", "clone", "--depth=1",
    "https://github.com/wbthomason/packer.nvim", packer_dir
  })
end

-- Bootstrap plenary if not present
if vim.fn.isdirectory(plenary_dir) == 0 then
  vim.fn.system({
    "git", "clone", "--depth=1",
    "https://github.com/nvim-lua/plenary.nvim", plenary_dir
  })
end

-- Bootstrap todo-comments if not present
if vim.fn.isdirectory(todo_dir) == 0 then
  vim.fn.system({
    "git", "clone", "--depth=1",
    "https://github.com/folke/todo-comments.nvim", todo_dir
  })
end

vim.cmd [[packadd packer.nvim]]
vim.cmd [[packadd plenary.nvim]]
vim.cmd [[packadd todo-comments.nvim]]

require("todo-comments").setup({})

vim.cmd [[set number]]

