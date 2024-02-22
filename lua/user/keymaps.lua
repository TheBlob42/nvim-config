local map = function(mode, lhs, rhs, opts)
    opts = opts or { silent = true }
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ some general keybindings ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- simply escape visual/select mode (for the "iRct" we have `houdini`)
map('x', 'fd', '<esc>')
map('s', 'fd', '<esc><esc>')

-- easier switch to normal mode from terminal mode
-- leave <esc> unchanged to not interfere with terminal commands that need it like vi, lazygit, etc.
map('t', '<C-q>', '<c-\\><c-n>', { desc = 'switch to normal mode' })
map('t', '<M-r>', function()
    -- add a custom highlight for visualisation
    local highlight = vim.fn.matchadd('@todo', '\\%#')
    vim.cmd.redraw()
    vim.schedule(function()
        pcall(vim.fn.matchdelete, highlight)
    end)

    local register = vim.fn.getcharstr()
    if register ~= vim.api.nvim_replace_termcodes('<ESC>', true, true, true) then
        return '<C-\\><C-N>"'..register..'pi'
    end
end, { expr = true, desc = 'paste from register' })

-- move line shortcuts
map('n', '<a-j>', ':m .+1<cr>==')
map('n', '<a-k>', ':m .-2<cr>==')
map('i', '<a-j>', '<esc>:m .+1<cr>==gi')
map('i', '<a-k>', '<esc>:m .-2<cr>==gi')
map('v', '<a-j>', ':m \'>+1<cr>gv=gv')
map('v', '<a-k>', ':m \'<-2<cr>gv=gv')

-- keep selection while shifting
map('v', '>', '>gv')
map('v', '<', '<gv')

-- paste in visual mode without replacing register content
map('x', 'p', [['pgv"' . v:register . 'y']], { noremap = true, expr = true })

-- close all other folds but the current one (using the 'z' mark)
map('n', 'z<C-f>', "mzzM'zzxzz", { desc = 'focus the current fold' })

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ multiple cursors (sort of) ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- see: http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript

local mc_select = [[y/\V\C<C-r>=escape(@", '/')<CR><CR>]]
local function mc_macro(selection)
    selection = selection or ''

    return function()
        if vim.fn.reg_recording() == 'z' then
            return 'q'
        end

        if vim.fn.getreg('z') ~= '' then
            return 'n@z'
        end

        return selection .. '*Nqz'
    end
end

map('n', 'cn', '*``cgn', { desc = 'mc change word (forward)' })
map('n', 'cN', '*``cgN', { desc = 'mc change word (backward)' })
map('x', '<leader>cn', mc_select .. '``cgn', { desc = 'mc change selection (forward)' })
map('x', '<leader>cN', mc_select .. '``cgN', { desc = 'mc change selection (backward)' })

map('n', 'cq', '*Nqz', { desc = 'mc start macro (foward)' })
map('n', 'cQ', '#Nqz', { desc = 'mc start macro (backward)' })
map('n', '<F2>', mc_macro(), { expr = true, desc = 'mc end or replay macro' })

map('x', '<leader>cq', mc_select .. '``qz', { desc = 'mc start macro (foward)' })
map('x', '<leader>cQ', mc_select:gsub('/', '?') .. '``qz', { desc = 'mc start macro (backward)' })
map('x', '<F2>', mc_macro(mc_select), { expr = true, desc = 'mc end or replay macro' })

-- check if file belongs to a Gradle project and add the appropriate key bindings
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function(opts)
        if vim.api.nvim_buf_is_valid(opts.buf) then
            vim.api.nvim_create_autocmd('BufWinEnter', {
                buffer = opts.buf,
                once = true,
                callback = function()
                    if require('user.commands.gradlew').get_gradlew_script_path() then
                        vim.keymap.set('n', '<localleader>gg', '<CMD>GradlewList<CR>', { buffer = true, desc = 'gradlew list tasks' })
                        vim.keymap.set('n', '<localleader>gc', '<CMD>GradlewClearCache<CR>', { buffer = true, desc = 'gradlew clear tasks cache' })
                        vim.keymap.set('n', '<localleader>gt', ':GradlewTask ', { buffer = true, desc = 'gradlew execute task'})
                    end
                end
            })
        end
    end
})

-- ~~~~~~~~~~~~~~~~~~~~~~
-- ~ leader keybindings ~
-- ~~~~~~~~~~~~~~~~~~~~~~

-- create repeatable diagnostics mappings (with `vim-repeat`)
-- unfortunately repeating with the floating diagnostics window does not work correctly
my.repeat_map('<Plug>NextError', function()
    vim.diagnostic.goto_next { float = false }
end)
my.repeat_map('<Plug>PrevError', function()
    vim.diagnostic.goto_prev { float = false }
end)

-- create repeatable spell mappings
my.repeat_map('<Plug>SpellCheckNext', ']s')
my.repeat_map('<Plug>SpellCheckPrev', '[s')

-- make moving tabs repeatable (with `vim-repeat`)
my.repeat_map('<Plug>MoveTabLeft',  '<CMD>-tabmove<CR>')
my.repeat_map('<Plug>MoveTabRight', '<CMD>+tabmove<CR>')

---Remove all trailing whitespaces within the current buffer
---Retain cursor position & last search content
local function remove_trailing_whitespaces()
    local pos = vim.api.nvim_win_get_cursor(0)
    local last_search = vim.fn.getreg('/')
    local hl_state = vim.v.hlsearch

    vim.cmd(':%s/\\s\\+$//e')

    vim.fn.setreg('/', last_search)     -- restore last search
    vim.api.nvim_win_set_cursor(0, pos) -- restore cursor position
    if hl_state == 0 then
        vim.cmd.nohlsearch() -- disable search highlighting again if it was disabled before
    end
end

---Like `:wa` but only for a certain directory (including all sub-directories)
---@param dir string? Directory to save all buffers (default: current working directory)
local function save_all_files_in_dir(dir)
    dir = dir or vim.loop.cwd()
    assert(dir, 'something went wrong')
    dir = vim.fn.fnamemodify(vim.fn.expand(dir), ':p')

    local saved = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':p')
        if vim.startswith(name, dir) then
            -- check for element type (file or directory) and modified status
            local file_info = vim.loop.fs_stat(name)
            local modified = vim.api.nvim_get_option_value('modified', { buf = buf })

            if file_info and file_info.type == 'file' and modified then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd.w()
                end)
                table.insert(saved, name)
            end
        end
    end

    if vim.tbl_isempty(saved) then
        vim.notify('Nothing was saved!', vim.log.levels.INFO, {})
    else
        vim.notify('Saved ' .. vim.tbl_count(saved) .. ' buffers:\n' .. table.concat(saved, '\n'), vim.log.levels.INFO, {})
    end
