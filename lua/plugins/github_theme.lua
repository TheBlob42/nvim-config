local status_ok, github = my.req('github-theme')
if not status_ok then
    return
end

local dark = 'dark'
local light = 'light'

local function load_theme(style)
    github.setup {
        theme_style = style,
        dark_sidebar = false,
    }
    vim.cmd('doautocmd Colorscheme') -- autocmd 'Colorscheme' is not triggered via 'setup'

    -- otherwise the prompt counter would be invisible
    vim.cmd [[ hi! link TelescopePromptCounter Normal ]]
    -- make debug line better visible
    vim.cmd [[ hi! link debugPC MatchParen ]]
end

-- startup NVIM in dark mode after 7PM
local hour = os.date('*t').hour
if hour > 18 or hour < 8 then
    load_theme(dark)
else
    load_theme(light)
end

-- toggle colorscheme between light and dark
vim.api.nvim_create_user_command('ToggleDarkMode', function()
    if vim.g.colors_name == 'github_dark' then
        load_theme(light)
    else
        load_theme(dark)
    end
end, {})
