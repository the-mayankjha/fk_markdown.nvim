local Base = require('fk_markdown.render.base')
local colors = require('fk_markdown.core.colors')
local list = require('fk_markdown.lib.list')
local str = require('fk_markdown.lib.str')
local ts = require('fk_markdown.core.ts')

---@class render.md.quote.Data
---@field callout? render.md.request.callout.Value
---@field level integer
---@field icon string
---@field highlight string
---@field repeat_linebreak? boolean

---@class render.md.render.Quote: render.md.Render
---@field private config render.md.quote.Config
---@field private data render.md.quote.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.quote
    if not self.config.enabled then
        return false
    end
    local level = self.node:level_in('block_quote')
    local callout = self.context.callout:get(self.node)
    local config = callout and callout.config
    local icon = config and config.quote_icon or self.config.icon
    local highlight = config and config.highlight or self.config.highlight
    self.data = {
        callout = callout,
        level = level,
        icon = assert(list.cycle(icon, level)),
        highlight = assert(list.cycle(highlight, level)),
        repeat_linebreak = self.config.repeat_linebreak or nil,
    }
    return true
end

---@protected
function Render:run()
    local style = self.config.style or 'compact'
    if style == 'boxy' then
        self:boxy_run()
    else
        self:callout()
        self:markers()
    end
end

--- ─────────────────────────────────────────────
---  COMPACT (default) style
--- ─────────────────────────────────────────────

---@private
function Render:callout()
    local callout = self.data.callout
    if not callout then return end
    local node = callout.node
    local config = callout.config
    local title = Render.title(node, config)
    self.marks:over(self.config, 'callout', node, {
        virt_text = { { title or config.rendered, config.highlight } },
        virt_text_pos = 'overlay',
        conceal = title and '' or nil,
    })
end

---@private
function Render:markers()
    local query = ts.parse('markdown', [[
        (block_quote_marker) @marker
        (block_continuation) @continuation
    ]])
    self.context.view:nodes(self.node:get(), query, function(capture, node)
        if capture == 'marker' then
            if node:level_in('block_quote') == self.data.level then
                self:marker(node, 1)
            end
        elseif capture == 'continuation' then
            self:marker(node, self.data.level)
        else
            error(('unhandled quote capture: %s'):format(capture))
        end
    end)
end

