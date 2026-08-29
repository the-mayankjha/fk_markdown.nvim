local M = {}

function M.init()
    vim.api.nvim_create_user_command('FkPreview', function()
        require('fk_markdown.preview').start()
    end, { desc = 'Start fk_markdown browser preview' })

    vim.api.nvim_create_user_command('FkPreviewStop', function()
        require('fk_markdown.preview').stop()
    end, { desc = 'Stop fk_markdown browser preview' })

    vim.api.nvim_create_user_command('FkPreviewToggle', function()
        require('fk_markdown.preview').toggle()
    end, { desc = 'Toggle fk_markdown browser preview' })

    local state = require('fk_markdown.state')
    local config = state.config.preview or {}
    if config.keymap then
        if config.keymap.start then
            vim.keymap.set('n', config.keymap.start, '<cmd>FkPreview<CR>', { desc = 'Start fk_markdown preview' })
        end
        if config.keymap.stop then
            vim.keymap.set('n', config.keymap.stop, '<cmd>FkPreviewStop<CR>', { desc = 'Stop fk_markdown preview' })
        end
        if config.keymap.toggle then
            vim.keymap.set('n', config.keymap.toggle, '<cmd>FkPreviewToggle<CR>', { desc = 'Toggle fk_markdown preview' })
        end
    end
end

return M
