require('catppuccin')

local dark = 'mocha'
local light = 'latte'

local function highlight_adaptions()
    -- make debug line better visible
    vim.cmd [[ hi! link debugPC CurSearch ]]
    -- make cursorline more visible
    vim.cmd [[ hi! link CursorLine ColorColumn ]]
end

-- startup NVIM in dark mode in the evening hours
local hour = os.date('*t').hour
if hour > 18 or hour < 8 then
    vim.g.catppuccin_flavour = dark
else
    vim.g.catppuccin_flavour = light
end

vim.cmd('colorscheme catppuccin')
highlight_adaptions()

-- toggle colorscheme between light and dark
vim.api.nvim_create_user_command('ToggleDarkMode', function()
    if vim.g.catppuccin_flavour == dark then
        vim.g.catppuccin_flavour = light
        vim.cmd('Catppuccin ' .. light)
    else
        vim.g.catppuccin_flavour = dark
        vim.cmd('Catppuccin ' .. dark)
    end

    highlight_adaptions()
end, {})
