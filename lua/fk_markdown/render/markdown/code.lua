local Base = require('fk_markdown.render.base')
local colors = require('fk_markdown.core.colors')
local env = require('fk_markdown.lib.env')
local icons = require('fk_markdown.lib.icons')
local str = require('fk_markdown.lib.str')

---@class render.md.code.Data
---@field info? render.md.Node
---@field language? render.md.Node
---@field language_padding integer
---@field padding integer
---@field body integer
---@field margin integer

---@class render.md.render.Code: render.md.Render
---@field private config render.md.code.Config
---@field private data render.md.code.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.code
    if not self.config.enabled then
        return false
    end
    -- skip single line code block
    if self.node:height() <= 2 then
        return false
    end

    local info = self.node:child('info_string')
    local language = info and info:child('language')

    local widths = self.node:widths()
    local width = vim.fn.max(widths)

    local language_padding = self:offset(self.config.language_pad, width)
    local left = self:offset(self.config.left_pad, width)
    local right = self:offset(self.config.right_pad, width)

    local body = str.width(self.config.language_left)
        + str.width(self.config.language_right)
        + language_padding
        + widths[1]
    body = math.max(body, left + width + right, self.config.min_width)

    self.data = {
        info = info,
        language = language,
        language_padding = language_padding,
        padding = left,
        body = body,
        margin = self:offset(self.config.left_margin, body),
    }

    return self:enabled(self.config.disable)
end

---@private
---@param value integer
---@param used integer
---@return integer
function Render:offset(value, used)
    if value <= 0 then
        return 0
    end
    local result = env.win.percent(self.context.win, value, used)
    if self.node.text:find('\t') then
        -- round to the next multiple of tab
        local tab = env.buf.get(self.context.buf, 'tabstop')
        result = math.ceil(result / tab) * tab
    end
    return result
end

---@private
---@param disable boolean|string[]
---@return boolean
function Render:enabled(disable)
    if type(disable) == 'boolean' then
        return not disable
    else
        local language = self.data.language
        return not language or not vim.tbl_contains(disable, language.text)
    end
end

---@protected
function Render:run()
    local start_row = self.node.start_row
    local end_row = self.node.end_row - 1

    local above = self.node:child('fenced_code_block_delimiter', start_row)
    local below = self.node:child('fenced_code_block_delimiter', end_row)

    if self.config.conceal_delimiters then
        self.marks:over(self.config, true, self.data.info, { conceal = '' })
        self.marks:over(self.config, true, above, { conceal = '' })
        self.marks:over(self.config, true, below, { conceal = '' })
    end

    -- Fetch dynamic language highlight for the borders
    local icons = require('fk_markdown.lib.icons')
    local language = self.data.language
    local dyn_hl = self.config.highlight_border
    if self.config.fk_border_hl then
        dyn_hl = self.config.fk_border_hl
    elseif language then
        local _, icon_hl = icons.get(language.text)
        if icon_hl then
            dyn_hl = icon_hl
        end
    end

    if not self:language(above) then
        self:border(above, self.config.above, true, dyn_hl)
    else
        -- If language overlay was drawn, we STILL need to draw the top border
        -- BEHIND it so the rest of the line has ╭───────╮
        self:border(above, self.config.above, true, dyn_hl)
    end
    self:border(below, self.config.below, false, dyn_hl)

    local background = self:enabled(self.config.disable_background)
    if background then
        local inset = self.config.background_inset
        self:background(start_row + inset, end_row - inset)
    end
    self:padding(background)
    
    -- Draw left and right vertical borders for the code content rows!
    if self.config.border ~= 'none' then
        local highlight = dyn_hl
        if highlight then
            local textoff = 0
            local wininfo = vim.fn.getwininfo(self.context.win)
            if wininfo and wininfo[1] then
                textoff = wininfo[1].textoff or 0
            end
            local text_width = vim.fn.winwidth(self.context.win) - textoff
            local block = self.config.width == 'block'
            local right_col = block and (self.data.body - 1 + (self.config.fk_right_pad or 0)) or (text_width - 1)
            local left_col = block and node.start_col or 0
            
            for row = start_row + 1, end_row - 1 do
                -- Left border │
                self.marks:add(self.config, 'code_border', row, 0, {
                    virt_text = { { '│', highlight } },
                    virt_text_win_col = left_col,
                    priority = 200,
                })
                -- Right border │
                self.marks:add(self.config, 'code_border', row, 0, {
                    virt_text = { { '│', highlight } },
                    virt_text_win_col = right_col,
                    priority = 200,
                })
            end
            
            -- Implement top and bottom padding via virt_lines
            local top_pad = self.config.fk_top_pad or 0
            local bot_pad = self.config.fk_bottom_pad or 0
            if top_pad > 0 or bot_pad > 0 then
                local inner_width = right_col - left_col - 1
                if inner_width > 0 then
                    local bg_hl = self:enabled(self.config.disable_background) and self.config.highlight or nil
                    local vline = {}
                    if left_col > 0 then
                        table.insert(vline, { string.rep(' ', left_col), 'Normal' })
                    end
                    table.insert(vline, { '│', highlight })
                    table.insert(vline, { string.rep(' ', inner_width), bg_hl or 'Normal' })
                    table.insert(vline, { '│', highlight })
                    
                    if top_pad > 0 then
                        local top_lines = {}
                        for i = 1, top_pad do table.insert(top_lines, vline) end
                        self.marks:add(self.config, 'code_border', start_row, 0, {
                            virt_lines = top_lines,
                            virt_lines_above = false,
                            priority = 200,
                        })
                    end
                    if bot_pad > 0 then
                        local bot_lines = {}
                        for i = 1, bot_pad do table.insert(bot_lines, vline) end
                        self.marks:add(self.config, 'code_border', end_row, 0, {
                            virt_lines = bot_lines,
                            virt_lines_above = true,
                            priority = 200,
                        })
                    end
                end
            end
        end
    end
