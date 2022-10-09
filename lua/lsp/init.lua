require('lsp.settings')
require('lsp.lsp-installer')
require('lsp.dap')

local status_ok, fidget = my.req('fidget')
if status_ok then
    fidget.setup {
        text = { spinner = 'dots_scrolling' }
    }
end
