local notify = require('notify')

notify.setup {
    timeout = 2000,
    stages = 'static', -- no fancy animation to make disappearance faster
}

vim.notify = notify

-- make sure telescope extension is loaded properly
require('telescope').load_extension('notify')
