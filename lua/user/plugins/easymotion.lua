--[[
    Simple EasyMotion plugin to quickly jump to any position marked by 2 characters

    Supports the following features:
    - Adding position to jumplist
    - Skip folded lines (only visible lines)
    - Multiple match groups when there are a lot of matches
    - If there is only a single match jump to it directly
--]]
local M = {}

local ns = vim.api.nvim_create_namespace('custom-easymotion')

---@class EasyMotionOptions
---@field mapping string Mapping for setting up the normal/visual mode keybinding
---@field next_group_char string Char that should be used to switch to the next group of labels if there are not enough `chars` to label them all
---@field chars string[] Chars that should be used for the jump labels
local options = {}

---@class EasyMotionPosition
---@field line integer
---@field col integer

---Catch keyboard interrupts during `getchar`
---@return string? Char input by the user
local function get_char()
    local status, char = pcall(vim.fn.getchar, -1)
    if status then
        ---@diagnostic disable-next-line: param-type-mismatch
        return vim.fn.nr2char(char)
    end
end

local function easymotion()
    local conceallevel = vim.wo.conceallevel
    vim.wo.conceallevel = 0

    -- trigger to show "hidden" text before continue
    vim.cmd.redraw()

    local reset = function()
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        vim.wo.conceallevel = conceallevel
    end

    local char1 = get_char()
    if not char1 then
        return reset()
    end
    local char2 = get_char()
    if not char2 then
        return reset()
    end
    local needle = char1 .. char2

    local case_sensitive = needle:lower() ~= needle
    if not case_sensitive then
        needle = needle:lower()
    end

    local first_line = vim.fn.line('w0')
    local last_line = vim.fn.line('w$')
    local lines = vim.api.nvim_buf_get_lines(0, first_line - 1, last_line, false)

    ---@type table<table<string, EasyMotionPosition>>
    local matches = {{}}
    local matches_index = 1
    local char_index = 1

    for line_index, line in ipairs(lines) do
        if vim.fn.foldclosed(line_index) == -1 then
            if not case_sensitive then
                line = line:lower()
            end

            local col = line:find(needle)

            while col do
                if char_index > #options.chars then
                    char_index = 1
                    matches_index = matches_index + 1
                    matches[matches_index] = {}
                end

                matches[matches_index][options.chars[char_index]] = {
                    line = line_index + first_line - 1,
                    col = col - 1,
                }

                char_index = char_index + 1
                col = line:find(needle, col + 1)
            end
        end
    end

    -- if there are no matches at all abort here
    if vim.tbl_isempty(matches[1]) then
        vim.wo.conceallevel = conceallevel
        return vim.api.nvim_echo({{ 'No matches found!', 'WarningMsg' }}, false, {})
    end

    -- if there is only a single match, jump to it directly
    if vim.tbl_count(matches[1]) == 1 then
        local ext = matches[1][options.chars[1]]
        vim.cmd("normal! m'")
        vim.api.nvim_win_set_cursor(0, { ext.line, ext.col })
        return reset()
    end

    matches_index = 1

    local jump
    jump = function()
        for index, marks in ipairs(matches) do
            for char, pos in pairs(marks) do
                local text, hl = ' ', 'CursorLine'
                if index == matches_index then
                    text, hl = char, 'CurSearch'
                end

                vim.api.nvim_buf_set_extmark(0, ns, pos.line - 1, pos.col + 2, {
                    virt_text_pos = 'overlay',
                    virt_text = {{ text, hl }},
                    hl_mode = 'replace',
                })
                vim.api.nvim_buf_set_extmark(0, ns, pos.line - 1, pos.col, {
                    end_col = pos.col + 2,
                    hl_group = 'DiagnosticUnderlineOk',
                    hl_mode = 'combine',
                })
            end
        end

        -- trigger redraw to show the labels before continue
        vim.cmd.redraw()

        ---@diagnostic disable-next-line: param-type-mismatch
        local char = get_char()
        reset()
        if not char then
            return
        end

        if char == options.next_group_char then
            matches_index = (matches_index % #matches) + 1
            return jump()
        end

        local ext = matches[matches_index][char]
        if ext then
            vim.cmd("normal! m'")
            vim.api.nvim_win_set_cursor(0, { ext.line, ext.col })
        end
    end

    jump()
end

---Setup the easymotion keybinding and options
---@param opts? EasyMotionOptions
function M.setup(opts)
    options = vim.tbl_extend('keep', opts or {}, {
        chars = vim.split('fjdkslgha;rueiwotyqpvbcnxmzFJDKSLGHARUEIWOTYQPVBCNXMZ', ''),
        mapping = 's',
        next_group_char = ' ',
    })
    vim.keymap.set({ 'n', 'x' }, options.mapping, easymotion, { desc = 'Jump to 2 characters' })
end

return M
