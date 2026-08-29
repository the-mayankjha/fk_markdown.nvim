-- LaTeX rendering state management for fk_markdown.nvim
-- Manages debounced render requests, active image tracking, and cleanup.

local backend = require('fk_markdown.latex.backend')
local kitty = require('fk_markdown.latex.kitty')

local M = {}

---@class fk_markdown.latex.ActiveImage
---@field id integer
---@field width integer
---@field height integer
---@field path string
---@field equation string
---@field cols integer
---@field rows integer

---@type table<string, fk_markdown.latex.ActiveImage>
M.active_images = {}

---@type table<string, uv_timer_t>
M.timers = {}

---@type table<string, boolean>
M.pending = {}

---@type table<string, {equation: string, reason: string}>
M.errors = {}

---Request an async render for an equation. Debounced by node_id.
---@param equation string
---@param config render.md.latex.Config
---@param node_id string
---@param min_cols integer
---@param callback fun(img: fk_markdown.latex.ActiveImage|nil)
function M.request_render(equation, config, node_id, min_cols, callback)
    local existing = M.active_images[node_id]
    if existing and existing.equation == equation then
        M.errors[node_id] = nil
        vim.schedule(function()
            callback(existing)
        end)
        return
    end

    local existing_err = M.errors[node_id]
    if existing_err and existing_err.equation == equation then
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
    min_cols = math.max(1, min_cols or 1)

    timer:start(config.update_interval or 400, 0, vim.schedule_wrap(function()
        M.timers[node_id] = nil

        backend.render(equation, config, function(path, reason)
            M.pending[node_id] = false
            if not path then
                if M.active_images[node_id] then
                    kitty.delete_image(M.active_images[node_id].id)
                    M.active_images[node_id] = nil
                end
                M.errors[node_id] = {
                    equation = equation,
                    reason = reason or 'invalid',
                }
                callback(nil)
                return
            end

            M.errors[node_id] = nil

            local w, h = kitty.get_png_dimensions(path)
            if w == 0 or h == 0 then
                M.errors[node_id] = { equation = equation, reason = 'invalid' }
                callback(nil)
                return
            end

            if not kitty.is_supported() then
                callback(nil)
                return
            end

            local cell_w, cell_h = kitty.get_cell_size()
            local img_cols = math.max(min_cols, math.ceil(w / cell_w))
            local img_rows = math.max(1, math.ceil(h / cell_h))
            img_cols = math.min(img_cols, math.max(min_cols, vim.o.columns - 4))
            img_rows = math.min(img_rows, math.max(1, vim.o.lines - 4))

            if M.active_images[node_id] then
                kitty.delete_image(M.active_images[node_id].id)
                M.active_images[node_id] = nil
            end

            local id = kitty.transmit_image(path, img_rows, img_cols)
            if not id then
                callback(nil)
                return
            end

            M.active_images[node_id] = {
                id = id,
                width = w,
                height = h,
                path = path,
                equation = equation,
                cols = img_cols,
                rows = img_rows,
            }
            callback(M.active_images[node_id])
        end)
    end))
end

---Clear a specific node's image.
---@param node_id string
function M.clear(node_id)
    if M.timers[node_id] then
        pcall(function()
            M.timers[node_id]:stop()
            M.timers[node_id]:close()
        end)
        M.timers[node_id] = nil
    end
    M.pending[node_id] = nil
    M.errors[node_id] = nil

    if M.active_images[node_id] then
        kitty.delete_image(M.active_images[node_id].id)
        M.active_images[node_id] = nil
    end
end

---Clear ALL images.
function M.clear_all()
    local ids = {}
    for node_id, _ in pairs(M.active_images) do
        ids[#ids + 1] = node_id
    end
    for node_id, _ in pairs(M.errors) do
        ids[#ids + 1] = node_id
    end
    for _, node_id in ipairs(ids) do
        M.clear(node_id)
    end
    kitty.delete_all()
end

return M
