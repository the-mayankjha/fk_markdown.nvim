-- Parse <img> tags out of markdown HTML (html_block / html_tag).

local M = {}

---@class fk_markdown.image.HtmlImg
---@field src string
---@field width integer|nil
---@field start integer
---@field finish integer

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
        if src and src ~= '' then
            imgs[#imgs + 1] = {
                src = src,
                width = tonumber(width),
                start = s,
                finish = e,
            }
        end
        i = e + 1
    end
    return imgs
end

return M
