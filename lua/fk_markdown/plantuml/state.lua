local kitty = require('fk_markdown.latex.kitty')
local resolve = require('fk_markdown.plantuml.resolve')

local M = {}

---@class render.md.plantuml.Active
---@field id integer
---@field path string
---@field puml_hash string
---@field rows integer
---@field cols integer
---@field px_w integer
---@field px_h integer

---Active Kitty image placements keyed by node_id (e.g. "start_row_start_col")
---@type table<string, render.md.plantuml.Active>
M.active_diagrams = {}

---Errors keyed by node_id
---@type table<string, { puml: string, message: string }>
M.errors = {}

---Track in-flight network requests by puml_hash
---@type table<string, boolean>
M.in_flight = {}

---Clear all active PlantUML images
function M.clear_all()
    for _, active in pairs(M.active_diagrams) do
        pcall(kitty.delete_image, active.id)
    end
    M.active_diagrams = {}
    M.errors = {}
    M.in_flight = {}
end

---Request resolution and Kitty transmission of a PlantUML diagram
---@param text string
---@param config table
---@param node_id string
---@param max_cols integer
---@param on_ready fun()
function M.request_render(text, config, node_id, max_cols, on_ready)
    local hash = resolve.hash(text, config.theme, config.styling)

    if M.in_flight[hash] then
        return
    end

    M.in_flight[hash] = true

    resolve.resolve(text, config, function(path, err)
        M.in_flight[hash] = nil
        if not path or err then
            M.errors[node_id] = {
                puml = text,
                message = err or 'Diagram rendering failed',
            }
            on_ready()
            return
        end

        local px_w, px_h = kitty.get_png_dimensions(path)
        if px_w <= 0 or px_h <= 0 then
            M.errors[node_id] = {
                puml = text,
                message = 'Invalid PNG dimensions',
            }
            on_ready()
            return
        end

        local cell_w, cell_h = kitty.get_cell_size()
        local cols = math.max(1, math.ceil(px_w / cell_w))
        local rows = math.max(1, math.ceil(px_h / cell_h))

        local max_dim = kitty.max_placeholder_dim()
        cols = math.min(cols, max_dim, max_cols or 120)
        rows = math.min(rows, max_dim)

        -- If replacing an existing image with different id, delete old one
        local old = M.active_diagrams[node_id]
        if old and old.id then
            pcall(kitty.delete_image, old.id)
        end

        local img_id = kitty.transmit_image(path, rows, cols)

        M.errors[node_id] = nil
        M.active_diagrams[node_id] = {
            id = img_id,
            path = path,
            puml_hash = hash,
            rows = rows,
            cols = cols,
            px_w = px_w,
            px_h = px_h,
        }

        on_ready()
    end)
end

return M
