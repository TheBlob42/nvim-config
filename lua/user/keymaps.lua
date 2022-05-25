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

-- go back to normal mode in terminal
map('t', '<esc>', '<c-\\><c-n>')

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
map('x', 'cn', mc_select .. '``cgn', { desc = 'mc change selection (forward)' })
map('x', 'cN', mc_select .. '``cgN', { desc = 'mc change selection (backward)' })

map('n', 'cq', '*Nqz', { desc = 'mc start macro (foward)' })
map('n', 'cQ', '#Nqz', { desc = 'mc start macro (backward)' })
map('n', '<F2>', mc_macro(), { expr = true, desc = 'mc end or replay macro' })

map('x', 'cq', mc_select .. '``qz', { desc = 'mc start macro (foward)' })
map('x', 'cQ', mc_select:gsub('/', '?') .. '``qz', { desc = 'mc start macro (backward)' })
map('x', '<F2>', mc_macro(mc_select), { expr = true, desc = 'mc end or replay macro' })

-- check if file belongs to a Gradle project and add the appropriate key bindings
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function(opts)
        vim.api.nvim_create_autocmd('BufWinEnter', {
            buffer = opts.buf,
            once = true,
            callback = function()
                if require('user.commands.gradlew').get_gradlew_script_path() then
                    vim.keymap.set('n', '<localleader>gg', '<CMD>GradlewList<CR>', { buffer = true })
                    vim.keymap.set('n', '<localleader>gc', '<CMD>GradlewClearCache<CR>', { buffer = true })
                    vim.keymap.set('n', '<localleader>gt', ':GradlewTask ', { buffer = true })
                end
            end
        })
    end
})

-- ~~~~~~~~~~~~~~~~~~~~~~
-- ~ leader keybindings ~
-- ~~~~~~~~~~~~~~~~~~~~~~

-- create repeatable diagnostics mappings (with `vim-repeat`)
my.repeat_map('<Plug>NextError', table.concat({
    '<CMD>lua vim.diagnostic.goto_next { float = false }<CR>',
    '<CMD>lua vim.diagnostic.open_float { border = "rounded" }<CR>'
}, ''))
my.repeat_map('<Plug>PrevError', table.concat({
    '<CMD>lua vim.diagnostic.goto_prev { float = false }<CR>',
    '<CMD>lua vim.diagnostic.open_float { border = "rounded" }<CR>'
}, ''))

---Remove all trailing whitespaces within the current buffer
---Retain cursor position & last search content
local function remove_trailing_whitespaces()
    local pos = vim.api.nvim_win_get_cursor(0)
    local last_search = vim.fn.getreg('/')
    vim.cmd(':%s/\\s\\+$//e')
    vim.fn.setreg('/', last_search)     -- restore last search
    vim.api.nvim_win_set_cursor(0, pos) -- restore cursor position
end

local mappings = {
    { '<F5>', remove_trailing_whitespaces, 'remove trailing whitespaces' },
    { 'gx', '<CMD>XOpen<CR>', 'open the link under the cursor via xdg-open' },
    -- leader mappings
    { '<leader><leader>', '<CMD>SwitchWindow<CR>', 'jump to another window' },
    { '<leader><TAB>', '<ESC>:b#<CR>', 'switch to previous buffer' },
    { '<leader>1', '<ESC>1<C-w>w', 'switch to window 1' },
    { '<leader>2', '<ESC>2<C-w>w', 'switch to window 2' },
    { '<leader>3', '<ESC>3<C-w>w', 'switch to window 3' },
    { '<leader>4', '<ESC>4<C-w>w', 'switch to window 4' },
    { '<leader>5', '<ESC>5<C-w>w', 'switch to window 5' },
    { '<leader>6', '<ESC>6<C-w>w', 'switch to window 6' },
    { '<leader>7', '<ESC>7<C-w>w', 'switch to window 7' },
    { '<leader>8', '<ESC>8<C-w>w', 'switch to window 8' },
    { '<leader>9', '<ESC>9<C-w>w', 'switch to window 9' },
    -- buffers
    { '<leader>ba', '<ESC>ggVGo', 'select all' },
    { '<leader>bn', '<CMD>enew<CR>', 'new buffer' },
    -- errors
    { '<leader>en', '<Plug>NextError', 'next error' },
    { '<leader>eN', '<Plug>PrevError', 'previous error' },
    { '<leader>ei', function() vim.diagnostic.open_float { border = 'rounded' } end, 'error details' },
    -- files
    { '<leader>fs', '<CMD>w<CR>', 'save file' , { silent = false } },
    { '<leader>fS', '<ESC>:saveas ', 'save file as', { silent = false } },
    -- insert
    { '<leader>iu', '<CMD>InsertUUID<CR>', 'insert uuid' },
    { '<leader>ij', ":<C-U>call append(line('.'), repeat([''], v:count1))<CR>", 'insert lines below' },
    { '<leader>ik', ":<C-U>call append(line('.')-1, repeat([''], v:count1))<CR>", 'insert lines above' },
    -- quit
    { '<leader>qq', '<CMD>confirm qall<CR>', 'quit NVIM' },
    -- search
    { '<leader>sc', '<CMD>nohl<CR>', 'clear search highlights' },
    -- tabs
    { '<leader>tn', '<CMD>TabNew<CR>', 'new tab' },
    { '<leader>td', '<CMD>tabclose<CR>', 'delete tab' },
    { '<leader>tH', '<CMD>-tabmove<CR>', 'move tab left' },
    { '<leader>tL', '<CMD>+tabmove<CR>', 'move tab right' },
    { '<leader>th', '<CMD>tabprevious<CR>', 'goto tab left' },
    { '<leader>tl', '<CMD>tabnext<CR>', 'goto tab right' },
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
