-- Markdown images via Kitty unicode placeholders (same protocol as LaTeX).

local kitty = require('fk_markdown.latex.kitty')
local state = require('fk_markdown.image.state')
local html = require('fk_markdown.image.html')

local M = {}

---@param context render.md.request.Context
local function refresh(context)
    if vim.api.nvim_buf_is_valid(context.buf) then
        pcall(
            require('fk_markdown.core.ui').update,
            context.buf,
            context.win,
            'UserCommand',
            true
        )
    end
end

---@param context render.md.request.Context
---@param marks render.md.Marks
---@param src string
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@param width_px? integer
---@return boolean handled
function M.try_src(context, marks, src, start_row, start_col, end_row, end_col, width_px)
    local config = context.config.image
    if not config or not config.enabled then
        return false
    end
    if not kitty.is_supported() then
        return false
    end
    local node_id = table.concat({
        tostring(start_row),
        tostring(start_col),
        src,
        tostring(width_px or 0),
    }, '_')
    local err = state.errors[node_id]
    if err and err.src == src then
        return false
    end

    local active = state.active[node_id]
    if not active or active.src ~= src then
        state.request(src, context.buf, config, node_id, function()
            refresh(context)
        end, width_px)
        return false
    end

    marks:add(config, false, start_row, start_col, {
        conceal = '',
        end_row = end_row,
        end_col = math.max(end_col, start_col + 1),
    })
    local lines = kitty.build_virt_lines(active.id, active.rows, active.cols)
    marks:add(config, false, start_row, 0, {
        virt_lines = lines,
        virt_lines_above = false,
    })
    return true
end

---@param context render.md.request.Context
---@param marks render.md.Marks
---@param node render.md.Node
---@return boolean handled
function M.try_render(context, marks, node)
    local dest = node:child('link_destination')
    if not dest then
        return false
    end
    return M.try_src(
        context,
        marks,
        dest.text,
        node.start_row,
        node.start_col,
        node.end_row,
        node.end_col
    )
end

---Render every <img> inside an HTML block or inline HTML tag.
---@param context render.md.request.Context
---@param marks render.md.Marks
---@param node render.md.Node
function M.try_html(context, marks, node)
    local config = context.config.image
    if not config or not config.enabled or config.html == false then
        return
    end
    if not kitty.is_supported() then
        return
    end
    local imgs = html.parse(node.text)
    if #imgs == 0 then
        return
    end

    local grids = {}
    local ready = 0
    for _, img in ipairs(imgs) do
        local node_id = table.concat({
            tostring(node.start_row),
            tostring(img.start),
            img.src,
            tostring(img.width or 0),
        }, '_')
        local err = state.errors[node_id]
        if err and err.src == img.src then
            goto continue
        end
        local active = state.active[node_id]
        if not active or active.src ~= img.src then
            state.request(img.src, context.buf, config, node_id, function()
                refresh(context)
            end, img.width)
        else
            ready = ready + 1
            local lines = kitty.build_virt_lines(active.id, active.rows, active.cols)
            for _, line in ipairs(lines) do
                grids[#grids + 1] = line
            end
        end
        ::continue::
    end

    if ready == 0 then
        return
    end

    marks:add(config, false, node.start_row, node.start_col, {
        conceal = '',
        end_row = node.end_row,
        end_col = math.max(node.end_col, node.start_col + 1),
    })
    local last = node.end_row
    if node.end_col == 0 and node.end_row > node.start_row then
        last = node.end_row - 1
    end
    local compat = require('fk_markdown.lib.compat')
    if compat.has_11 then
        for r = node.start_row + 1, last do
            marks:add(config, false, r, 0, { conceal_lines = '' })
        end
    end
    marks:add(config, false, node.start_row, 0, {
        virt_lines = grids,
        virt_lines_above = false,
    })
end

return M
