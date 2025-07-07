--[[
    Automatically switch the cwd depending on the current file/buffer
    You need to call the `setup` function to enable this functionality

    See also this thread on reddit:
    https://www.reddit.com/r/neovim/comments/zy5s0l/you_dont_need_vimrooter_usually_or_how_to_set_up/
--]]

local M = {}

---@class RooterOptions
---@field root_markers string[]? Directory markers to identify the current root folder (default: `{ '.git', 'Makefile', '.marksman.toml' }`)

local options = {
    root_markers = { '.git', 'Makefile', '.marksman.toml' }
}

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

    if not vim.uv.fs_stat(path) then
        return
    end

    if vim.fn.isdirectory(path) == 0 then
        path = assert(vim.fs.dirname(path))
    end

    local root = root_cache[path]
    if root == nil then
        root = path -- defaults to the parent directory of the current file

        local root_file = vim.fs.find(options.root_markers, {
            path = path,
            upward = true,
            stop = vim.env.HOME,
        })[1]

        if root_file then
            root = vim.fs.dirname(root_file)
        end

        root_cache[path] = root
    end

    vim.fn.chdir(root)
end

---Setup the `rooter` plugin
---@param opts RooterOptions? Plugin options to overwrite the defaults
function M.setup(opts)
    options = vim.tbl_extend('force', options, opts or {})

    vim.opt.autochdir = false
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
        group = vim.api.nvim_create_augroup('AutoRoot', { clear = true }),
        callback = set_root,
    })
end

return M
