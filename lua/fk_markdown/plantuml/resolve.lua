local encoder = require('fk_markdown.plantuml.encoder')

local M = {}

---Ensure cache directory exists
---@param dir string
---@return boolean
local function ensure_dir(dir)
    if vim.fn.isdirectory(dir) == 1 then
        return true
    end
    return vim.fn.mkdir(dir, 'p') == 1
end

---Compute safe hash string for caching
---@param text string
---@param theme? string
---@param styling? table
---@return string
function M.hash(text, theme, styling)
    local raw = text .. '||' .. (theme or '') .. '||' .. vim.inspect(styling or {})
    return vim.fn.sha256(raw)
end

---Resolve or download PlantUML diagram to a local PNG file
---@param text string
---@param config table
---@param callback fun(path: string|nil, err: string|nil)
function M.resolve(text, config, callback)
    local cache_dir = config.cache_dir or (vim.fn.stdpath('cache') .. '/fk_markdown/plantuml')
    ensure_dir(cache_dir)

    local hash = M.hash(text, config.theme, config.styling)
    local target_file = string.format('%s/%s.png', cache_dir, hash)

    -- Return immediately if already cached
    if vim.fn.filereadable(target_file) == 1 then
        local size = vim.fn.getfsize(target_file)
        if size > 0 then
            callback(target_file, nil)
            return
        end
    end

    -- 1. If local plantuml command exists and local rendering preferred
    if config.local_cmd and vim.fn.executable(config.local_cmd) == 1 then
        local puml_content = encoder.normalize_puml(text, config.theme, config.styling)
        local cmd = { config.local_cmd, '-tpng', '-pipe' }
        if vim.system then
            vim.system(cmd, { stdin = puml_content }, function(res)
                vim.schedule(function()
                    if res.code == 0 and res.stdout and #res.stdout > 0 then
                        local f = io.open(target_file, 'wb')
                        if f then
                            f:write(res.stdout)
                            f:close()
                            callback(target_file, nil)
                            return
                        end
                    end
                    -- Fallback to remote server
                    M.fetch_remote(text, config, target_file, callback)
                end)
            end)
            return
        end
    end

    -- 2. Remote server fetch via curl
    M.fetch_remote(text, config, target_file, callback)
end

---Fetch diagram from PlantUML server
---@param text string
---@param config table
---@param target_file string
---@param callback fun(path: string|nil, err: string|nil)
function M.fetch_remote(text, config, target_file, callback)
    local url = encoder.get_url(config.server or 'https://www.plantuml.com/plantuml', 'png', text, config.theme, config.styling)
    local tmp_file = target_file .. '.tmp'

    local cmd = {
        'curl',
        '-s',
        '-L',
        '--max-time',
        '10',
        '-o',
        tmp_file,
        url,
    }

    if vim.system then
        vim.system(cmd, {}, function(res)
            vim.schedule(function()
                if res.code == 0 and vim.fn.filereadable(tmp_file) == 1 and vim.fn.getfsize(tmp_file) > 0 then
                    os.rename(tmp_file, target_file)
                    callback(target_file, nil)
                else
                    pcall(os.remove, tmp_file)
                    callback(nil, res.stderr or 'Failed to download PlantUML diagram from server')
                end
            end)
        end)
    else
        local job_id = vim.fn.jobstart(cmd, {
            on_exit = function(_, code)
                vim.schedule(function()
                    if code == 0 and vim.fn.filereadable(tmp_file) == 1 and vim.fn.getfsize(tmp_file) > 0 then
                        os.rename(tmp_file, target_file)
                        callback(target_file, nil)
                    else
                        pcall(os.remove, tmp_file)
                        callback(nil, 'Failed to download PlantUML diagram from server')
                    end
                end)
            end,
        })
        if job_id <= 0 then
            callback(nil, 'Failed to spawn curl for PlantUML diagram')
        end
    end
end

return M
