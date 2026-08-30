local bit = bit or bit32 or require('bit')
local rshift = bit.rshift
local lshift = bit.lshift
local band = bit.band
local bor = bit.bor

local M = {}

---Map 6 bits (0..63) to PlantUML 64-character alphabet
---@param b integer
---@return string
local function encode6bit(b)
    if b < 10 then
        return string.char(48 + b) -- '0'..'9'
    end
    b = b - 10
    if b < 26 then
        return string.char(65 + b) -- 'A'..'Z'
    end
    b = b - 26
    if b < 26 then
        return string.char(97 + b) -- 'a'..'z'
    end
    b = b - 26
    if b == 0 then
        return '-'
    end
    if b == 1 then
        return '_'
    end
    return '?'
end

---Append 3 bytes (24 bits) as 4 6-bit characters
---@param b1 integer
---@param b2 integer
---@param b3 integer
---@return string
local function append3bytes(b1, b2, b3)
    local c1 = rshift(b1, 2)
    local c2 = bor(lshift(band(b1, 0x3), 4), rshift(b2, 4))
    local c3 = bor(lshift(band(b2, 0xF), 2), rshift(b3, 6))
    local c4 = band(b3, 0x3F)
    return encode6bit(band(c1, 0x3F))
        .. encode6bit(band(c2, 0x3F))
        .. encode6bit(band(c3, 0x3F))
        .. encode6bit(band(c4, 0x3F))
end

---Encode binary data using PlantUML 64-character scheme
---@param data string
---@return string
function M.encode64(data)
    local r = {}
    local len = #data
    local i = 1
    while i <= len do
        local b1 = data:byte(i)
        local b2 = (i + 1 <= len) and data:byte(i + 1) or 0
        local b3 = (i + 2 <= len) and data:byte(i + 2) or 0
        r[#r + 1] = append3bytes(b1, b2, b3)
        i = i + 3
    end
    return table.concat(r)
end

---Bit writer for Deflate stream
---@return fun(val: integer, count: integer), fun(): string
local function create_bit_writer()
    local bytes = {}
    local bit_buf = 0
    local bit_cnt = 0

    local function write_bits(val, count)
        bit_buf = bor(bit_buf, lshift(val, bit_cnt))
        bit_cnt = bit_cnt + count
        while bit_cnt >= 8 do
            bytes[#bytes + 1] = string.char(band(bit_buf, 0xFF))
            bit_buf = rshift(bit_buf, 8)
            bit_cnt = bit_cnt - 8
        end
    end

    local function finish()
        if bit_cnt > 0 then
            bytes[#bytes + 1] = string.char(band(bit_buf, 0xFF))
        end
        return table.concat(bytes)
    end

    return write_bits, finish
end

---Reverse lowest n bits of an integer
---@param val integer
---@param n integer
---@return integer
local function reverse_bits(val, n)
    local res = 0
    for i = 0, n - 1 do
        if band(val, lshift(1, i)) ~= 0 then
            res = bor(res, lshift(1, n - 1 - i))
        end
    end
    return res
end

---Compress string with RFC 1951 Fixed Huffman Deflate
---@param text string
---@return string
function M.deflate(text)
    local write_bits, finish = create_bit_writer()
    -- BFINAL = 1 (1 bit), BTYPE = 01 (fixed Huffman, 2 bits) -> 0b011 (3 bits, LSB first)
    write_bits(3, 3)

    for i = 1, #text do
        local byte = text:byte(i)
        if byte <= 143 then
            -- 0..143: 8 bits, code is (0x30 + byte)
            local code = 0x30 + byte
            write_bits(reverse_bits(code, 8), 8)
        else
            -- 144..255: 9 bits, code is (0x100 + byte)
            local code = 0x100 + byte
            write_bits(reverse_bits(code, 9), 9)
        end
    end
    -- End of block code 256: 7 bits, code 0 (0000000)
    write_bits(0, 7)
    return finish()
end

---Normalize PlantUML text (ensures @startuml / @enduml wrap)
---@param text string
---@param theme? string
---@param styling? table
---@return string
function M.normalize_puml(text, theme, styling)
    local trimmed = vim.trim(text)
    local has_start = trimmed:find('^@start') ~= nil
    local has_end = trimmed:find('@end') ~= nil

    local header_lines = {}
    if theme and theme ~= 'default' and theme ~= '' then
        header_lines[#header_lines + 1] = '!theme ' .. theme
    end

    if styling and type(styling) == 'table' then
        if styling.background and styling.background ~= 'transparent' and styling.background ~= '' then
            header_lines[#header_lines + 1] = 'skinparam backgroundColor ' .. styling.background
        elseif styling.background == 'transparent' then
            header_lines[#header_lines + 1] = 'skinparam backgroundColor transparent'
        end
        if styling.dpi and type(styling.dpi) == 'number' then
            header_lines[#header_lines + 1] = 'skinparam dpi ' .. tostring(styling.dpi)
        end
        if styling.scale and type(styling.scale) == 'number' and styling.scale ~= 1.0 then
            header_lines[#header_lines + 1] = 'scale ' .. tostring(styling.scale)
        end
        if styling.font and type(styling.font) == 'string' and styling.font ~= '' then
            header_lines[#header_lines + 1] = 'skinparam defaultFontName ' .. styling.font
        end
    end

    local injected_header = #header_lines > 0 and (table.concat(header_lines, '\n') .. '\n') or ''

    if not has_start then
        trimmed = '@startuml\n' .. injected_header .. trimmed
    elseif injected_header ~= '' then
        -- Insert after the first line (e.g. @startuml)
        local first_line_end = trimmed:find('\n')
        if first_line_end then
            trimmed = trimmed:sub(1, first_line_end) .. injected_header .. trimmed:sub(first_line_end + 1)
        else
            trimmed = trimmed .. '\n' .. injected_header
        end
    end

    if not has_end then
        trimmed = trimmed .. '\n@enduml'
    end

    return trimmed
end

---Encode PlantUML code into PlantUML URL path token
---@param text string
---@param theme? string
---@param styling? table
---@return string
function M.encode(text, theme, styling)
    local puml = M.normalize_puml(text, theme, styling)
    local deflated = M.deflate(puml)
    return M.encode64(deflated)
end

---Build full PlantUML URL
---@param server string
---@param format string "png"|"svg"
---@param text string
---@param theme? string
---@param styling? table
---@return string
function M.get_url(server, format, text, theme, styling)
    local base = (server or 'https://www.plantuml.com/plantuml'):gsub('/+$', '')
    local encoded = M.encode(text, theme, styling)
    return string.format('%s/%s/%s', base, format or 'png', encoded)
end

return M
