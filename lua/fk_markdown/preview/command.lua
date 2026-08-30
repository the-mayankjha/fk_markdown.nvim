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

    local function autoscroll_cmd(opts)
        require('fk_markdown.preview').autoscroll(opts.args ~= '' and opts.args or nil)
    end

    local autoscroll_opts = {
        desc = 'Toggle or set auto scroll in preview (on|off|toggle)',
        nargs = '?',
        complete = function(arglead)
            local options = { 'toggle', 'on', 'off', 'enable', 'disable', 'true', 'false' }
            local matches = {}
            for _, opt in ipairs(options) do
                if opt:sub(1, #arglead) == arglead then
                    table.insert(matches, opt)
                end
            end
            return matches
        end,
    }

    vim.api.nvim_create_user_command('FkPreviewAutoScroll', autoscroll_cmd, autoscroll_opts)
    vim.api.nvim_create_user_command('FkAutoScroll', autoscroll_cmd, autoscroll_opts)
    vim.api.nvim_create_user_command('FkAutoscroll', autoscroll_cmd, autoscroll_opts)
    vim.api.nvim_create_user_command('FkPreviewAutoscroll', autoscroll_cmd, autoscroll_opts)

    local state = require('fk_markdown.state')
    local config = (state.config and state.config.preview) or {}
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
