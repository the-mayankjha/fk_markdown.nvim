-- Resolve a markdown image destination to a local PNG path.

local M = {}

local function ensure_dir(dir)
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
end

local function decode(s)
    s = s:gsub('^<', ''):gsub('>$', '')
    s = s:gsub('^%s+', ''):gsub('%s+$', '')
    s = s:gsub('^file://', '')
    s = s:gsub('%%(%x%x)', function(hex)
        return string.char(tonumber(hex, 16))
    end)
    return s
end

---@param path string
---@return string
local function ext(path)
    return (path:match('%.([%w]+)$') or ''):lower()
end

---@param src string
---@param out string
---@param callback fun(path: string|nil)
local function convert_to_png(src, out, callback)
    if ext(src) == 'png' then
        vim.schedule(function()
            callback(src)
        end)
        return
    end
    if vim.fn.filereadable(out) == 1 and vim.fn.getfsize(out) > 32 then
        vim.schedule(function()
            callback(out)
        end)
        return
    end

    local function done(ok)
        vim.schedule(function()
            if ok and vim.fn.getfsize(out) > 32 then
                callback(out)
            else
                pcall(vim.fn.delete, out)
                callback(nil)
            end
        end)
    end

    if ext(src) == 'svg' and vim.fn.executable('rsvg-convert') == 1 then
        vim.system({ 'rsvg-convert', '-b', 'none', '-o', out, src }, {}, function(r)
            done(r.code == 0)
        end)
        return
    end
    if vim.fn.executable('sips') == 1 then
        vim.system({ 'sips', '-s', 'format', 'png', src, '--out', out }, {}, function(r)
            done(r.code == 0)
        end)
        return
    end
    if vim.fn.executable('magick') == 1 then
        vim.system({ 'magick', src, out }, {}, function(r)
            done(r.code == 0)
        end)
        return
    end
    if vim.fn.executable('convert') == 1 then
        vim.system({ 'convert', src, out }, {}, function(r)
            done(r.code == 0)
        end)
        return
    end
    vim.schedule(function()
        callback(nil)
    end)
end

---Turn a markdown image destination into a PNG on disk.
---@param dest string
---@param buf integer
---@param cache_dir string
---@param callback fun(path: string|nil)
function M.to_png(dest, buf, cache_dir, callback)
    ensure_dir(cache_dir)
    local src = decode(dest)
    if src == '' then
        vim.schedule(function()
            callback(nil)
        end)
        return
    end

    if src:match('^https?://') then
        local name = vim.fn.sha256(src):sub(1, 16)
        local guessed = src:match('%.([%w]+)$') or 'bin'
        local raw = cache_dir .. '/' .. name .. '.' .. guessed
        local png = cache_dir .. '/' .. name .. '.png'
        if vim.fn.filereadable(png) == 1 and vim.fn.getfsize(png) > 32 then
            vim.schedule(function()
                callback(png)
            end)
            return
        end
        vim.system({ 'curl', '-sL', '--max-time', '20', '-o', raw, src }, {}, function(out)
            if out.code ~= 0 or vim.fn.getfsize(raw) < 32 then
                pcall(vim.fn.delete, raw)
                vim.schedule(function()
                    callback(nil)
                end)
                return
            end
            convert_to_png(raw, png, callback)
        end)
        return
    end

    local path = src
    if not path:match('^/') and not path:match('^%a:[/\\]') then
        local bufname = vim.api.nvim_buf_get_name(buf)
        local dir = vim.fn.fnamemodify(bufname, ':h')
        path = vim.fn.fnamemodify(dir .. '/' .. src, ':p')
    else
        path = vim.fn.fnamemodify(path, ':p')
    end

    if vim.fn.filereadable(path) == 0 then
        vim.schedule(function()
            callback(nil)
        end)
        return
    end

    local png = cache_dir .. '/' .. vim.fn.sha256(path):sub(1, 16) .. '.png'
    convert_to_png(path, png, callback)
end

return M
