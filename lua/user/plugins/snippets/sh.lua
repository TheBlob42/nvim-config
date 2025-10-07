local snippets = require('user.plugins.snippets')
local format = snippets.format

snippets.set_snippets('sh', {
    ['shebang'] = '#!/bin/bash',
    ['if'] = format [[
        if [ $1 ]; then
        \t$0
        fi
    ]],
})
