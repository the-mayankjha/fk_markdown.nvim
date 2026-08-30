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
---When multiple small images (badges) appear in the same container, they are
---laid out horizontally on the same virtual-line row, wrapping when the total
---width would exceed the terminal window — just like GitHub renders badges.
---@param context render.md.request.Context
---@param marks render.md.Marks
---@param node render.md.Node
function M.try_html(context, marks, node)
    local config = context.config.image
    if not config or not config.enabled then
        return
    end
    local html_config = config.html
    -- Support both old boolean config and new table config
    if type(html_config) == 'boolean' then
        if not html_config then
            return
        end
        html_config = { image_rendering = true, properties = true }
    elseif type(html_config) == 'table' then
        if html_config.image_rendering == false then
            return
        end
    end
    if not kitty.is_supported() then
        return
    end
    local imgs = html.parse(node.text)
    if #imgs == 0 then
        return
    end

    local honor_props = html_config and html_config.properties ~= false

    -- Collect ready image info
    ---@class fk_markdown.image.ReadyImg
    ---@field active fk_markdown.image.Active
    ---@field align string|nil
    local ready_imgs = {}
    local all_ready = true
    local img_align = nil

    for _, img in ipairs(imgs) do
        local w_px = honor_props and img.width or nil
        local h_px = honor_props and img.height or nil
        if honor_props and img.align then
            img_align = img.align
        end
        local node_id = table.concat({
            tostring(node.start_row),
            tostring(img.start),
            img.src,
            tostring(w_px or 0),
            tostring(h_px or 0),
        }, '_')
        local err = state.errors[node_id]
        if err and err.src == img.src then
            goto continue
        end
        local active = state.active[node_id]
        if not active or active.src ~= img.src then
            state.request(img.src, context.buf, config, node_id, function()
                refresh(context)
            end, w_px, h_px)
            all_ready = false
        else
            ready_imgs[#ready_imgs + 1] = {
                active = active,
                align = img.align,
            }
        end
        ::continue::
    end

    if #ready_imgs == 0 then
        return
    end

    -- Compute available window width
    local win_width = vim.o.columns
    local ok, win = pcall(vim.api.nvim_get_current_win)
    if ok then
        win_width = vim.api.nvim_win_get_width(win)
        local info = vim.fn.getwininfo(win)
        if info and info[1] and info[1].textoff then
            win_width = win_width - info[1].textoff
        end
    end
    win_width = math.max(8, win_width - 2)

    -- Determine if we should use inline (horizontal) layout.
    -- Badge images are small (typically 1-3 rows tall). If ALL ready images
    -- are short, lay them out horizontally; otherwise stack vertically.
    local BADGE_MAX_ROWS = 4
    local GAP_COLS = 1
    local is_inline = #ready_imgs > 1
    if is_inline then
        for _, ri in ipairs(ready_imgs) do
            if ri.active.rows > BADGE_MAX_ROWS then
                is_inline = false
                break
            end
        end
    end

    local grids = {}
    local total_cols = 0

    if is_inline then
        -- Horizontal badge layout with wrapping
        -- Group images into rows that fit within win_width
        local rows_of_imgs = { {} }
        local current_row_width = 0

        for _, ri in ipairs(ready_imgs) do
            local needed = ri.active.cols
            if current_row_width > 0 then
                needed = needed + GAP_COLS
            end
            if current_row_width + needed > win_width and current_row_width > 0 then
                -- Wrap to new row
                rows_of_imgs[#rows_of_imgs + 1] = { ri }
                current_row_width = ri.active.cols
            else
                rows_of_imgs[#rows_of_imgs][#rows_of_imgs[#rows_of_imgs] + 1] = ri
                current_row_width = current_row_width + needed
            end
        end

        -- Build virtual lines for each row of badges
        for _, row_imgs in ipairs(rows_of_imgs) do
            -- Find max height (rows) in this badge row
            local max_rows = 0
            local row_total_cols = 0
            for idx, ri in ipairs(row_imgs) do
                if ri.active.rows > max_rows then
                    max_rows = ri.active.rows
                end
                row_total_cols = row_total_cols + ri.active.cols
                if idx > 1 then
                    row_total_cols = row_total_cols + GAP_COLS
                end
            end

            -- Build combined virtual lines for this badge row
            for r = 1, max_rows do
                local line = {}
                for idx, ri in ipairs(row_imgs) do
                    if idx > 1 then
                        -- Gap between badges
                        line[#line + 1] = { string.rep(' ', GAP_COLS), '' }
                    end
                    if r <= ri.active.rows then
                        -- This image has content at this row
                        local hl = kitty.get_highlight(ri.active.id)
                        line[#line + 1] = { kitty.build_placeholder_row(r, ri.active.cols), hl }
                    else
                        -- Pad shorter images with spaces
                        line[#line + 1] = { string.rep(' ', ri.active.cols), '' }
                    end
                end
                grids[#grids + 1] = line
            end

            total_cols = math.max(total_cols, row_total_cols)
        end
    else
        -- Vertical stacking (single large image or single badge)
        for _, ri in ipairs(ready_imgs) do
            total_cols = math.max(total_cols, ri.active.cols)
            local lines = kitty.build_virt_lines(ri.active.id, ri.active.rows, ri.active.cols)
            for _, line in ipairs(lines) do
                grids[#grids + 1] = line
            end
        end
    end

    -- Apply alignment padding to virtual lines
    if honor_props and img_align and total_cols > 0 then
        local pad = 0
        if img_align == 'center' then
            pad = math.max(0, math.floor((win_width - total_cols) / 2))
        elseif img_align == 'right' then
            pad = math.max(0, win_width - total_cols)
        end
        if pad > 0 then
            local pad_str = string.rep(' ', pad)
            for i, line in ipairs(grids) do
                grids[i] = vim.list_extend({ { pad_str, '' } }, line)
            end
        end
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
