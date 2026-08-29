local server = require('fk_markdown.preview.server')
local state = require('fk_markdown.state')

local M = {}
M.servers = {} -- map of buf -> server instance

function M.start()
    local buf = vim.api.nvim_get_current_buf()
    if M.servers[buf] then
        vim.notify("fk_markdown: Preview already running for this buffer", vim.log.levels.INFO)
        return
    end

    local srv = server.new(buf)
    local ok, err = srv:start()
    if not ok then
        vim.notify("fk_markdown: Failed to start preview server: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    M.servers[buf] = srv
    srv:open_browser()
    vim.notify("fk_markdown: Preview started", vim.log.levels.INFO)
end

function M.stop()
    local buf = vim.api.nvim_get_current_buf()
    local srv = M.servers[buf]
    if not srv then
        vim.notify("fk_markdown: No preview running for this buffer", vim.log.levels.INFO)
        return
    end

    srv:stop()
    M.servers[buf] = nil
    vim.notify("fk_markdown: Preview stopped", vim.log.levels.INFO)
end

function M.toggle()
    local buf = vim.api.nvim_get_current_buf()
    if M.servers[buf] then
        M.stop()
    else
        M.start()
    end
end

return M
