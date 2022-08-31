local status_ok, telescope = my.req('telescope')
if not status_ok then
    return
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local transform_mod = require('telescope.actions.mt').transform_mod
local builtin = require('telescope.builtin')

-- ~~~~~~~~~~~~~~~~~~
-- ~ custom actions ~
-- ~~~~~~~~~~~~~~~~~~

---Get the cwd from the current file picker
---Return `nil` if the current picker is NOT a file picker
local function get_cwd()
    local selection = action_state.get_selected_entry()

    -- check `selection.text` to not open a search from a "search/live_grep" picker
    if selection and selection.cwd and not selection.text then
        return selection.cwd
    end
end

local custom_actions = {}

-- get some basic "paste" functionality in the prompt buffer
function custom_actions.paste(_)
    local text = vim.fn.getreg('+')
    vim.api.nvim_put({text}, vim.fn.getregtype('+'), true, true)
end

---Open a DREX buffer at the cwd of the selected entry (if possible)
---@param prompt_bufnr number
function custom_actions.open_drex_buffer(prompt_bufnr)
    local cwd = get_cwd()
    if cwd then
        actions.close(prompt_bufnr)
        require('drex').open_directory_buffer(cwd)
        return
    end

    vim.notify('Open DREX buffer not possible in this Telescope picker', vim.log.levels.WARN, {})
end

---Start a `live_grep` search from the cwd of the current picker
---Only works for file pickers (entries have a `cwd` property)
---@param prompt_bufnr number
function custom_actions.start_search(prompt_bufnr)
    local cwd = get_cwd()
    if cwd then
        actions.close(prompt_bufnr)
        local title = vim.fn.fnamemodify(cwd, ':~')
        vim.schedule(function()
            require('telescope.builtin').live_grep {
                prompt_title = "Search in '" .. title .. "'",
                search_dirs = { cwd },
            }
        end)
        return
    end

    vim.notify('Starting a Live Grep search is not possible from this Telescope picker!', vim.log.levels.WARN, {})
end

custom_actions = transform_mod(custom_actions)

-- ~~~~~~~~~~~~~~~~~~~
-- ~ telescope setup ~
-- ~~~~~~~~~~~~~~~~~~~

-- fix to make folds work with telescope
-- see: https://github.com/nvim-telescope/telescope.nvim/issues/1277
-- see: https://github.com/tmhedberg/SimpylFold/issues/130#issuecomment-1074049490
vim.api.nvim_create_autocmd('BufRead', {
    callback = function(opts)
        vim.api.nvim_create_autocmd('BufWinEnter', {
            buffer = opts.buf,
            once = true,
            command = 'normal! zx'
        })
    end
})

telescope.setup {
    defaults = {
        layout_config = {
            prompt_position = "top",
        },
        sorting_strategy = "ascending",
        mappings = {
            i = {
                ["<C-c>"] = actions.close,
                ["<A-d>"] = custom_actions.open_drex_buffer,
                ["<A-s>"] = custom_actions.start_search,
            },
            n = {
                ["p"]     = custom_actions.paste,
                ["q"]     = actions.close,
                ["fd"]    = actions.close,
                ["<C-c>"] = actions.close,
                ["<A-d>"] = custom_actions.open_drex_buffer,
                ["<A-s>"] = custom_actions.start_search,
            }
        },
    },
    pickers = {
        live_grep = {
            on_input_filter_cb = function(prompt)
                -- spaces are replaced with wildcards (like emacs "swiper")
                return { prompt = prompt:gsub('%s', '.*') }
            end
        },
    },
    extensions = {
        fzf = {
            override_generic_sorter = true,
            override_file_sorter = true,
        },
        project = {
            base_dirs = vim.tbl_get(my, 'sys_local', 'project_base_dirs')
        },
    },
}

-- load telescope extensions
require('telescope').load_extension('project')
require('telescope').load_extension('file_browser')
require('telescope').load_extension('fzf')

-- ~~~~~~~~~~~~~~~
-- ~ keymappings ~
-- ~~~~~~~~~~~~~~~

local mappings = {
    { '<A-x>',  '<CMD>Telescope keymaps show_plug=false<CR>', 'keymappings' },
    { '<leader>h',  '<CMD>Telescope help_tags<CR>', 'help tags' },
    { '<leader>bb', '<CMD>Telescope buffers<CR>', 'switch buffers' },
    { '<leader>el', '<CMD>Telescope diagnostics bufnr=0<CR>', 'list errors' },
    { '<leader>ff', '<CMD>Telescope file_browser hidden=true<CR>', 'find file (cwd)' },
    { '<leader>fF', '<CMD>Telescope file_browser hidden=true cwd=%:h<CR>', 'find file (%:h)' },
    { '<leader>fr', '<CMD>Telescope oldfiles<CR>', 'recent file' },
    { '<leader>pp', '<CMD>Telescope project<CR>', 'switch project' },
    { '<leader>pf', '<CMD>Telescope find_files<CR>', 'project files' },
    { '<leader>ss', '<CMD>Telescope current_buffer_fuzzy_find<CR>', 'search in current file' },
    { '<leader>pb', function() builtin.buffers { prompt_title = 'Project Buffers', only_cwd = true } end, 'project buffers' },
    { '<leader>sd', function()
        builtin.live_grep(require('telescope.themes').get_ivy { prompt_title = 'Search in CWD' })
    end, 'search in cwd' },
}

for _, mapping in ipairs(mappings) do
    local lhs, rhs, desc = unpack(mapping)
    vim.keymap.set('n', lhs, rhs, { desc = desc })
end
