-- Parse <img> tags out of markdown HTML (html_block / html_tag).

local M = {}

---@class fk_markdown.image.HtmlImg
---@field src string
---@field width integer|nil
---@field height integer|nil
---@field align string|nil
---@field start integer
---@field finish integer

---Extract align attribute from the nearest parent tag wrapping any <img>.
---Searches backwards from each <img> for tags like <p align="center">, <div align="right">, etc.
---@param text string
---@return string|nil
function M.parse_parent_align(text)
    -- Look for align on any enclosing tag (e.g. <p align="center">, <div align="left">)
    local align = text:match('<[^>]*[Aa][Ll][Ii][Gg][Nn]%s*=%s*"([^"]+)"[^>]*>')
        or text:match("<[^>]*[Aa][Ll][Ii][Gg][Nn]%s*=%s*'([^']+)'[^>]*>")
    if align then
        return align:lower()
    end
    -- Also check for CSS text-align in style attribute
    local style_align = text:match('[Ss][Tt][Yy][Ll][Ee]%s*=%s*"[^"]*text%-align%s*:%s*([%a]+)')
        or text:match("[Ss][Tt][Yy][Ll][Ee]%s*=%s*'[^']*text%-align%s*:%s*([%a]+)")
    if style_align then
        return style_align:lower()
    end
    return nil
end

---@param text string
---@return fk_markdown.image.HtmlImg[]
function M.parse(text)
    local imgs = {}
    local i = 1
    while true do
        local s, e = text:find('<[Ii][Mm][Gg]%s[^>]*>', i)
        if not s then
            break
        end
        local tag = text:sub(s, e)
        local src = tag:match('[Ss][Rr][Cc]%s*=%s*"([^"]*)"')
            or tag:match("[Ss][Rr][Cc]%s*=%s*'([^']*)'")
        local width = tag:match('[Ww][Ii][Dd][Tt][Hh]%s*=%s*"(%d+)"')
            or tag:match("[Ww][Ii][Dd][Tt][Hh]%s*=%s*'(%d+)'")
            or tag:match('[Ww][Ii][Dd][Tt][Hh]%s*=%s*(%d+)')
        local height = tag:match('[Hh][Ee][Ii][Gg][Hh][Tt]%s*=%s*"(%d+)"')
            or tag:match("[Hh][Ee][Ii][Gg][Hh][Tt]%s*=%s*'(%d+)'")
            or tag:match('[Hh][Ee][Ii][Gg][Hh][Tt]%s*=%s*(%d+)')
        local align = tag:match('[Aa][Ll][Ii][Gg][Nn]%s*=%s*"([^"]+)"')
            or tag:match("[Aa][Ll][Ii][Gg][Nn]%s*=%s*'([^']+)'")
            or tag:match('[Aa][Ll][Ii][Gg][Nn]%s*=%s*([%a]+)')
        if src and src ~= '' then
            -- If no align on <img> itself, check parent tags
            if not align then
                local prefix = text:sub(1, s - 1)
                align = M.parse_parent_align(prefix)
            end
            imgs[#imgs + 1] = {
                src = src,
                width = tonumber(width),
                height = tonumber(height),
                align = align and align:lower() or nil,
                start = s,
                finish = e,
            }
        end
        i = e + 1
    end
    return imgs
end

return M
