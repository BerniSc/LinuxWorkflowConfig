-- Auto-Activate TreeSitter highlight on Filetype enter IF installed
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("tree-sitter-enable", { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
            return
        end

        -- Check if highlighting queries exist for this language
        if vim.treesitter.query.get(lang, "highlights") then
            vim.treesitter.start(args.buf)
        end
    end,
})

local ensure_installed = { 'bash', 'c', 'lua', 'vim', 'cpp', 'svelte', 'html', 'css', 'javascript', 'markdown', 'yaml', 'python' }
require('nvim-treesitter').install(ensure_installed)

local custom_ftype_maps = {
    ["*.inc"] = "bitbake",
}

for pattern, filetype in pairs(custom_ftype_maps) do
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        pattern = pattern,
        callback = function()
            vim.bo.filetype = filetype
        end,
    })
end
