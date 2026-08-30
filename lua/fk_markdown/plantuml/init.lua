local kitty = require('fk_markdown.latex.kitty')
local resolve = require('fk_markdown.plantuml.resolve')
local state = require('fk_markdown.plantuml.state')

local M = {}

---Check if a code block language is PlantUML
---@param lang? string
---@return boolean
function M.is_plantuml(lang)
    if not lang then
        return false
    end
    local l = lang:lower()
    return l == 'plantuml' or l == 'puml' or l == 'plant-uml' or l == 'plant_uml'
end

---Extract code block body text without fences
---@param node render.md.Node
---@return string
function M.extract_code(node)
    local buf = node.buf
    local all_lines = vim.api.nvim_buf_get_lines(buf, node.start_row, node.end_row, false)
    if #all_lines <= 2 then
        return ''
    end
    -- Remove first line (```plantuml)
    table.remove(all_lines, 1)
    -- Remove last line if delimiter (``` or ~~~)
    if #all_lines > 0 and (all_lines[#all_lines]:match('^%s*```') or all_lines[#all_lines]:match('^%s*~~~')) then
        table.remove(all_lines)
    end
    return table.concat(all_lines, '\n')
end

---Render PlantUML code block using Kitty protocol
---@param context render.md.request.Context
---@param marks render.md.Marks
---@param node render.md.Node
---@param lang string
---@return boolean handled
function M.render(context, marks, node, lang)
    local config = context.config.plant_uml
    if not config or not config.enabled then
        return false
    end

    if config.render_method ~= 'image' then
        return false
    end

    if not kitty.is_supported() then
        return false
    end

    local code = M.extract_code(node)
    if vim.trim(code) == '' then
        return false
    end

    local node_id = tostring(node.start_row) .. '_' .. tostring(node.start_col)
    local hash = resolve.hash(code, config.theme, config.styling)
    local active = state.active_diagrams[node_id]
    local err = state.errors[node_id]

    local mode = vim.fn.mode()
    local in_insert = mode == 'i' and config.hide_on_insert

    if in_insert then
        return false
    end

    local function refresh()
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

    local win_width = vim.fn.winwidth(context.win)
    local max_cols = math.max(20, win_width - 8)

    if err and err.puml == code then
        -- Error occurred while resolving diagram, let standard codeblock render
        return false
    elseif not active or active.puml_hash ~= hash then
        -- Request async render
        state.request_render(code, config, node_id, max_cols, function()
            refresh()
        end)
        return false
    else
        -- Draw Kitty image virtual lines and conceal all source lines
        local lines = kitty.build_virt_lines(active.id, active.rows, active.cols)
        
        -- Conceal first fence line
        local first_line = vim.api.nvim_buf_get_lines(
            context.buf,
            node.start_row,
            node.start_row + 1,
            false
        )[1] or ''

        marks:add(config, false, node.start_row, node.start_col, {
            conceal = '',
            end_row = node.start_row,
            end_col = math.max(#first_line, node.start_col + 1),
        })

        -- Insert the diagram image virtual lines under the first line
        marks:add(config, false, node.start_row, 0, {
            virt_lines = lines,
            virt_lines_above = false,
        })

        -- Conceal all remaining source lines of the code block
        local compat = require('fk_markdown.lib.compat')
        local last = node.end_row
        if node.end_col == 0 and node.end_row > node.start_row then
            last = node.end_row - 1
        end

        for r = node.start_row + 1, last do
            if compat.has_11 then
                marks:add(config, false, r, 0, { conceal_lines = '' })
            else
                local src_line = vim.api.nvim_buf_get_lines(context.buf, r, r + 1, false)[1] or ''
                local w = math.max(1, vim.fn.strdisplaywidth(src_line))
                marks:add(config, false, r, 0, {
                    virt_text = { { string.rep(' ', w), 'Normal' } },
                    virt_text_pos = 'overlay',
                    virt_text_hide = true,
                    conceal = '',
                    end_row = r,
                    end_col = math.max(#src_line, 1),
                })
            end
        end

        return true
    end
end

return M
