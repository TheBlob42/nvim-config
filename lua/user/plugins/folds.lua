--[[
    Making folds "nicer" by improving the look of the foldtext by adding decorations:
    - Highlight the folded line with `CursorLine` if hovered
    - Show count of folded lines

    This should be used in conjunction with `set foldtext=''`

    Most inspiration coming from this reddit post:
    https://www.reddit.com/r/neovim/comments/1le6l6x/add_decoration_to_the_folded_lines/
--]]

local M = {}

local ns = vim.api.nvim_create_namespace('folds')

local marked_curline = {}

local function clear_marked_curline(buf)
    local lnum = marked_curline[buf]
    if lnum then
        vim.api.nvim_buf_clear_namespace(buf, ns, lnum - 1, lnum)
        marked_curline[buf] = nil
    end
end

local function cursorline_folded(win, buf)
    if not vim.wo[win].cursorline then
        clear_marked_curline(buf)
        return
    end

    local curline = vim.api.nvim_win_get_cursor(win)[1]
    local lnum = marked_curline[buf]
    local foldstart = vim.fn.foldclosed(curline)
    if foldstart == -1 then
        clear_marked_curline(buf)
        return
    end

    local foldend = vim.fn.foldclosedend(curline)
    if lnum then
        if foldstart > lnum or foldend < lnum then
            clear_marked_curline(buf)
        end
    else
        vim.api.nvim_buf_set_extmark(buf, ns, foldstart - 1, 0, {
            line_hl_group = 'CursorLine',
            hl_mode = 'combine',
        })
        marked_curline[buf] = foldstart
    end
end

---Render additional information segments for each applicable fold
---@param buf integer The buffer id
---@param foldstart integer The start line number of the closed fold
---@return integer foldend The last line number of the closed fold
local function render_segments(buf, foldstart)
    local foldend = vim.fn.foldclosedend(foldstart)

    local folded_lines = foldend - foldstart + 1
    local folded_lines_segment = {{ ' [↕' .. folded_lines .. '] ', { 'Bold', 'MoreMsg' }}}

    local text = vim.api.nvim_buf_get_lines(buf, foldstart - 1, foldstart, false)[1]:match('^(.-)%s*$')
    vim.api.nvim_buf_set_extmark(buf, ns, foldstart - 1, 0, {
        virt_text = folded_lines_segment,
        virt_text_pos = 'overlay',
        virt_text_win_col = 2 + text:len(),
        hl_mode = 'combine',
        ephemeral = true,
        priority = 0,
    })

    return foldend
end

---Setup "beautiful" folds
---Is supposed to be used with `set foldtext=''`
function M.setup()
    -- the order of execution is: on_start, on_buf, on_win
    vim.api.nvim_set_decoration_provider(ns, {
        on_start = function(_)
            -- decorations should only be visible in the currently focused window
            -- avoid "weirdness" when same buffer is visible in multiple windows with different folds
            -- NOTE: this is experimental and the function signature might change
            vim.api.nvim__ns_set(ns, { wins = { vim.api.nvim_get_current_win() }})
        end,
        on_buf = function(_, buf, _)
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end,
        on_win = function(_, win, buf, topline, botline)
            if win == vim.api.nvim_get_current_win() then
                vim.api.nvim_win_call(win, function()
                    cursorline_folded(win, buf)
                end)

                local line = topline
                while line <= botline do
                    local foldstart = vim.fn.foldclosed(line)
                    if foldstart ~= -1 then
                        line = render_segments(buf, foldstart)
                    end
                    line = line + 1
                end
            end
        end
    })
end

return M
