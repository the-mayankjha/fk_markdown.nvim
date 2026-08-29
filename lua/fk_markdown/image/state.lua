-- Markdown image state: resolve file/URL → PNG, transmit via Kitty placeholders.

local kitty = require('fk_markdown.latex.kitty')
local resolve = require('fk_markdown.image.resolve')

local M = {}

---@class fk_markdown.image.Active
---@field id integer
---@field path string
---@field src string
---@field cols integer
---@field rows integer

---@type table<string, fk_markdown.image.Active>
M.active = {}
---@type table<string, uv_timer_t>
M.timers = {}
---@type table<string, boolean>
M.pending = {}
---@type table<string, {src: string}>
M.errors = {}

---@param w integer
---@param h integer
---@param config render.md.image.Config
---@return integer, integer
local function text_width()
    local width = vim.o.columns
    local ok, win = pcall(vim.api.nvim_get_current_win)
    if ok then
        width = vim.api.nvim_win_get_width(win)
        local info = vim.fn.getwininfo(win)
        if info and info[1] and info[1].textoff then
            width = width - info[1].textoff
        end
    end
    return math.max(8, width - 2)
end

local function fit_cells(w, h, config)
    local cell_w, cell_h = kitty.get_cell_size()
    local cols = math.max(1, math.ceil(w / cell_w))
    local rows = math.max(1, math.ceil(h / cell_h))
    local cap = kitty.max_placeholder_dim()
    -- Keep native aspect; only shrink if the grid would wrap (wrap tiles the image).
    local max_cols = math.min(cap, text_width())
    if type(config.size) == 'number' then
        max_cols = math.min(max_cols, math.max(1, config.size))
    end
    if cols > max_cols then
        local scale = max_cols / cols
        cols = max_cols
        rows = math.max(1, math.floor(rows * scale + 0.5))
    end
    if type(config.size) == 'number' then
        local max_rows = config.max_height
        if type(max_rows) == 'number' and max_rows > 0 and rows > max_rows then
            local scale = max_rows / rows
            rows = max_rows
            cols = math.max(1, math.floor(cols * scale + 0.5))
        end
    end
    rows = math.min(rows, cap)
    return cols, rows
end

---@param src string
---@param buf integer
---@param config render.md.image.Config
---@param node_id string
---@param callback fun(img: fk_markdown.image.Active|nil)
function M.request(src, buf, config, node_id, callback)
    local existing = M.active[node_id]
    if existing and existing.src == src then
        M.errors[node_id] = nil
        vim.schedule(function()
            callback(existing)
        end)
        return
    end
    local err = M.errors[node_id]
    if err and err.src == src then
        vim.schedule(function()
            callback(nil)
        end)
        return
    end
    if M.pending[node_id] then
        return
    end
    if M.timers[node_id] then
        pcall(function()
            M.timers[node_id]:stop()
            M.timers[node_id]:close()
        end)
        M.timers[node_id] = nil
    end

    local uv = vim.uv or vim.loop
    local timer = uv.new_timer()
    M.timers[node_id] = timer
    M.pending[node_id] = true

    timer:start(config.update_interval or 100, 0, vim.schedule_wrap(function()
        M.timers[node_id] = nil
        resolve.to_png(src, buf, config.cache_dir, function(path)
            M.pending[node_id] = false
            if not path then
                M.errors[node_id] = { src = src }
                callback(nil)
                return
            end
            local w, h = kitty.get_png_dimensions(path)
            if w == 0 or h == 0 then
                M.errors[node_id] = { src = src }
                callback(nil)
                return
            end
            if not kitty.is_supported() then
                callback(nil)
                return
            end
            local cols, rows = fit_cells(w, h, config)
            if M.active[node_id] then
                kitty.delete_image(M.active[node_id].id)
                M.active[node_id] = nil
            end
            local id = kitty.transmit_image(path, rows, cols)
            M.errors[node_id] = nil
            M.active[node_id] = {
                id = id,
                path = path,
                src = src,
                cols = cols,
                rows = rows,
            }
            callback(M.active[node_id])
        end)
    end))
end

return M
