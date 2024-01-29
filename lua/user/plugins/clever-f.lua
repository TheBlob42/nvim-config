local ns = vim.api.nvim_create_namespace('clever-f')
local current

---Return a mapping function for the "clever-f" functionality
---@param c string The character that triggers this mapping
---@return function clever-f-mapping-fn A "clever-f" function for the specific char that can be used for a keymapping
local function clever(c)
    local forward = c == c:lower()

    return function()
        if current and current:lower() == c:lower() then
            if forward then
                return ';'
            else
                return ','
            end
        else
            current = c
            local i = 1
            vim.on_key(function(char)
                if i == 1 then
                    -- this is the initial f/F/t/T key press
                    i = i + 1
                elseif i == 2 then
                    -- this is the character we want to jump to (set custom line highlights)
                    i = i + 1
                    local line_nr = assert(vim.fn.line('.'))
                    local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
                    if line:len() < 1000 then
                        local j = 0
                        while true do
                            ---@diagnostic disable-next-line: cast-local-type
                            j = line:find(vim.pesc(char), j)
                            if not j then break end
                            vim.fn.matchaddpos('IncSearch', {{ line_nr, j }})
                            j = j + 1
                        end
                    end
                else
                    if char ~= ';' and char ~= ',' then
                        current = nil
                        vim.fn.clearmatches()
                        ---@diagnostic disable-next-line: param-type-mismatch
                        vim.on_key(nil, ns)
                    end
                end
            end, ns)

            return c
        end
    end
end

vim.keymap.set({ 'n', 'x' }, 'f', clever('f'), { expr = true, desc = 'f (clever-f)' })
vim.keymap.set({ 'n', 'x' }, 'F', clever('F'), { expr = true, desc = 'F (clever-f)' })
vim.keymap.set({ 'n', 'x' }, 't', clever('t'), { expr = true, desc = 't (clever-f)' })
vim.keymap.set({ 'n', 'x' }, 'T', clever('T'), { expr = true, desc = 'T (clever-f)' })
