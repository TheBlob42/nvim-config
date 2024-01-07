-- source: https://www.reddit.com/r/neovim/comments/zy5s0l/you_dont_need_vimrooter_usually_or_how_to_set_up/

vim.opt.autochdir = false

local root_names = { '.git', 'Makefile', '.marksman.toml' }
local root_cache = {}

local function set_root()
    -- if there is a specific vim-rooter variable set use it with priority
    if vim.b.rootDir then
        vim.fn.chdir(vim.b.rootDir)
        return
    end

    -- terminal buffers should NEVER change the cwd
    if vim.api.nvim_get_option_value('buftype', {}) == 'terminal' then
        return
    end

    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then
        return
    end
    path = assert(vim.fs.dirname(path))

    local root = root_cache[path]
    if root == nil then
        local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
        if not root_file then
            return
        end
        root = vim.fs.dirname(root_file)
        root_cache[path] = root
    end

    vim.fn.chdir(root)
end

vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('AutoRoot', {}),
    callback = set_root,
})
