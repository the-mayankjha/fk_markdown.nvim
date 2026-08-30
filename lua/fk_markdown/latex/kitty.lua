-- Kitty Graphics Protocol + Unicode placeholders.
-- Protocol usage matches mdmath.nvim (Thiago4532): transmit with t=f,
-- place with U=1, then draw U+10EEEE placeholders as overlay virt_text
-- whose guifg is the image id. See:
--   https://sw.kovidgoyal.net/kitty/graphics-protocol/#unicode-placeholders
-- Cell metrics match image.nvim (ioctl TIOCGWINSZ).

local M = {}

---@private
local stdout = nil
local function get_tty()
    if stdout then
        return stdout
    end
    stdout = (vim.uv or vim.loop).new_tty(1, false)
    if not stdout then
        vim.notify('[fk_markdown] Failed to open stdout TTY for Kitty Graphics', vim.log.levels.WARN)
    end
    return stdout
end

local function tmux_escape(sequence)
    return '\x1bPtmux;' .. sequence:gsub('\x1b', '\x1b\x1b') .. '\x1b\\'
end

---Send a Kitty graphics command. `payload` is raw bytes (file path for t=f).
---@param params table<string, string|integer>
---@param payload? string
local function kitty_send(params, payload)
    if params.q == nil then
        params.q = 2
    end
    local parts = {}
    for k, v in pairs(params) do
        parts[#parts + 1] = tostring(k) .. '=' .. tostring(v)
    end
    local message
    if payload ~= nil then
        message = string.format('\x1b_G%s;%s\x1b\\', table.concat(parts, ','), vim.base64.encode(payload))
    else
        message = string.format('\x1b_G%s\x1b\\', table.concat(parts, ','))
    end
    local t = get_tty()
    if not t then
        return
    end
    local tmux = os.getenv('TMUX')
    if tmux and tmux ~= '' then
        t:write(tmux_escape(message))
    else
        t:write(message)
    end
end

-- ─── Image ID tracking ──────────────────────────────────────────────────────

local next_image_id = 333 -- Same starting ID as mdmath.nvim

-- ─── PNG dimensions ──────────────────────────────────────────────────────────

function M.get_png_dimensions(path)
    local f = io.open(path, 'rb')
    if not f then
        return 0, 0
    end
    f:seek('set', 16)
    local w_bytes = f:read(4)
    local h_bytes = f:read(4)
    f:close()
    if not w_bytes or not h_bytes or #w_bytes < 4 or #h_bytes < 4 then
        return 0, 0
    end
    local w = w_bytes:byte(1) * 16777216
        + w_bytes:byte(2) * 65536
        + w_bytes:byte(3) * 256
        + w_bytes:byte(4)
    local h = h_bytes:byte(1) * 16777216
        + h_bytes:byte(2) * 65536
        + h_bytes:byte(3) * 256
        + h_bytes:byte(4)
    return w, h
end

---@private
local cached_cell = nil ---@type {w: number, h: number}|nil

local function query_cell_size()
    local env_w = tonumber(vim.env.KITTY_CELL_WIDTH)
    local env_h = tonumber(vim.env.KITTY_CELL_HEIGHT)
    if env_w and env_h and env_w > 0 and env_h > 0 then
        return env_w, env_h
    end

    local ok, w, h = pcall(function()
        local ffi = require('ffi')
        pcall(ffi.cdef, [[
            typedef struct {
                unsigned short row;
                unsigned short col;
                unsigned short xpixel;
                unsigned short ypixel;
            } fk_markdown_winsize;
        ]])
        pcall(ffi.cdef, [[ int ioctl(int, unsigned long, ...); ]])
        local TIOCGWINSZ
        if vim.fn.has('linux') == 1 then
            TIOCGWINSZ = 0x5413
        elseif vim.fn.has('mac') == 1 or vim.fn.has('bsd') == 1 then
            TIOCGWINSZ = 0x40087468
        else
            return nil
        end
        local sz = ffi.new('fk_markdown_winsize')
        if ffi.C.ioctl(1, TIOCGWINSZ, sz) ~= 0 then
            return nil
        end
        local xpixel, ypixel = tonumber(sz.xpixel), tonumber(sz.ypixel)
        local cols, rows = tonumber(sz.col), tonumber(sz.row)
        if not cols or not rows or cols < 1 or rows < 1 then
            return nil
        end
        -- SSH / tmux often report 0 pixel dimensions (same fallback as image.nvim)
        if not xpixel or not ypixel or xpixel == 0 or ypixel == 0 then
            xpixel = cols * 8
            ypixel = rows * 16
        end
        return xpixel / cols, ypixel / rows
    end)
    if ok and w and h and w > 0 and h > 0 then
        return w, h
    end
    return 8, 16
end

function M.get_cell_size()
    if cached_cell then
        return cached_cell.w, cached_cell.h
    end
    local w, h = query_cell_size()
    cached_cell = { w = w, h = h }
    return w, h
end

function M.refresh_cell_size()
    cached_cell = nil
end

-- ─── Image transmission ─────────────────────────────────────────────────────

---Transmit a PNG and register it as a Unicode-placeholder image.
---Matches mdmath.nvim Image:_init (t=f path payload, then a=p U=1).
---@param path string
---@param rows integer
---@param cols integer
---@return integer
function M.transmit_image(path, rows, cols)
    local id = next_image_id
    next_image_id = next_image_id + 1
    if next_image_id > 0xFFFFFF then
        next_image_id = 333
    end

    local abs = vim.fn.fnamemodify(path, ':p')
    -- a=t transmit PNG from a local file; C=1 do not move the cursor
    kitty_send({ a = 't', i = id, f = 100, t = 'f', C = 1 }, abs)
    kitty_send({ a = 'p', i = id, U = 1, r = rows, c = cols, C = 1 })
    return id
end

-- ─── Unicode Placeholder string generation ───────────────────────────────────

-- Kitty placeholder character and row/column diacritics.
local PLACEHOLDER = '\u{10EEEE}'
local DIACRITICS = require('fk_markdown.latex.diacritics')

function M.max_placeholder_dim()
    return #DIACRITICS
end

---@type table<integer, string>
local hl_cache = {}

---Highlight group whose 24-bit guifg is the Kitty image id.
---Do not call nvim_get_hl_id_by_name first: it allocates an empty group and
---hlexists then skips setting guifg, so placeholders never bind to the image.
function M.get_highlight(image_id)
    local cached = hl_cache[image_id]
    if cached then
        return cached
    end
    local hl_name = 'FkLatexImg' .. image_id
    vim.api.nvim_set_hl(0, hl_name, {
        fg = string.format('#%06X', image_id),
        ctermfg = image_id < 256 and image_id or nil,
    })
    hl_cache[image_id] = hl_name
    return hl_name
end

---One placeholder row. `row` and columns are 1-based (mdmath Image.unicode_at).
function M.build_placeholder_row(row, num_cols)
    local n = #DIACRITICS
    row = math.max(1, math.min(row, n))
    num_cols = math.max(1, math.min(num_cols, n))
    local row_d = DIACRITICS[row]
    local parts = {}
    for col = 1, num_cols do
        parts[#parts + 1] = PLACEHOLDER .. row_d .. DIACRITICS[col]
    end
    return table.concat(parts)
end

function M.build_virt_lines(image_id, rows, cols)
    local hl = M.get_highlight(image_id)
    local lines = {}
    for r = 1, rows do
        lines[#lines + 1] = { { M.build_placeholder_row(r, cols), hl } }
    end
    return lines, hl
end

function M.build_inline_placeholder(image_id, cols)
    local hl = M.get_highlight(image_id)
    return M.build_placeholder_row(1, cols), hl
end

-- ─── Image deletion ──────────────────────────────────────────────────────────

function M.delete_image(image_id)
    -- d=I: delete placements and free stored image data (mdmath Image:close)
    kitty_send({ a = 'd', d = 'I', i = image_id })
end

function M.delete_all()
    kitty_send({ a = 'd', d = 'a' })
end

-- ─── Terminal detection ──────────────────────────────────────────────────────

function M.is_supported()
    -- Unicode placeholders: Kitty >= 0.28 and Ghostty. WezTerm speaks the
    -- graphics protocol but does not implement placeholders (mdmath docs).
    if vim.env.KITTY_WINDOW_ID and vim.env.KITTY_WINDOW_ID ~= '' then
        return true
    end
    if vim.env.GHOSTTY_RESOURCES_DIR and vim.env.GHOSTTY_RESOURCES_DIR ~= '' then
        return true
    end
    local term = vim.env.TERM or ''
    local term_program = (vim.env.TERM_PROGRAM or ''):lower()
    if term:find('xterm%-kitty', 1, false) or term_program:find('kitty', 1, true) then
        return true
    end
    if term:find('ghostty', 1, true) or term_program:find('ghostty', 1, true) then
        return true
    end
    return false
end

pcall(vim.api.nvim_create_autocmd, 'VimResized', {
    callback = function()
        M.refresh_cell_size()
    end,
})

pcall(vim.api.nvim_create_autocmd, 'ColorScheme', {
    callback = function()
        hl_cache = {}
    end,
})

return M
