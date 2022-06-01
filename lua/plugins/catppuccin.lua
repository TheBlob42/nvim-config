local status_ok, _ = my.req('catppuccin')
if not status_ok then
    return
end

local dark = 'mocha'
local light = 'latte'

local function highlight_adaptions()
    -- make debug line better visible
    vim.cmd [[ hi! link debugPC TSNote ]]
end

-- startup NVIM in dark mode after 7PM
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
