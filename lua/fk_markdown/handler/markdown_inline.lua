local Context = require('fk_markdown.request.context')
local Marks = require('fk_markdown.lib.marks')
local ts = require('fk_markdown.core.ts')

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    -- stylua: ignore
    local query = ts.parse('markdown_inline', [[
        (code_span) @code

        ((inline) @highlight
            (#lua-match? @highlight "==[^=]+=="))

        [
            (email_autolink)
            (full_reference_link)
            (image)
            (inline_link)
            (uri_autolink)
        ] @link

        (shortcut_link) @shortcut
    ]])
    ---@type table<string, render.md.Render>
    local renders = {
        code = require('fk_markdown.render.inline.code'),
        highlight = require('fk_markdown.render.inline.highlight'),
        link = require('fk_markdown.render.inline.link'),
        shortcut = require('fk_markdown.render.inline.shortcut'),
    }
    local context = Context.get(ctx.buf)
    local marks = Marks.new(context, true)
    context.view:nodes(ctx.root, query, function(capture, node)
        local render = renders[capture]
        assert(render, ('unhandled inline capture: %s'):format(capture))
        render:execute(context, marks, node)
    end)
    return marks:get()
end

return M
