local snippets = require('user.plugins.snippets')
local format = snippets.format

for _, ft in ipairs({ 'javascript', 'typescript', 'typescriptreact' }) do
    snippets.set_snippets(ft, {
        ['log'] = 'console.log($1);',
        ['if'] = format [[
            if ($1) {
            \t$0
            }
        ]],
        ['try'] = format [[
            try {
            \t$1
            } catch (${2:e}) {
            \t$0
            }
        ]],
    })
end
