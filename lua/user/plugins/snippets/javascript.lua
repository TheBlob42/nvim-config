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
    })
end