end

local mappings = {
    { '<F1>', '<CMD>setlocal spell!<CR>', 'toggle spell checking' },
    { '<F3>', function() vim.opt.background = vim.o.background == 'dark' and 'light' or 'dark' end, 'toggle background' },
    { '<F5>', remove_trailing_whitespaces, 'remove trailing whitespaces' },

    -- navigation
    { '<leader><leader>', '<CMD>SwitchWindow<CR>', 'jump to another window' },
    { '<leader><TAB>', '<ESC>:b#<CR>', 'switch to previous buffer' },

    -- buffers
    { '<leader>ba', '<ESC>ggVGo', 'select all' },
    { '<leader>bn', '<CMD>enew<CR>', 'new buffer' },

    -- errors
    { '<leader>en', '<Plug>NextError', 'next error' },
    { '<leader>eN', '<Plug>PrevError', 'previous error' },
    {
        '<leader>ei',
        function() vim.diagnostic.open_float { border = 'rounded' } end,
        'error details'
    },

    -- files
    { '<leader>fs', '<CMD>update<CR>', 'save file' , { silent = false } },
    { '<leader>f<C-s>', save_all_files_in_dir, 'save all files in cwd' },

    -- insert
    { '<leader>iu', '<CMD>InsertUUID<CR>', 'insert uuid' },
    { '<leader>ij', ":<C-U>call append(line('.'), repeat([''], v:count1))<CR>", 'insert lines below' },
    { '<leader>ik', ":<C-U>call append(line('.')-1, repeat([''], v:count1))<CR>", 'insert lines above' },

    -- quit
    { '<leader>qq', '<CMD>confirm qall<CR>', 'quit NVIM' },

    -- search
    { '<leader>sc', '<CMD>nohl<CR>', 'clear search highlights' },

    -- spelling
    { '<leader>ct', '<CMD>setlocal spell!<CR>', 'toggle spell checking' },
    { '<leader>cn', '<CMD>setlocal spell<CR><Plug>SpellCheckNext', 'next spelling error' },
    { '<leader>cN', '<CMD>setlocal spell<CR><Plug>SpellCheckPrev', 'prev spelling error' },
    { '<leader>cc', '<CMD>setlocal spell<CR><CMD>FzfLua spell_suggest<CR>', 'correct spelling error' },

    -- tabs
    { '<leader>tn', '<CMD>TabNew<CR>', 'new tab' },
    { '<leader>td', '<CMD>tabclose<CR>', 'delete tab' },
    { '<leader>tH', '<Plug>MoveTabLeft', 'move tab left' },
    { '<leader>tL', '<Plug>MoveTabRight', 'move tab right' },
    { '<leader>th', '<CMD>tabprevious<CR>', 'goto tab left' },
    { '<leader>tl', '<CMD>tabnext<CR>', 'goto tab right' },
    { '<leader>tt', require('user.plugins.tabline').switch_tab, 'switch tab' },
    { '<leader>tr', require('user.plugins.tabline').rename_tab, 'rename tab' },

    --windows
    { '<leader>w=', '<C-W>=', 'balance windows' },
    { '<leader>wh', '<C-W>h', 'goto window left' },
    { '<leader>wj', '<C-W>j', 'goto window down' },
    { '<leader>wk', '<C-W>k', 'goto window up' },
    { '<leader>wl', '<C-W>l', 'goto window right' },
    { '<leader>wd', '<C-W>c', 'delete window' },
    { '<leader>wD', '<C-W>o', 'delete other windows' },
    { '<leader>ws', '<CMD>split<CR>', 'split window' },
    { '<leader>wv', '<CMD>vsplit<CR>', 'vertical split window' },
    { '<leader>wL', '<Plug>WinResizeRight', 'win resize rightʳ' },
    { '<leader>wH', '<Plug>WinResizeLeft', 'win resize leftʳ' },
    { '<leader>wK', '<Plug>WinResizeUp', 'win resize upʳ' },
    { '<leader>wJ', '<Plug>WinResizeDown', 'win resize downʳ' },
}

for _, mapping in ipairs(mappings) do
    local lhs, rhs, desc, custom_options = unpack(mapping)
    local options = { desc = desc, silent = true }
    if custom_options then
        options = vim.tbl_deep_extend('force', options, custom_options)
    end
    vim.keymap.set('n', lhs, rhs, options)
end
