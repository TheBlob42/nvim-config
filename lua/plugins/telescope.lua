local status_ok, telescope = my.req('telescope')
if not status_ok then
    return
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local transform_mod = require('telescope.actions.mt').transform_mod
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local builtin = require('telescope.builtin')
local make_entry = require('telescope.make_entry')

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
            -- base_dirs = my.sys_local.project_base_dirs
            base_dirs = my.lookup(my, { 'sys_local', 'project_base_dirs' })
        },
    },
}

-- load telescope extensions
require('telescope').load_extension('project')
require('telescope').load_extension('file_browser')
require('telescope').load_extension('fzf')

-- ~~~~~~~~~~~~~~~~~~~~
-- ~ custom functions ~
-- ~~~~~~~~~~~~~~~~~~~~

local function live_grep_in_dir()
    if vim.fn.executable('find') < 1 then
        vim.api.nvim_echo({ "'find' was not found in PATH, install it in order to use this command!", 'ErrorMsg' }, true, {})
        return
    end

    local path = vim.fn.expand('%')
    if path == '' or vim.opt.buftype:get('buftype') == 'nofile' then
        path = vim.fn.getcwd()
    else
        path = vim.fn.fnamemodify(path, ':p:h')
    end

    local entry_maker = function(entry)
        local dir_name = '.' .. entry:sub(#path+1)
        return {
            value = entry,
            display = dir_name,
            ordinal = dir_name,
        }
    end

    pickers.new({}, {
        prompt_title = 'Select Directory',
        results_title = path,
        finder = finders.new_oneshot_job({ "find", path, '-maxdepth', '1', '-type', 'd' }, { entry_maker = entry_maker }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            -- navigate into the parent directory of the current path
            local goto_parent_dir = function()
                path = vim.fn.fnamemodify(path, ':h')

                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker.results_border:change_title(path)

                local finder = finders.new_oneshot_job({ "find", path, '-maxdepth', '1', '-type', 'd' }, { entry_maker = entry_maker })
                current_picker:refresh(finder, { reset_prompt = true })
            end

            -- navigate into the selected directory and continue
            local goto_selected_dir = function()
                local selection = action_state.get_selected_entry()
                path = selection.value

                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker.results_border:change_title(path)

                local finder = finders.new_oneshot_job({ "find", path, '-maxdepth', '1', '-type', 'd' }, { entry_maker = entry_maker })
                current_picker:refresh(finder, { reset_prompt = true })
            end

            -- start the search with the current selected entry as search directory
            local start_search = function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()

                if selection then
                    local target_dir = selection.value
                    local title = vim.fn.fnamemodify(target_dir, ':~')

                    vim.schedule(function()
                        require('telescope.builtin').live_grep {
                            prompt_title = "Search in '" .. title .. "'",
                            search_dirs = { target_dir },
                        }
                    end)
                end
            end

            map('i', '<C-SPACE>', start_search)
            map('i', '<C-h>', goto_parent_dir)
            map('i', '<CR>', goto_selected_dir)
            map('n', '<C-SPACE>', start_search)
            map('n', '<C-h>', goto_parent_dir)
            map('n', '<CR>', goto_selected_dir)

            return true
        end,
    }):find()
end

local function my_keymaps()
    local keymaps_encountered = {}
    local keymaps_table = {}
    local max_len_lhs = 0

    local function extract_keymap(keymaps)
        for _, keymap in pairs(keymaps) do
            local keymap_key = keymap.buffer .. keymap.mode .. keymap.lhs
            if not keymaps_encountered[keymap_key] and keymap.desc then
                keymaps_encountered[keymap_key] = true
                table.insert(keymaps_table, keymap)
                max_len_lhs = math.max(max_len_lhs, #require('telescope.utils').display_termcodes(keymap.lhs))
            end
        end
    end

    for _, mode in ipairs({ 'n', 'x', 'i', 'c' }) do
        local global = vim.api.nvim_get_keymap(mode)
        local buf_local = vim.api.nvim_buf_get_keymap(0, mode)
        extract_keymap(global)
        extract_keymap(buf_local)
    end

    pickers.new({}, {
        prompt_title = 'My Key Maps',
        finder = finders.new_table {
            results = keymaps_table,
            entry_maker = make_entry.gen_from_keymaps { width_lhs = max_len_lhs + 1 },
        },
        sorter = conf.generic_sorter {},
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if not selection then
                  return
                end

                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(selection.value.lhs, true, false, true), 't', true)
                return actions.close(prompt_bufnr)
            end)
            return true
        end,
    }):find()
end

-- ~~~~~~~~~~~~~~~
-- ~ keymappings ~
-- ~~~~~~~~~~~~~~~

local mappings = {
    { '<A-x>',  my_keymaps, 'my keymappings' },
    { '<leader>h',  '<CMD>Telescope help_tags<CR>', 'help tags' },
    { '<leader>bb', '<CMD>Telescope buffers<CR>', 'switch buffers' },
    { '<leader>el', '<CMD>Telescope diagnostics bufnr=0<CR>', 'list errors' },
    { '<leader>ff', '<CMD>Telescope file_browser hidden=true<CR>', 'find file' },
    { '<leader>fr', '<CMD>Telescope oldfiles<CR>', 'recent file' },
    { '<leader>pp', '<CMD>Telescope project<CR>', 'switch project' },
    { '<leader>pf', '<CMD>Telescope find_files<CR>', 'project files' },
    { '<leader>ss', '<CMD>Telescope current_buffer_fuzzy_find<CR>', 'search in current file' },
    { '<leader>pb', function() builtin.buffers { prompt_title = 'Project Buffers', only_cwd = true } end, 'project buffers' },
    { '<leader>sd', function()
        builtin.live_grep(require('telescope.themes').get_ivy { prompt_title = 'Search in CWD' })
    end, 'search in cwd' },
    { '<leader>sD', live_grep_in_dir, 'search in directory' },
}

for _, mapping in ipairs(mappings) do
    local lhs, rhs, desc = unpack(mapping)
    vim.keymap.set('n', lhs, rhs, { desc = desc })
end
