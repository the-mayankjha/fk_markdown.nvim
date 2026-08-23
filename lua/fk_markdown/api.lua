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

return M
