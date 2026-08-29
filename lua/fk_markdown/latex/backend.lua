-- LaTeX → PNG rendering backend for fk_markdown.nvim

local M = {}

---@private
local deps_checked = false
---@private
local available_backend = nil

-- CodeCogs returns this exact PNG for unparseable TeX ("Invalid Equation").
local CODECOGS_ERROR_SHA256 =
    '370d76315229343de42479afc5be9f3e3eeec4da8b1ea92d8496b7814c11f5fa'

local function ensure_dir(dir)
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
end

local function hash(content)
    return vim.fn.sha256(content):sub(1, 16)
end

---@param s string
---@return string
local function urlencode(s)
    return (s:gsub('([^%w%-_%.~])', function(c)
        return string.format('%%%02X', string.byte(c))
    end))
end

local function file_sha256(path)
    local f = io.open(path, 'rb')
    if not f then
        return nil
    end
    local data = f:read('*a')
    f:close()
    if not data then
        return nil
    end
    return vim.fn.sha256(data)
end

---Undo C-style escapes that turn `\begin` into backspace+egin, `\frac` into form-feed+rac.
---@param s string
---@return string
function M.sanitize_tex(s)
    local map = {
        ['\a'] = '\\a',
        ['\b'] = '\\b',
        ['\t'] = '\\t',
        ['\v'] = '\\v',
        ['\f'] = '\\f',
        ['\r'] = '\\r',
    }
    return (s:gsub('[\a\b\t\v\f\r]', function(c)
        return map[c]
    end))
end

---@param config render.md.latex.Config
---@return string
local function glyph_color(config)
    local bg = config.image_background or 'transparent'
    if type(bg) == 'string' and bg:match('^#%x%x%x%x%x%x$') then
        -- Light backgrounds need dark glyphs
        local r = tonumber(bg:sub(2, 3), 16) or 0
        local g = tonumber(bg:sub(4, 5), 16) or 0
        local b = tonumber(bg:sub(6, 7), 16) or 0
        if (r + g + b) / 3 > 140 then
            return '#000000'
        end
        return '#ffffff'
    end
    if vim.o.background == 'light' then
        return '#000000'
    end
    return '#ffffff'
end

---@param config render.md.latex.Config
---@return string rsvg -b value
local function rsvg_background(config)
    local bg = config.image_background or 'transparent'
    if bg == 'transparent' or bg == 'none' then
        return 'none'
    end
    if bg == 'match' then
        if vim.o.background == 'light' then
            return '#ffffff'
        end
        return '#000000'
    end
    if type(bg) == 'string' and bg:match('^#%x%x%x%x%x%x$') then
        return bg
    end
    return 'none'
end

function M.detect_backend()
    if deps_checked then
        return available_backend
    end
    deps_checked = true

    local has_node = vim.fn.executable('node') == 1
    local has_rsvg = vim.fn.executable('rsvg-convert') == 1
    local has_mathjax = false
    if has_node then
        vim.fn.system({ 'node', '-e', "require('mathjax')" })
        if vim.v.shell_error == 0 then
            has_mathjax = true
        else
            vim.fn.system({ 'node', '-e', "require('mathjax-node')" })
            if vim.v.shell_error == 0 then
                has_mathjax = true
            end
        end
    end

    if has_node and has_rsvg and has_mathjax then
        available_backend = 'mathjax'
        return available_backend
    end

    if vim.fn.executable('curl') == 1 then
        available_backend = 'network'
        return available_backend
    end

    available_backend = nil
    return nil
end

function M.resolve(config)
    local requested = config.backend
    if requested == 'auto' then
        return M.detect_backend()
    end
    if requested == 'mathjax' then
        return 'mathjax'
    end
    if requested == 'network' then
        if vim.fn.executable('curl') == 1 then
            return 'network'
        end
        return nil
    end
    return nil
end

---@param svg string
---@param fill string
---@return string
local function svg_set_fill(svg, fill)
    if svg:find('<svg[^>]*fill=', 1, false) then
        return svg:gsub('(<svg[^>]*)fill="[^"]*"', '%1fill="' .. fill .. '"', 1)
    end
    return (svg:gsub('<svg%s', '<svg fill="' .. fill .. '" ', 1))
end

