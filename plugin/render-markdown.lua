if vim.g.loaded_fk_markdown then
    return
end
vim.g.loaded_fk_markdown = true

require('fk_markdown').setup(vim.g.fk_markdown_config)
require('fk_markdown.core.colors').init()
require('fk_markdown.core.command').init()
require('fk_markdown.core.log').init()
require('fk_markdown.core.manager').init()
