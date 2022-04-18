-- place for personal utility & configuration options
_G.my = {
    -- lisp filetypes (used for `conjure`, `cmp-conjure` & `parinfer`)
    lisps = { "clojure", "fennel", "janet", "racket", "scheme", "hy", "lisp" },
}

require('user.utils')        -- configuration utility
pcall(require, 'user.local') -- local user config (if present)

-- must be loaded before any other lua plugin
local status_ok, impatient = my.req('impatient')
if status_ok then
    impatient.enable_profile()
end
pcall(require, 'packer_compiled') -- not present on first launch

require('user.settings')
require('user.keymaps')
require('user.commands')
require('user.plugins')
require('lsp')
