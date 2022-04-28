local map = function(mode, lhs, rhs, opts)
    opts = opts or { silent = true }
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- TODO checkout: http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript

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

local mappings = {
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
    { '<leader>wL', '<Plug>IncWidth', 'inc widthʳ' },
    { '<leader>wH', '<Plug>DecWidth', 'dec widthʳ' },
    { '<leader>wK', '<Plug>IncHeight', 'inc heightʳ' },
    { '<leader>wJ', '<Plug>DecHeight', 'dec heightʳ' },
}

for _, mapping in ipairs(mappings) do
    local lhs, rhs, desc, custom_options = unpack(mapping)
    local options = { desc = desc, silent = true }
    if custom_options then
        options = vim.tbl_deep_extend('force', options, custom_options)
    end
    vim.keymap.set('n', lhs, rhs, options)
end
