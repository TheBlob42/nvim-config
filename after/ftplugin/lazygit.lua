-- avoid collision with custom <esc> sequence in lazygit
vim.keymap.set('t', '<esc>', '<esc>', { buffer = true })
