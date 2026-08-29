local Context = require('fk_markdown.request.context')
local Indent = require('fk_markdown.lib.indent')
local Marks = require('fk_markdown.lib.marks')
local Node = require('fk_markdown.lib.node')
local env = require('fk_markdown.lib.env')
local iter = require('fk_markdown.lib.iter')
local log = require('fk_markdown.core.log')
local str = require('fk_markdown.lib.str')

---@class render.md.handler.buf.Latex
---@field private context render.md.request.Context
---@field private marks render.md.Marks
---@field private config render.md.latex.Config
local Handler = {}
Handler.__index = Handler

---@private
---@type table<string, string>
Handler.cache = {}

---@param buf integer
---@return render.md.handler.buf.Latex
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.context = Context.get(buf)
    self.marks = Marks.new(self.context, true)
    self.config = self.context.config.latex
    return self
end

---@param root TSNode
---@param last boolean
---@return render.md.Mark[]

function Handler:run(root, last)
    if not self.config.enabled then
        return {}
    end

    local node = Node.new(self.context.buf, root)
    local count = str.chars(node.text, '$')
    local include = (count <= 1 and self.config.inline)
        or (count >= 2 and self.config.block)
    if include then
        log.node('latex', node)
        self.context.latex:add(node)
    end

    if last then
        local nodes = self.context.latex:get()
        local use_image = false

        if self.config.render_method == 'image' then
            -- Check at runtime whether image rendering is actually possible
            local kitty = require('fk_markdown.latex.kitty')
            local latex_backend = require('fk_markdown.latex.backend')
            use_image = kitty.is_supported() and latex_backend.resolve(self.config) ~= nil
        end

        if use_image then
            self:render_images(nodes)
        else
            -- Text-based rendering (original utftex / latex2text pipeline)
            local cmds = env.commands(self.config.converter)
            if #cmds > 0 then
                local inputs = Handler.inputs(nodes)
                for _, cmd in ipairs(cmds) do
                    inputs = Handler.convert(cmd, inputs)
                end
                for _, input in ipairs(inputs) do
                    log.add('error', 'ConvertersFailed', input)
                    Handler.cache[input] = 'error'
                end
                local rows = self:rows(nodes)
                for row, row_nodes in pairs(rows) do
                    self:render(row, row_nodes)
                end
            end
        end
    end

    return self.marks:get()
end

---@private
---@param cols integer
---@return string, string
local function invalid_banner(cols)
    local hl = 'FkLatexInvalid'
    vim.api.nvim_set_hl(0, hl, {
        fg = '#1e1e2e',
        bg = '#f38ba8',
        bold = true,
        default = true,
    })
    local label = '  ⚠  Invalid Equation  '
    local width = math.max(cols, 48, vim.fn.strdisplaywidth(label) + 4)
    width = math.min(width, math.max(48, vim.o.columns - 4))
    local inner = vim.fn.strdisplaywidth(label)
    local pad = math.max(0, width - inner)
    local left = math.floor(pad / 2)
    local right = pad - left
    return string.rep(' ', left) .. label .. string.rep(' ', right), hl
end