---@private
---@param node render.md.Node
---@param index integer
function Render:marker(node, index)
    local range = node:find('>')[index]
    if not range then return end
    self.marks:add(self.config, 'quote', range[1], range[2], {
        end_row = range[3],
        end_col = range[4],
        virt_text = { { self.data.icon, self.data.highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = self.data.repeat_linebreak,
    })
end

--- ─────────────────────────────────────────────
---  Helpers
--- ─────────────────────────────────────────────

-- Resolve a hex string or highlight group name to a hex color string.
-- Falls back to the plugin's own colors.get_hl() which properly
-- de-references linked highlight chains.
---@param val string|nil
---@param is_bg boolean
---@return string|nil
local function resolve_color(val, is_bg)
    if not val or val == 'NONE' or val == '' then return nil end
    if type(val) == 'string' and val:sub(1, 1) == '#' then return val end
    -- Use the plugin's battle-tested HL resolver
    local hl = colors.get_hl(val)
    local n = is_bg and hl.bg or hl.fg
    return n and string.format('#%06x', n) or nil
end

-- Get the fg colour of a highlight group, following link chains.
---@param name string
---@return string|nil
local function get_fg(name)
    return resolve_color(name, false)
end

--- ─────────────────────────────────────────────
---  BOXY style — Notion-like bordered container
--- ─────────────────────────────────────────────

---@private
function Render:boxy_run()
    local cfg = self.config
    local callout = self.data.callout
    local callout_cfg = callout and callout.config

    -- Per-callout accent highlight group (RenderMarkdownInfo, RenderMarkdownWarn…)
    local accent_hl = (callout_cfg and callout_cfg.highlight) or self.data.highlight

    -- Resolve the actual hex fg from that group (follows link chains)
    local accent_fg = get_fg(accent_hl)

    -- Body text: user-configured fg, else Normal fg (white from theme)
    local body_fg = resolve_color(cfg.fg, false) or get_fg('Normal')

    -- Background for the whole block
    local user_bg  = resolve_color(cfg.bg, true)
    local border_on = cfg.border ~= false  -- default true

    -- ── Auto highlight groups (unique per callout accent) ─────────
    local hl_key     = 'FkMdBoxy_' .. accent_hl
    local hl_bg_key  = hl_key .. '_Bg'   -- body rows
    local hl_bar_key = hl_key .. '_Bar'  -- ▌ left bar
    local hl_brd_key = hl_key .. '_Brd'  -- ╭──╮ border

    vim.api.nvim_set_hl(0, hl_bg_key, { fg = body_fg, bg = user_bg })
    vim.api.nvim_set_hl(0, hl_bar_key, { fg = accent_fg, bg = user_bg, bold = true })
    vim.api.nvim_set_hl(0, hl_brd_key, { fg = accent_fg, bg = user_bg })

    -- ── Geometry ──────────────────────────────────────────────────
    local start_row = self.node.start_row
    local end_row   = self.node.end_row - 1
    local start_col = self.node.start_col
    local win_width = vim.fn.winwidth(self.context.win)

    -- ── 1. Background fill on every real line ─────────────────────
    -- priority 150 = above treesitter (@markup.quote at ~100) so body
    -- text gets Normal fg (white) instead of the treesitter accent color
    for row = start_row, end_row do
        self.marks:add(self.config, 'quote', row, start_col, {
            end_row  = row + 1,
            hl_group = hl_bg_key,
            hl_eol   = true,
            priority = 150,
        })
    end

    -- ── 2. Rounded box borders (Top, Bottom, and Right) ──────────
    if border_on then
        local textoff = 0
        local wininfo = vim.fn.getwininfo(self.context.win)
        if wininfo and wininfo[1] then
            textoff = wininfo[1].textoff or 0
        end
        
        -- Calculate exact right edge to align ╮, │, and ╯
        local text_width = win_width - textoff
        local right_col  = math.max(text_width - 1, 10)
        local inner      = math.max(right_col - 1, 4)

        -- Trailing spaces ensure virt_lines bg extends to window edge (like hl_eol)
        local trailing   = string.rep(' ', 100)
        local top_str    = '╭' .. string.rep('─', inner) .. '╮' .. trailing
        local bot_str    = '╰' .. string.rep('─', inner) .. '╯' .. trailing

        self.marks:add(self.config, 'quote', start_row, start_col, {
            virt_lines       = { { { top_str, hl_brd_key } } },
            virt_lines_above = true,
            priority         = 100,
        })

        self.marks:add(self.config, 'quote', end_row, start_col, {
            virt_lines = { { { bot_str, hl_brd_key } } },
            priority   = 100,
        })

        -- RIGHT BORDER: draw '│' on every content row at the exact same column 
        -- so the top and bottom corners are visually connected!
        for row = start_row, end_row do
            self.marks:add(self.config, 'quote', row, start_col, {
                virt_text         = { { '│', hl_brd_key } },
                virt_text_win_col = right_col,
                priority          = 200,
            })
        end
    end

    -- ── 3. Left accent bar — three selectable modes ───────────────
    -- 'thick'  (img 2): █▌  — solid block + half block = gradient bar
    -- 'line'   (img 3): ▋   — single seven-eighths block (default)
    -- 'corner' (img 4): no continuous bar; box corners only from virt_lines
    local accent_mode = cfg.accent or 'line'

    for row = start_row, end_row do
        local bar_vt
        if accent_mode == 'thick' then
            -- Two-char gradient: full block → half block → space
            bar_vt = { { '█', hl_bar_key }, { '▌', hl_bar_key } }
        elseif accent_mode == 'corner' then
            -- No visible bar on content rows — just replace '> ' with spaces
            -- The box corners (╭/╰) from virt_lines are the only accent
            bar_vt = { { '  ', hl_bg_key } }
        else
            -- 'line' (default): single thick bar character
            bar_vt = { { '▋ ', hl_bar_key } }
        end

        self.marks:add(self.config, 'quote', row, start_col, {
            end_row       = row,
            end_col       = start_col + 2,
            virt_text     = bar_vt,
            virt_text_pos = 'overlay',
            priority      = 200,
        })
    end

    -- ── 4. Callout title overlay ──────────────────────────────────
    if callout then
        local node   = callout.node
        local config = callout_cfg
        local title  = Render.title(node, config)
        self.marks:over(self.config, 'callout', node, {
            virt_text     = { { title or config.rendered, accent_hl } },
            virt_text_pos = 'overlay',
            conceal       = title and '' or nil,
            priority      = 150,
        })
    end
end

--- ─────────────────────────────────────────────
---  Shared helper
--- ─────────────────────────────────────────────

---@private
---@param node render.md.Node
---@param config render.md.callout.Config
---@return string?
function Render.title(node, config)
    local content = node:parent('inline')
    if content then
        local line = str.split(content.text, '\n', true)[1]
        local prefix = config.raw:lower()
        if #line > #prefix and vim.startswith(line:lower(), prefix) then
            local icon  = str.split(config.rendered, ' ', true)[1]
            local title = vim.trim(line:sub(#prefix + 1))
            return icon .. ' ' .. title
        end
    end
    return nil
end

return Render
