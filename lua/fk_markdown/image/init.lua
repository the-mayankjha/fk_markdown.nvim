-- Markdown images via Kitty unicode placeholders (same protocol as LaTeX).

local kitty = require('fk_markdown.latex.kitty')
local state = require('fk_markdown.image.state')

local M = {}

---@param context render.md.request.Context
---@param marks render.md.Marks
---@param node render.md.Node
---@return boolean handled
function M.try_render(context, marks, node)
    local config = context.config.image
    if not config or not config.enabled then
        return false
    end
    if not kitty.is_supported() then
        return false
    end
    local dest = node:child('link_destination')
    if not dest then
        return false
    end
    local src = dest.text
    local node_id = tostring(node.start_row) .. '_' .. tostring(node.start_col)
    local err = state.errors[node_id]
    if err and err.src == src then
        return false
    end

    local active = state.active[node_id]
    if not active or active.src ~= src then
        state.request(src, context.buf, config, node_id, function(img)
            if img and vim.api.nvim_buf_is_valid(context.buf) then
                pcall(
                    require('fk_markdown.core.ui').update,
                    context.buf,
                    context.win,
                    'UserCommand',
                    true
                )
            end
        end)
        return false
    end

    -- Conceal the markdown. Draw the full image as a rectangular virt_lines
    -- grid so placeholders do not wrap on the short `![]()` line (that tiles).
    marks:add(config, false, node.start_row, node.start_col, {
        conceal = '',
        end_row = node.end_row,
        end_col = math.max(node.end_col, node.start_col + 1),
    })
    local lines = kitty.build_virt_lines(active.id, active.rows, active.cols)
    marks:add(config, false, node.start_row, 0, {
        virt_lines = lines,
        virt_lines_above = false,
    })
    return true
end

return M
