local status_ok, houdini = my.req('houdini')
if not status_ok then
    return
end

houdini.setup {
    mappings = { 'fd', 'AA', 'II' },
    escape_sequences = {
        i = function(first, second)
            local seq = first..second

            if seq == 'AA' then
                return '<BS><BS><End>'
            end
            if seq == 'II' then
                return '<BS><BS><Home>'
            end
            return '<BS><BS><ESC>'
        end,
    },
}