---@private
function Handler:render_images(nodes)
    local state = require('fk_markdown.latex.state')
    local kitty = require('fk_markdown.latex.kitty')
    local mode = vim.fn.mode()
    local in_insert = mode == 'i' and self.config.hide_on_insert

    local function refresh()
        if vim.api.nvim_buf_is_valid(self.context.buf) then
            pcall(
                require('fk_markdown.core.ui').update,
                self.context.buf,
                self.context.win,
                'UserCommand',
                true
            )
        end
    end

    for _, node in ipairs(nodes) do
        local node_id = tostring(node.start_row) .. '_' .. tostring(node.start_col)
        local input = Handler.input(node)
        local source_cols = math.max(1, vim.fn.strdisplaywidth(node.text))

        if not in_insert then
            local err = state.errors[node_id]
            local active = state.active_images[node_id]

            if err and err.equation == input then
                local text, hl = invalid_banner(source_cols)
                self.marks:add(self.config, 'latex', node.start_row, node.start_col, {
                    virt_text = { { text, hl } },
                    virt_text_pos = 'overlay',
                    virt_text_hide = true,
                })
                -- Cover remaining source lines so raw TeX does not peek through.
                for r = node.start_row + 1, node.end_row do
                    self.marks:add(self.config, 'latex', r, 0, {
                        virt_text = { { string.rep(' ', math.max(source_cols, vim.fn.strdisplaywidth(text))), hl } },
                        virt_text_pos = 'overlay',
                        virt_text_hide = true,
                    })
                end
            elseif not active or active.equation ~= input then
                state.request_render(input, self.config, node_id, source_cols, function()
                    refresh()
                end)
            else
                local img_cols = math.max(active.cols, source_cols)
                local img_rows = active.rows
                local hl = kitty.get_highlight(active.id)
                local src_rows = node:height()

                for i = 1, math.min(src_rows, img_rows) do
                    local row = node.start_row + i - 1
                    local col = i == 1 and node.start_col or 0
                    self.marks:add(self.config, 'latex', row, col, {
                        virt_text = { { kitty.build_placeholder_row(i, img_cols), hl } },
                        virt_text_pos = 'overlay',
                        virt_text_hide = true,
                    })
                end

                if img_rows > src_rows then
                    local extra = {}
                    for r = src_rows + 1, img_rows do
                        extra[#extra + 1] = { { kitty.build_placeholder_row(r, img_cols), hl } }
                    end
                    self.marks:add(self.config, 'virtual_lines', node.end_row, 0, {
                        virt_lines = extra,
                        virt_lines_above = false,
                    })
                end
            end
        end
    end
end


---@private
---@param nodes render.md.Node[]
---@return string[]
function Handler.inputs(nodes)
    local inputs = {} ---@type string[]
    for _, node in ipairs(nodes) do
        local input = Handler.input(node)
        if not Handler.cache[input] and not vim.tbl_contains(inputs, input) then
            inputs[#inputs + 1] = input
        end
    end
    return inputs
end

---@private
---@param node render.md.Node
---@return string
function Handler.input(node)
    local text = vim.trim(node.text)
    text = text:gsub('^%$+', ''):gsub('%$+$', '')
    text = require('fk_markdown.latex.backend').sanitize_tex(text)
    return vim.trim(text)
end

---@private
---@param cmd string
---@param inputs string[]
---@return string[]
function Handler.convert(cmd, inputs)
    local failed = {} ---@type string[]
    if vim.system then
        local tasks = {} ---@type table<string, vim.SystemObj>
        for _, input in ipairs(inputs) do
            tasks[input] = vim.system({ cmd }, { stdin = input, text = true })
        end
        for input, task in pairs(tasks) do
            local output = task:wait()
            local result = output.stdout
            if output.code == 0 and result then
                Handler.cache[input] = result
            else
                failed[#failed + 1] = input
            end
        end
    else
        for _, input in ipairs(inputs) do
            local result = vim.fn.system(cmd, input)
            if vim.v.shell_error == 0 and result then
                Handler.cache[input] = result
            else
                failed[#failed + 1] = input
            end
        end
    end
    return failed
end

---@private
---@param nodes render.md.Node[]
---@return table<integer, render.md.Node[]>
function Handler:rows(nodes)
    local position = self.config.position

    ---@param node render.md.Node
    ---@return integer, integer
    local function get(node)
        if position == 'below' and node:height() > 1 then
            return node.end_row, 0
        else
            return node.start_row, node.start_col
        end
    end

    table.sort(nodes, function(a, b)
        local a_row, a_col = get(a)
        local b_row, b_col = get(b)
        if a_row ~= b_row then
            return a_row < b_row
        else
            return a_col < b_col
        end
    end)

    local result = {} ---@type table<integer, render.md.Node[]>
    for _, node in ipairs(nodes) do
        local node_row = get(node)
        if not result[node_row] then
            result[node_row] = {}
        end
        local row = result[node_row]
        row[#row + 1] = node
    end
    return result
end

---@private
---@param row integer
---@param nodes render.md.Node[]
function Handler:render(row, nodes)
    local first = nodes[1]
    local indent = self:indent(first)

    local lines_above = {} ---@type string[]
    local lines_below = {} ---@type string[]
    local current = 0

    for _, node in ipairs(nodes) do
        local output = str.split(Handler.cache[Handler.input(node)], '\n', true)
        if #output > 0 then
            -- add top and bottom padding around output
            for _ = 1, self.config.top_pad do
                table.insert(output, 1, '')
            end
            for _ = 1, self.config.bottom_pad do
                output[#output + 1] = ''
            end

            -- pad lines to the same width
            local width = vim.fn.max(iter.list.map(output, str.width))
            for i, line in ipairs(output) do
                output[i] = line .. str.pad(width - str.width(line))
            end

            -- center is only possible if formula is a single line
            local position = self.config.position
            if position == 'center' and node:height() > 1 then
                position = 'above'
            end

            -- absolute formula column
            local col ---@type integer
            if position == 'below' and node:height() > 1 then
                -- latex blocks include last line, unlike markdown blocks
                local _, line = node:line('below', 1)
                col = line and str.spaces('start', line) or 0
            else
                local _, line = node:line('first', 0)
                col = self.context:width({
                    text = line and line:sub(1, node.start_col) or '',
                    start_row = node.start_row,
                    start_col = 0,
                    end_row = node.start_row,
                    end_col = node.start_col,
                })
            end

            -- convert column to relative offset, include padding between formulas
            local prefix = math.max(col - current, current == 0 and 0 or 1)

            local above ---@type integer
            local below ---@type integer
            if position == 'above' then
                above = #output
                below = 0
            elseif position == 'below' then
                above = 0
                below = #output
            else
                assert(node:height() == 1, 'invalid center height')
                local center = math.floor(#output / 2) + 1
                above = center - 1
                below = #output - center
                self.marks:over(self.config, 'latex', node, {
                    virt_text = { { output[center], self.config.highlight } },
                    virt_text_pos = 'inline',
                    conceal = '',
                })
            end

            -- fill in new lines at top and bottom
            while #lines_above < above do
                table.insert(lines_above, 1, str.pad(current))
            end
            while #lines_below < below do
                lines_below[#lines_below + 1] = str.pad(current)
            end

            -- concatenate output onto lines
            for i, line in ipairs(lines_above) do
                local index = i - (#lines_above - above)
                local body = output[index] or str.pad(width)
                lines_above[i] = line .. str.pad(prefix) .. body
            end
            for i, line in ipairs(lines_below) do
                local index = i + (#output - below)
                local body = output[index] or str.pad(width)
                lines_below[i] = line .. str.pad(prefix) .. body
            end

            -- update current width of lines
            current = current + prefix + width
        end
    end

    ---@param lines string[]
    ---@param above boolean
    local function add_lines(lines, above)
        if #lines == 0 then
            return
        end
        self.marks:add(self.config, 'virtual_lines', row, 0, {
            virt_lines = iter.list.map(lines, function(line)
                return indent:copy():text(line, self.config.highlight):get()
            end),
            virt_lines_above = above,
        })
    end

    add_lines(lines_above, true)
    add_lines(lines_below, false)
end

---@private
---@param node render.md.Node
---@return render.md.Line
function Handler:indent(node)
    local buf = self.context.buf
    local markdown = vim.treesitter.get_node({
        bufnr = buf,
        pos = { node.start_row, node.start_col },
        lang = 'markdown',
    })
    if not markdown then
        return self.context.config:line()
    else
        return Indent.new(self.context, Node.new(buf, markdown)):line(true)
    end
end

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):run(ctx.root, ctx.last)
end

return M