end

---@private
---@param delim? render.md.Node
---@return boolean
function Render:language(delim)
    if not self.config.language then
        return false
    end

    local info = self.data.info
    local language = self.data.language
    local padding = self.data.language_padding
    if not info or not language or not delim then
        return false
    end

    local icon, icon_hl = icons.get(language.text)
    if self.config.highlight_language then
        icon_hl = self.config.highlight_language
    end
    self:sign(self.config, self.config.sign, icon, icon_hl)

    local icon_hl_list = { icon_hl or self.config.highlight_fallback } ---@type string[]
    local text_hl_list = { self.config.fk_text_hl or icon_hl or self.config.highlight_fallback } ---@type string[]
    
    local info_hl = { self.config.highlight_info } ---@type string[]
    local border_hl = self.config.highlight_border or nil
    if border_hl then
        -- We removed appending border_hl to icon_hl/text_hl so DevIcon colors aren't overridden
        border_hl = colors.bg_as_fg(border_hl)
    end

    local text = self:line()
    if self.config.language_icon and icon then
        text:text(icon .. ' ', icon_hl_list)
    end
    if self.config.language_name then
        text:text(language.text, text_hl_list)
    end
    if self.config.language_info then
        local offset = info.start_col
        text = self:line()
            :text(info.text:sub(1, language.start_col - offset), info_hl)
            :extend(text)
            :text(info.text:sub(language.end_col - offset + 1), info_hl)
    end
    if text:empty() then
        return false
    end

    local body = self:line()
        :text(self.config.language_left, border_hl)
        :extend(text)
        :text(self.config.language_right, border_hl)

    -- code blocks can pick up varying amounts of leading white space
    -- this is lumped into the delimiter node and needs to be handled
    local prefix = str.spaces('start', delim.text)
    local suffix = 0
    -- space within block after accounting for white space and padding
    local width = self.data.body - delim.start_col
    local extra = width - prefix - body:width() - suffix - padding ---@type integer
    if self.config.position == 'left' then
        prefix = prefix + padding
        suffix = suffix + extra
    elseif self.config.position == 'right' then
        prefix = prefix + extra
        suffix = suffix + padding
    else
        prefix = prefix + padding + math.floor(extra / 2)
        suffix = suffix + math.ceil(extra / 2)
    end
    if self.config.width == 'full' then
        suffix = suffix + vim.o.columns
    end

    local border = border_hl and self.config.language_border or ' '
    
    -- If using our custom boxy renderer, we don't want to overwrite the ╭──────╮
    -- border line with empty spaces. We just draw the language title exactly where it belongs.
    local line = self:line()
    local win_col = 0
    if border == ' ' then
        -- Don't draw prefix spaces (which would overwrite the border), just use win_col
        line:extend(body)
        win_col = prefix
    else
        line:rep(border, prefix, border_hl)
            :extend(body)
            :rep(border, suffix, border_hl)
    end
    
    local opts = {
        virt_text = line:get(),
        virt_text_pos = 'overlay',
        priority = 150,
    }
    if win_col > 0 then
        opts.virt_text_win_col = win_col
    end

    return self.marks:start(self.config, 'code_language', delim, opts)
