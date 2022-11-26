require('catppuccin').setup {
    integrations = {
        notify = true,
        cmp = true,
        dap = {
            enabled = true,
            enable_ui = true,
        }
    }
}

local dark = 'mocha'
local light = 'latte'

local current = light

local function highlight_adaptions()
    -- make debug line better visible
    vim.cmd [[ hi! link debugPC CurSearch ]]
    -- make cursorline more visible
    vim.cmd [[ hi! link CursorLine ColorColumn ]]
end

-- startup NVIM in dark mode in the evening hours
local hour = os.date('*t').hour
if hour > 18 or hour < 8 then
    current = dark
else
    current = light
end

vim.cmd('colorscheme catppuccin-' .. current)
highlight_adaptions()

-- toggle colorscheme between light and dark
vim.api.nvim_create_user_command('ToggleDarkMode', function()
    current = current == dark and light or dark
    vim.cmd('colorscheme catppuccin-' .. current)
    highlight_adaptions()
end, {})
