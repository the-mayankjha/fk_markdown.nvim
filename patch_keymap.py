import re

with open('lua/fk_markdown/preview/command.lua', 'r') as f:
    content = f.read()

keymap_code = """
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
"""

content = content.replace("end\n\nreturn M", keymap_code + "end\n\nreturn M")

with open('lua/fk_markdown/preview/command.lua', 'w') as f:
    f.write(content)
