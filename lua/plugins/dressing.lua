local status_ok, dressing, telescope_themes = my.req('dressing', 'telescope.themes')
if not status_ok then
    return
end

dressing.setup {
    select = {
        get_config = function(opts)
            return {
                telescope = telescope_themes.get_dropdown {
                    layout_config = {
                        width = function(_, max_columns, _)
                            -- make sure its wide enough to fit the complete prompt text
                            return math.min(max_columns, math.max(#opts.prompt, 80))
                        end,
                    }
                }
            }
        end
    }
}