end

---@private
---@param node? render.md.Node
---@param thin string
---@param is_top boolean
---@param dyn_hl string?
function Render:border(node, thin, is_top, dyn_hl)
    local kind = self.config.border
    if kind == 'none' or not node then
        return
    end
    if kind == 'hide' then
        self.marks:over(self.config, true, node, { conceal_lines = '' })
        return
    end

    local highlight = dyn_hl or self.config.highlight_border or nil
    if not highlight then
        return
    end
    local icon = '─'
    
    local textoff = 0
    local wininfo = vim.fn.getwininfo(self.context.win)
    if wininfo and wininfo[1] then
        textoff = wininfo[1].textoff or 0
    end
    local win_width = vim.fn.winwidth(self.context.win)
    local text_width = win_width - textoff
    
    local block = self.config.width == 'block'
    local width = block and (self.data.body - node.start_col + (self.config.fk_right_pad or 0)) or text_width
    local inner = math.max(width - 2, 4)

    local left_corner  = is_top and '╭' or '╰'
    local right_corner = is_top and '╮' or '╯'
    
    -- Draw the rounded border line. Add a massive trailing pad so if 
    -- hl_eol is true for the content, the border's background extends fully too.
    local line_str = left_corner .. string.rep(icon, inner) .. right_corner .. string.rep(' ', 100)

    self.marks:start(self.config, 'code_border', node, {
        virt_text = { { line_str, highlight } },
        virt_text_pos = 'overlay',
        priority = 100,
    })
end

---@private
---@param start_row integer
---@param end_row integer
function Render:background(start_row, end_row)
    local padding = self:line()
    local win_col = 0
    if self.config.width == 'block' then
        padding:pad(vim.o.columns * 2)
        win_col = self.data.margin + self.data.body + self:indent():size() + (self.config.fk_right_pad or 0)
    end
    local col = self.node.start_col
    for row = start_row, end_row do
        self.marks:add(self.config, 'code_background', row, col, {
            end_row = row + 1,
            priority = self.config.priority,
            hl_group = self.config.highlight,
            hl_eol = true,
        })
        if not padding:empty() and win_col > 0 then
            -- overwrite anything beyond width with padding
            self.marks:add(self.config, 'code_background', row, col, {
                priority = 0,
                virt_text = padding:get(),
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param background boolean
function Render:padding(background)
    local col = self.node.start_col
    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    local empty = {} ---@type integer[]
    local widths = col == 0 and {} or self.node:widths()
    for i, width in ipairs(widths) do
        if width == 0 then
            empty[#empty + 1] = (start_row + i - 1)
        end
    end
    if #empty == 0 and self.data.margin <= 0 and self.data.padding <= 0 then
        return
    end
    local highlight = background and self.config.highlight or nil
    for row = start_row, end_row do
        local line = self:line()
        if vim.tbl_contains(empty, row) then
            line:pad(col)
        end
        line:pad(self.data.margin)
        if row > start_row and row < end_row then
            line:pad(self.data.padding, highlight)
        end
        if not line:empty() then
            self.marks:add(self.config, false, row, col, {
                priority = 100,
                virt_text = line:get(),
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
