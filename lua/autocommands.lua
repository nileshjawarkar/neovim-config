local ui_elem_group = vim.api.nvim_create_augroup('custom-ui-onevent-modif', { clear = true })
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`

-- Auto command to clear block cursor after exit. It help to prevent messup in terminals
-- color theme. This is useful in alacrity teminal OR may also helful in other
-- terminals.
vim.api.nvim_create_autocmd("ExitPre", {
    group = ui_elem_group,
    command = "set guicursor=a:ver90",
    desc = "Set cursor back to beam when leaving Neovim."
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = ui_elem_group,
    callback = function()
        vim.hl.on_yank()
    end,
})

-- By default cursorline is disabled.
-- Automatically enable cursorline only in the active window
vim.api.nvim_create_autocmd("WinEnter", {
    pattern = "*",
    group = ui_elem_group,
    callback = function()
        vim.wo.cursorline = true
    end,
})

-- Disable cursorline when switching away from a window
vim.api.nvim_create_autocmd("WinLeave", {
    pattern = "*",
    group = ui_elem_group,
    callback = function()
        vim.wo.cursorline = false
    end,
})

