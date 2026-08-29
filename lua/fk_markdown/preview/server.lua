local uv = vim.uv or vim.loop

local M = {}
M.__index = M

function M.new(buf)
    local self = setmetatable({}, M)
    self.buf = buf
    self.clients = {}
    self.tcp = nil
    self.port = 0
    self.group = vim.api.nvim_create_augroup('FkMarkdownPreview_' .. buf, { clear = true })
    return self
end

local html_template = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>fk_markdown preview</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-dark.min.css">
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.0.3/purify.min.js"></script>
<style>
body { font-family: sans-serif; padding: 20px; max-width: 900px; margin: auto; background-color: #0d1117; }
.markdown-body { box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; }
@media (max-width: 767px) { .markdown-body { padding: 15px; } }
</style>
</head>
<body>
<article class="markdown-body" id="content"></article>
<script>
const contentDiv = document.getElementById('content');
const es = new EventSource('/events');
es.onmessage = function(e) {
    const payload = JSON.parse(e.data);
    if (payload.type === 'update') {
        contentDiv.innerHTML = DOMPurify.sanitize(marked.parse(payload.text));
        if (payload.auto_scroll && payload.total_lines > 0) {
            const percent = (payload.line - 1) / (payload.total_lines > 1 ? payload.total_lines - 1 : 1);
            const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
            if (maxScroll > 0) {
                window.scrollTo({ top: maxScroll * percent, behavior: 'instant' });
            }
        }
    } else if (payload.type === 'scroll') {
        if (payload.total_lines > 0) {
            const percent = (payload.line - 1) / (payload.total_lines > 1 ? payload.total_lines - 1 : 1);
            const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
            if (maxScroll > 0) {
                window.scrollTo({ top: maxScroll * percent, behavior: 'smooth' });
            }
        }
    }
};
</script>
</body>
</html>
]]

function M:start()
    self.tcp = uv.new_tcp()
    local ok, err = self.tcp:bind("127.0.0.1", 0)
    if not ok then return false, err end

    self.port = self.tcp:getsockname().port

    self.tcp:listen(128, function(err)
        if err then return end
        local client = uv.new_tcp()
        self.tcp:accept(client)
        client:read_start(function(err, chunk)
            if err or not chunk then
                client:close()
                return
            end
            
            -- very basic HTTP parser
            local method, path = chunk:match("^(%u+)%s+(%S+)")
            if method == "GET" then
                if path == "/" then
                    local body = html_template
                    local resp = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: " .. #body .. "\r\nConnection: close\r\n\r\n" .. body
                    client:write(resp, function() client:close() end)
                elseif path == "/events" then
                    local resp = "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\n\r\n"
                    client:write(resp)
                    table.insert(self.clients, client)
                    self:send_update()
                else
                    -- attempt to serve local file
                    vim.schedule(function()
                        local clean_path = path:gsub("%?.*$", "")
                        clean_path = clean_path:gsub("%%(%x%x)", function(h)
                            return string.char(tonumber(h, 16))
                        end)
                        
                        local base_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ':h')
                        local file_path = vim.fn.expand(base_dir .. clean_path)
                        local f = io.open(file_path, "rb")
                        
                        if f then
                            local content = f:read("*a")
                            f:close()
                            local ext = file_path:match("^.+(%..+)$") or ""
                            local ctype = "text/plain"
                            if ext == ".png" then ctype = "image/png"
                            elseif ext == ".jpg" or ext == ".jpeg" then ctype = "image/jpeg"
                            elseif ext == ".gif" then ctype = "image/gif"
                            elseif ext == ".svg" then ctype = "image/svg+xml"
                            end
                            local resp = "HTTP/1.1 200 OK\r\nContent-Type: " .. ctype .. "\r\nContent-Length: " .. #content .. "\r\nConnection: close\r\n\r\n" .. content
                            client:write(resp, function() client:close() end)
                        else
                            client:write("HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n", function() client:close() end)
                        end
                    end)
                end
            end
        end)
    end)

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = self.buf,
        group = self.group,
        callback = function()
            self:send_update()
        end
    })
    
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = self.buf,
        group = self.group,
        callback = function()
            self:send_scroll()
        end
    })
    
    vim.api.nvim_create_autocmd("BufUnload", {
        buffer = self.buf,
        group = self.group,
        callback = function()
            require('fk_markdown.preview').stop()
        end
    })

    return true
end

function M:send_scroll()
    local state = require('fk_markdown.state')
    if not state.config.preview.auto_scroll then return end
    vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(self.buf) then return end
        local win = vim.fn.bufwinid(self.buf)
        if win == -1 then return end
        
        local current_line = vim.api.nvim_win_get_cursor(win)[1]
        local total_lines = vim.api.nvim_buf_line_count(self.buf)
        
        local payload_obj = {
            type = "scroll",
            line = current_line,
            total_lines = total_lines
        }
        local data = vim.json.encode(payload_obj)
        local payload = "data: " .. data .. "\n\n"
        
        local active_clients = {}
        for _, client in ipairs(self.clients) do
            if client:is_active() then
                client:write(payload)
                table.insert(active_clients, client)
            end
        end
        self.clients = active_clients
    end)
end

function M:send_update()
    vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(self.buf) then return end
        local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
        local text = table.concat(lines, "\n")
        
        local state = require('fk_markdown.state')
        local auto_scroll = state.config.preview.auto_scroll
        local current_line = 1
        local total_lines = #lines
        if auto_scroll then
            local win = vim.fn.bufwinid(self.buf)
            if win ~= -1 then
                current_line = vim.api.nvim_win_get_cursor(win)[1]
            end
        end
        
        local payload_obj = { type = "update", text = text, line = current_line, total_lines = total_lines, auto_scroll = auto_scroll }
        local data = vim.json.encode(payload_obj)
        local payload = "data: " .. data .. "\n\n"
        
        local active_clients = {}
        for _, client in ipairs(self.clients) do
            if client:is_active() then
                client:write(payload)
                table.insert(active_clients, client)
            end
        end
        self.clients = active_clients
    end)
end

function M:stop()
    if self.tcp then
        self.tcp:close()
        self.tcp = nil
    end
    for _, client in ipairs(self.clients) do
        if not client:is_closing() then
            client:close()
        end
    end
    self.clients = {}
    pcall(vim.api.nvim_del_augroup_by_id, self.group)
end

function M:open_browser()
    local url = "http://127.0.0.1:" .. self.port
    local cmd
    if vim.fn.has('mac') == 1 then
        cmd = { 'open', url }
    elseif vim.fn.has('unix') == 1 then
        cmd = { 'xdg-open', url }
    elseif vim.fn.has('win32') == 1 then
        cmd = { 'cmd.exe', '/c', 'start', url }
    end
    if cmd then
        vim.fn.jobstart(cmd, { detach = true })
    else
        vim.notify("fk_markdown: Please open " .. url .. " in your browser.", vim.log.levels.INFO)
    end
end

return M
