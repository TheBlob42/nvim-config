local M = {}

local query = vim.treesitter.query.parse('markdown', '((list_item (task_list_marker_unchecked)) @todo-item)')

---@class JournalOptions
---@field date_format string? The date format used for the journal files

local options = {
    date_format = '%Y-%V'
}

---Configure the journal plugin
---@param opts JournalOptions?
function M.configure(opts)
    options = vim.tbl_extend('force', options, opts or {})
end

---@diagnostic disable-next-line: param-type-mismatch
local journal_folder = vim.fs.joinpath(vim.fn.stdpath('data'), 'journal')
if not vim.loop.fs_stat(journal_folder) then
    vim.fn.mkdir(journal_folder, 'p')
end

---Return the relevant context for the given todo-list-item
---- If the item is part of a level 2 section (even if nested deeper) return the whole level 2 section
---- If the item is nested directly under the top level section (1) return its parent list element
---- If there is no section with a level marker (no heading in the file) also return the parent list
---@param item TSNode Treesitter node of type 'list_item'
---@return TSNode? context Treesitter node that represents the context for given item
local function get_context(item)
    local parent = item:parent()
    while parent do
        if parent:type() == 'section' then
            local heading = parent:child(0)
            if heading and heading:type() == 'atx_heading' then
                local marker = assert(heading:child(0))
                if marker:type() == 'atx_h1_marker' then
                    return item -- top level section with a heading
                elseif marker:type() == 'atx_h2_marker' then
                    return parent
                end
            else
                return item -- top level section without a heading
            end
        end
        item = parent
        parent = parent:parent()
    end
end

---Extract all text relevant to todo items that have not been completed yet
---@return table lines All lines that belong to unfinished todo items and their context
local function extract_todo_text()
    local items = {}

    for _, match, _ in query:iter_matches(vim.treesitter.get_node():tree():root(), 0, 0, -1) do
        for _, node in pairs(match) do
            local context = get_context(node)
            if not context then
                print("No context found for node: '" .. vim.treesitter.get_node_text(node, 0) .. "'")
            else
                local row = context:range() -- ignore the other range return values
                local text = vim.treesitter.get_node_text(context, 0)
                items[row] = text
            end
        end
    end

    -- sort the items by line number
    local ordered_items = {}
    local rows = vim.tbl_keys(items)
    table.sort(rows)
    for _, row in ipairs(rows) do
        table.insert(ordered_items, items[row])
    end

    -- convert into text lines
    return vim.iter(ordered_items)
        :map(function(i) return vim.split(i, "\n") end)
        :flatten(1)
        :totable()
end

---@alias Behavior '"match"' | '"before"' | '"after"'
---@class FindEntryOptions
---@field behavior? Behavior

---Find the journal entry for the given date
---Use options to further refine the search behavior (e.g. find the entry before or after the given date)
---@param date string? Date in the format 'YYYY-MM-DD'
---@param opts FindEntryOptions? Further options to specify the behavior
---@return string? path The path to the journal entry or nil if none was found
function M.find_entry(date, opts)
    date = date or os.date(options.date_format) .. ''

    opts = vim.tbl_extend('keep', opts or {}, {
        behavior = 'match' -- match, before & after
    })

    local tmp_before
    date = date .. '.md'

    -- vim.fs.dir streams through the folder in ascending order
    for name, type in vim.fs.dir(journal_folder) do
        if type == 'file' then
            if opts.behavior == 'match' and name == date then
                return vim.fs.joinpath(journal_folder, name)
            elseif opts.behavior == 'before' then
                if name < date then
                    tmp_before = name
                else
                    return vim.fs.joinpath(journal_folder, tmp_before)
                end
            elseif opts.behavior == 'after' and name > date then
                return vim.fs.joinpath(journal_folder, name)
            end
        end
    end

    if tmp_before then
        return vim.fs.joinpath(journal_folder, tmp_before)
    end
end

local function setup_journal_buffer(buf)
    buf = buf or vim.api.nvim_get_current_buf()

    vim.keymap.set('n', 'gl', function()
        local date = vim.fn.expand('%:t:r')
        M.open_next_entry(date)
    end, { buffer = buf, desc = 'jump to next journal entry' })
    vim.keymap.set('n', 'gh', function()
        local date = vim.fn.expand('%:t:r')
        M.open_latest_entry(date)
    end, { buffer = buf, desc = 'jump to previous journal entry' })
end

function M.open_latest_entry(before)
    local path = M.find_entry(before, { behavior = 'before' })
    if path then
        vim.cmd.e(path)
        setup_journal_buffer()
        return true
    end

    print('No journal entries found')
    return false
end

function M.open_next_entry(from)
    local path = M.find_entry(from, { behavior = 'after' })
    if path then
        vim.cmd.e(path)
        setup_journal_buffer()
        return true
    end

    print('No journal entries found')
    return false
end

function M.open()
    local today = os.date(options.date_format) .. ''
    local path = M.find_entry(today, { behavior = 'match'})
    if path then
        vim.cmd.e(path)
        setup_journal_buffer()
        return
    end

    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '# Notes for ' .. today, '' })
    vim.api.nvim_buf_set_name(buf, vim.fs.joinpath(journal_folder, today .. '.md'))

    if M.open_latest_entry(today) then
        local lines = extract_todo_text()
        vim.api.nvim_buf_set_lines(buf, 2, -1, false, lines)
    end

    vim.api.nvim_set_current_buf(buf)
    vim.cmd.w()
    vim.cmd.e() -- needed to trigger LSP etc.

    setup_journal_buffer(buf)
end

vim.keymap.set('n', '<leader>J', M.open, { desc = "open today's journal entry" })

return M
