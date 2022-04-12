local status_ok, notify = my.req('notify')
if not status_ok then
    return
end

notify.setup {
    timeout = 2000,
    stages = 'static', -- no fancy animation to make disappearance faster
}

vim.notify = notify