---@param svg_path string
---@param png_path string
---@param config render.md.latex.Config
---@param callback fun(path: string|nil, reason?: string)
local function svg_to_png(svg_path, png_path, config, callback)
    if vim.fn.executable('rsvg-convert') ~= 1 then
        pcall(vim.fn.delete, svg_path)
        callback(nil, 'rsvg')
        return
    end
    local scale = config.dynamic_scale or 1.0
    local dpi = math.floor(144 * scale)
    local bg = rsvg_background(config)
    vim.system({
        'rsvg-convert',
        '-b',
        bg,
        '-d',
        tostring(dpi),
        '-p',
        tostring(dpi),
        '-o',
        png_path,
        svg_path,
    }, {}, function(rsvg_out)
        vim.schedule(function()
            pcall(vim.fn.delete, svg_path)
            if rsvg_out.code == 0 and vim.fn.getfsize(png_path) > 100 then
                callback(png_path)
            else
                pcall(vim.fn.delete, png_path)
                callback(nil, 'invalid')
            end
        end)
    end)
end

function M.render(equation, config, callback)
    ensure_dir(config.cache_dir)
    equation = M.sanitize_tex(equation)
    -- CodeCogs / one-line TeX: keep \\ row breaks, drop source newlines
    local tex = equation:gsub('\r\n', '\n'):gsub('\n', ' ')
    tex = vim.trim(tex)

    local backend = M.resolve(config)
    local bg = config.image_background or 'transparent'
    local key = 'v3:' .. tostring(backend) .. ':' .. tostring(bg) .. ':' .. glyph_color(config) .. ':' .. tex
    local path = config.cache_dir .. '/' .. hash(key) .. '.png'

    if vim.fn.filereadable(path) == 1 and vim.fn.getfsize(path) > 100 then
        if file_sha256(path) == CODECOGS_ERROR_SHA256 then
            pcall(vim.fn.delete, path)
            vim.schedule(function()
                callback(nil, 'invalid')
            end)
            return
        end
        vim.schedule(function()
            callback(path)
        end)
        return
    end

    if not backend then
        vim.schedule(function()
            callback(nil, 'backend')
        end)
        return
    end

    if backend == 'network' then
        M.render_network(tex, path, config, callback)
    elseif backend == 'mathjax' then
        M.render_mathjax(tex, path, config, callback)
    else
        vim.schedule(function()
            callback(nil, 'backend')
        end)
    end
end

function M.render_network(equation, path, config, callback)
    if vim.fn.executable('rsvg-convert') ~= 1 then
        local url = 'https://latex.codecogs.com/png.image?' .. urlencode('\\dpi{200}' .. equation)
        vim.system({ 'curl', '-s', '-L', '--max-time', '15', '-o', path, url }, {}, function(out)
            vim.schedule(function()
                if out.code ~= 0 or vim.fn.getfsize(path) < 100 then
                    pcall(vim.fn.delete, path)
                    callback(nil, 'network')
                    return
                end
                if file_sha256(path) == CODECOGS_ERROR_SHA256 then
                    pcall(vim.fn.delete, path)
                    callback(nil, 'invalid')
                    return
                end
                callback(path)
            end)
        end)
        return
    end

    -- SVG has a transparent canvas; PNG from CodeCogs is an opaque colormap.
    local url = 'https://latex.codecogs.com/svg.image?' .. urlencode(equation)
    local svg_path = path:gsub('%.png$', '.svg')

    vim.system({ 'curl', '-s', '-L', '--max-time', '15', '-o', svg_path, url }, {}, function(out)
        vim.schedule(function()
            if out.code ~= 0 or vim.fn.getfsize(svg_path) < 80 then
                pcall(vim.fn.delete, svg_path)
                callback(nil, 'network')
                return
            end
            local f = io.open(svg_path, 'r')
            local svg = f and f:read('*a') or ''
            if f then
                f:close()
            end
            if not svg:find('<svg', 1, true) or svg:lower():find('invalid') then
                pcall(vim.fn.delete, svg_path)
                callback(nil, 'invalid')
                return
            end
            svg = svg_set_fill(svg, glyph_color(config))
            f = io.open(svg_path, 'w')
            if not f then
                callback(nil, 'io')
                return
            end
            f:write(svg)
            f:close()
            svg_to_png(svg_path, path, config, callback)
        end)
    end)
end

function M.render_mathjax(equation, path, config, callback)
    local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
    local script = plugin_dir .. '/mathjax.js'
    local svg_path = path:gsub('%.png$', '.svg')

    -- stdin avoids argv mangling of backslashes and ARG_MAX on big matrices
    vim.system({ 'node', script }, { text = true, stdin = equation }, function(node_out)
        if node_out.code ~= 0 or not node_out.stdout or node_out.stdout == '' then
            vim.schedule(function()
                callback(nil, 'invalid')
            end)
            return
        end
        local svg = svg_set_fill(node_out.stdout, glyph_color(config))
        vim.schedule(function()
            local f = io.open(svg_path, 'w')
            if not f then
                callback(nil, 'io')
                return
            end
            f:write(svg)
            f:close()
            svg_to_png(svg_path, path, config, callback)
        end)
    end)
end

return M
