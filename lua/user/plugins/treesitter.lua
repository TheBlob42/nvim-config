-- Simple module with some helper functions for using treesitter
local M = {}

---Search for the first node in `direction` that is of the given `type`
---@param type string
---@param direction "upward"|"forward"
---@return TSNode? node
function M.find_node_by_type(type, direction)
    return M.find_node(function(n)
        return n:type() == type
    end, direction)
end

---Search for the first node in `direction` that matches the given `predicate`
---@param predicate fun(node: TSNode): boolean The predicate function to check every iterated node
---@param direction 'upward'|'forward' The direction of the search
---@param start_node TSNode? Starting node if not current one
---@return TSNode? node
function M.find_node(predicate, direction, start_node)
    local node = start_node or vim.treesitter.get_node()
    if not node then
        return
    end

    if direction == 'upward' then
        local parent = node and node:parent()
        while node do
            if predicate(node) then
                return node
            end

            node = parent
            parent = node and node:parent()
        end
    elseif direction == 'forward' then
        if predicate(node) then
            return node
        end

        for child in node:iter_children() do
            if predicate(child) then
                return child
            end

            local result = M.find_node(predicate, 'forward', child)
            if result then
                return result
            end
        end
    end
end

---Same as `vim.treesitter.get_node` but additionally also accepts a `biggest` option
---With the `biggest` option set it returns the node covering the widest range at the given position
---@param opts table? Optional options to refine the search
---@return TSNode? node
function M.get_node(opts)
    local biggest = (opts or {}).biggest
    local node = vim.treesitter.get_node(opts)

    if node and biggest then
        local row, col = node:range()
        local parent = node:parent()
        while parent do
            local prow, pcol = parent:range()
            if row == prow and col == pcol then
                node = parent
                parent = node:parent()
            else
                return node
            end
        end
    end

    return node
end

---Execute the given `query` over the given treesitter `node`
---Return the text of all query captures grouped by the capture name
---Ensure that they are in the exact order as they appear in the node
---
---## Example
---
---Take the following java method declaration as an example:
---```java
---public String testMethod(int paramOne, int paramTwo) {}
---```
---Extract the return type and parameter names with the following call:
---```lua
---get_captures(node, vim.treesitter.query.parse('java', [[
---  (method_declaration
---    type: (_) @type
---    parameters: (formal_parameters
---                  (formal_parameter
---                     name: (identifier) @param)))]]))
---```
---The result will be:
---```lua
---{
---   type = { "String" },
---   param = { "paramOne", "paramTwo" } -- order of appearance
---}
---```
---@param node TSNode
---@param query vim.treesitter.Query
---@return table<string, string[]> results
function M.get_captures(node, query)
    local used_node_ids = {}
    local result = {}

    for capture_id, capture_node, _, _ in query:iter_captures(node, 0) do
        local name = query.captures[capture_id]
        local node_id = capture_node:id()

        if not result[name] then
            result[name] = {}
        end

        if not used_node_ids[node_id] then
            used_node_ids[node_id] = true
            result[name][#result[name]+1] = vim.treesitter.get_node_text(capture_node, 0)
        end
    end

    return result
end

return M
