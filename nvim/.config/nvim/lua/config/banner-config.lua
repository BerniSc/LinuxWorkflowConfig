require('lualine').setup {
    options = {
        theme = 'auto',
        component_separators = '|',
        section_separators = { left = '', right = '' },
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
