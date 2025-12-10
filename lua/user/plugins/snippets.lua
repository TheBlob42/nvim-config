local M = {}

---Snippets not corresponding to a specific filetype
local generic_snippets = {}

---Snippets which correspond to a specific filetype
local filetype_snippets = {}

---Parse the given snippets for further processing
---This checks for "regex" snippets and places them in a dedicated sub table called `_regex` for easier access
---
---@param snippets table<string, string|fun(...): string> The snippet definitions that should be parsed
---@return table parsed_snippets
local function parse_snippets(snippets)
    local s = {}
    for trigger, snippet in pairs(snippets) do
        local regex = type(snippet) == 'function' and debug.getinfo(snippet).nparams > 0
        if regex then
            if not s._regex then
                s._regex = {}
            end
            s._regex[trigger] = snippet
        else
            s[trigger] = snippet
        end
    end
    return s
end

---Set generic snippets that should be applied not matter of the `filetype`
---This replaces all previously set generic snippets
---
---Snippets is a map of the `trigger` word to the corresponding snippet that should be expanded
---A snippet can either be a string following the LSP snippet syntax or a function that returns such a string
---Functions with more than zero parameters are considered as "regex" and will receive the matches as arguments
---
---@param snippets table<string, string|fun(...): string> The new generic snippet definitions
function M.set_generic_snippets(snippets)
    generic_snippets = parse_snippets(snippets)
end

---Set snippets for the given `filetype`
---This replaces all previously set snippets for this filetype
---
---Snippets is a map of the `trigger` word to the corresponding snippet that should be expanded
---A snippet can either be a string following the LSP snippet syntax or a function that returns such a string
---Functions with more than zero parameters are considered as "regex" and will receive the matches as arguments
---
---@param ft string The filetype to set the snippets
---@param snippet_definitions table<string, string|fun(...): string> The snippets that should replace the current ones
function M.set_snippets(ft, snippet_definitions)
    filetype_snippets[ft] = parse_snippets(snippet_definitions)
end

---Utility function to strip away unwanted indentation when defining snippets
---
---@param format_string string The snippet string that should be processed
---@param ... any (Optional) Additional arguments for `string.format`
---@return string snippet_string
function M.format(format_string, ...)
    local lines = vim.split(format_string, '\n')
    local line_count = vim.tbl_count(lines)

    local indentation = -1
    local filtered_lines = {}
    for i, l in ipairs(lines) do
        if (i == 1 or i == line_count) and l:find('^%s*$') then
            goto continue
        end

        if indentation == -1 then
            local _, line_indentation = l:find('^%s+')
            if line_indentation then
                indentation = line_indentation + 1
            else
                indentation = 0
            end
        end

        table.insert(filtered_lines, l:sub(indentation))
        ::continue::
    end

    return table.concat(filtered_lines, '\n')
      :gsub('\\t', '\t') -- keep tabs in snippets
      :format(...)
end

vim.keymap.set({ 'i', 's' }, '<ESC>', function()
    if vim.snippet.active() then
        vim.snippet.stop()
    end
    return '<ESC>'
end, { expr = true })

-- delay snippet execution on the event loop to make sure that the snippet text was already deleted
local snippet_text = '<CMD>lua vim.schedule(function() pcall(vim.snippet.expand, _G.s(%s)) end)<CR>'

vim.keymap.set({ 'i', 's' }, '<Tab>', function()
    if vim.snippet.active({ direction = 1 }) then
        return '<CMD>lua vim.snippet.jump(1)<CR>'
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local word = line:sub(1, col):match('[%w%d%-_,.>]+$')

    if not word then
        return '<TAB>'
    end

    -- check filetype specific snippets first, then go for generic ones
    for _, snippets in ipairs({ filetype_snippets[vim.bo.filetype] or {}, generic_snippets }) do
        local snippet = snippets[word]

        if snippet then
            if type(snippet) == 'function' then
                _G.s = snippet
            else
                _G.s = function() return snippet end
            end

            return ('<bs>'):rep(#word)..snippet_text:format('')
        end

        if snippets._regex then
            for rgx, s in pairs(snippets._regex) do
                local matches = { word:match(rgx) }
                if not vim.tbl_isempty(matches) then
                    _G.s = s
                    return ('<bs>'):rep(#word)..snippet_text:format('"'..word..'","'..table.concat(matches, '","')..'"')
                end
            end
        end
    end

    return '<TAB>'
end, { expr = true })

return M
