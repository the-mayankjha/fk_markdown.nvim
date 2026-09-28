---@class render.md.render.Context
---@field buf integer
---@field win? integer|integer[]
---@field event? string
---@field config? render.md.partial.UserConfig

---@class render.md.Api
local M = {}

---@param ctx render.md.render.Context
function M.render(ctx)
    local env = require('fk_markdown.lib.env')
    local list = require('fk_markdown.lib.list')
    local state = require('fk_markdown.state')
    local ui = require('fk_markdown.core.ui')

    local buf = ctx.buf
    local wins = list.ensure(ctx.win or env.buf.wins(buf))
    local event = ctx.event or 'Api'

    state.get(buf, ctx.config)
    state.attach()

    for _, win in ipairs(wins) do
        ui.update(buf, win, event, true)
    end
end

---@return boolean
function M.get()
    return require('fk_markdown.state').enabled
end

---@param enable? boolean
function M.set(enable)
    require('fk_markdown.core.manager').set(enable)
end

---@param enable? boolean
function M.set_buf(enable)
    require('fk_markdown.core.manager').set_buf(nil, enable)
end

function M.enable()
    M.set(true)
end

function M.buf_enable()
    M.set_buf(true)
end

function M.disable()
    M.set(false)
end

function M.buf_disable()
    M.set_buf(false)
end

function M.toggle()
    M.set()
end

function M.buf_toggle()
    M.set_buf()
end

function M.preview()
    require('fk_markdown.core.preview').open()
end

function M.log()
    require('fk_markdown.core.log').open()
end

function M.expand()
    require('fk_markdown.state').modify_anti_conceal(1)
    M.enable()
end

function M.contract()
    require('fk_markdown.state').modify_anti_conceal(-1)
    M.enable()
end

function M.debug()
    require('fk_markdown.debug.marks').show()
end

function M.config()
    local difference = require('fk_markdown.state').difference()
    if not difference then
        -- selene: allow(deprecated)
        vim.print('default configuration')
    else
        -- selene: allow(deprecated)
        vim.print(difference)
    end
end

---Follow or open the link under cursor
function M.follow_link()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local line_idx = cursor[1] - 1
    local col_idx = cursor[2]
    local line_text = vim.api.nvim_buf_get_lines(buf, line_idx, line_idx + 1, false)[1] or ''

    local url = nil

    -- 1. Try treesitter node under cursor
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if ok and parser then
        local node = vim.treesitter.get_node({ buf = buf, pos = { line_idx, col_idx } })
        while node do
            local ntype = node:type()
            if ntype == 'inline_link' or ntype == 'uri_autolink' or ntype == 'link_destination' then
                local dest_node = node:child_by_field_name('destination') or (ntype == 'link_destination' and node)
                if dest_node then
                    local text = vim.treesitter.get_node_text(dest_node, buf)
                    url = text:gsub('^<', ''):gsub('>$', '')
                    break
                else
                    local ntext = vim.treesitter.get_node_text(node, buf)
                    url = ntext:match('%((https?://[^%s%)]+)%)') or ntext:match('%(([^%s%)]+)%)')
                    if url then break end
                end
            end
            node = node:parent()
        end
    end

    -- 2. Fallback: regex search on cursor line
    if not url or url == '' then
        for u in line_text:gmatch('%((https?://[^%s%)]+)%)') do
            url = u
            break
        end
        if not url then
            for u in line_text:gmatch('(https?://[%w_.~!*\'();:@&=+$,/?%%#%-[#%]]+)') do
                url = u
                break
            end
        end
    end

    if url and url ~= '' then
        url = vim.trim(url)
        vim.notify('FkMarkdown: Opening ' .. url, vim.log.levels.INFO)
        if vim.ui and vim.ui.open then
            vim.ui.open(url)
        else
            local sys = vim.loop.os_uname().sysname
            local open_cmd = sys == 'Darwin' and 'open' or (sys == 'Windows_NT' and 'start' or 'xdg-open')
            vim.fn.jobstart({ open_cmd, url }, { detach = true })
        end
    else
        vim.notify('FkMarkdown: No link found under cursor', vim.log.levels.WARN)
    end
end

return M
