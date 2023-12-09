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

local function load_catppuccin()
    vim.cmd.colorscheme('catppuccin')

    -- some highlight adaptions
    vim.cmd [[ hi! link debugPC CurSearch ]]      -- make debug line better visible
    vim.cmd [[ hi! link CursorLine ColorColumn ]] -- make cursorline more visible
end

-- startup NVIM in dark mode in the evening hours
local hour = os.date('*t').hour
if hour > 18 or hour < 8 then
    vim.opt.background = "dark"
else
    vim.opt.background = "light"
end

load_catppuccin()

-- toggle colorscheme between light and dark
vim.api.nvim_create_user_command('ToggleDarkMode', function()
    local background = vim.opt.background:get()
    vim.opt.background = background == 'dark' and 'light' or 'dark'
    load_catppuccin()
end, {})
