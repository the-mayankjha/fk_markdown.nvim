local Base = require('fk_markdown.render.base')
local Footnote = require('fk_markdown.render.common.footnote')
local Wiki = require('fk_markdown.render.common.wiki')

---@class render.md.render.inline.Shortcut: render.md.Render
---@field private config render.md.link.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local callout = self.context.config.resolved:callout(self.node)
    if callout then
        self.context.callout:set(self.node, callout)
        return false
    end
    local checkbox = self.context.config.resolved:checkbox(self.node)
    if checkbox then
        if self.node:after() == ' ' then
            self.context.checkbox:set(self.node, checkbox)
        end
        local cb_config = self.context.config.checkbox
        if cb_config and cb_config.enabled then
            self.data = { checkbox = checkbox, cb_config = cb_config }
            return true
        end
        return false
    end
    self.config = self.context.config.link
    return self.config.enabled
end

---@protected
function Render:run()
    if self.data and self.data.checkbox then
        local cb = self.data.checkbox
        local cb_config = self.data.cb_config
        local icon = cb.rendered or cb.icon or '󰄱 '
        local highlight = cb.highlight or 'RenderMarkdownUnchecked'
        self.marks:over(cb_config, 'check_icon', self.node, {
            virt_text = { { icon, highlight } },
            virt_text_pos = 'overlay',
            conceal = '',
        })
        return
    end
    local _, line = self.node:line('first', 0)
    if line and line:find('[' .. self.node.text .. ']', 1, true) then
        Wiki:execute(self.context, self.marks, self.node)
    else
        Footnote:execute(self.context, self.marks, self.node)
    end
end

return Render
