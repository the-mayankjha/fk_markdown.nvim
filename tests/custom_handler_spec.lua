---@module 'luassert'

local util = require('tests.util')

describe('custom handler', function()
    local lines = {
        '`Inline` code',
        '\\$1.50 \\$3.55',
    }

    ---@param ctx render.md.handler.Context
    ---@return render.md.Mark[]
    local function handler(ctx)
        local marks = {} ---@type render.md.Mark[]
        local buf_lines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
        for row, line in ipairs(buf_lines) do
            local index = 1 ---@type integer?
            while index do
                local col = line:find('$', index, true)
                if not col then
                    index = nil
                else
                    marks[#marks + 1] = {
                        conceal = true,
                        start_row = row - 1,
                        start_col = col - 1,
                        opts = {
                            end_row = row - 1,
                            end_col = col,
                            conceal = '',
                        },
                    }
                    index = col + 1
                end
            end
        end
        return marks
    end

    it('default', function()
        util.setup.text(lines)
        -- inline code + no custom handler
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 8 }, util.highlight('code'))
        util.assert_view(marks, {
            'Inline code',
            '$1.50 $3.55',
        })
    end)

    it('custom conceal override', function()
        util.setup.text(lines, {
            custom_handlers = {
                markdown_inline = { parse = handler },
            },
        })
        -- no inline code + custom handler
        local marks = util.marks()
        marks:add({ 1, 1 }, { 1, 2 }, util.conceal())
        marks:add({ 1, 1 }, { 8, 9 }, util.conceal())
        util.assert_view(marks, {
            'Inline code',
            '1.50 3.55',
        })
    end)

    it('custom conceal extend', function()
        util.setup.text(lines, {
            custom_handlers = {
                markdown_inline = { extends = true, parse = handler },
            },
        })
        -- inline code + custom handler
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 8 }, util.highlight('code'))
        marks:add({ 1, 1 }, { 1, 2 }, util.conceal())
        marks:add({ 1, 1 }, { 8, 9 }, util.conceal())
        util.assert_view(marks, {
            'Inline code',
            '1.50 3.55',
        })
    end)
end)
