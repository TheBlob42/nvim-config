local status_ok, notify, telescope = my.req('notify', 'telescope')
if not status_ok then
    return
end

notify.setup {
    timeout = 2000,
    stages = 'static', -- no fancy animation to make disappearance faster
}

vim.notify = notify

-- make sure telescope extension is loaded properly
telescope.load_extension('notify')
