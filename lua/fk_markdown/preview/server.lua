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

function M:get_html()
    local state = require('fk_markdown.state')
    local preview_conf = (state.config and state.config.preview) or {}
    local theme = preview_conf.theme or "dark"
    local is_dark = theme ~= "light"

    local syn = preview_conf.syntax_highlight or preview_conf.syntax or preview_conf.code or preview_conf.highlight or {}
    local highlight_enabled = true
    if type(syn) == 'boolean' then
        highlight_enabled = syn
        syn = {}
    elseif type(syn) == 'table' and syn.enabled ~= nil then
        highlight_enabled = syn.enabled
    end

    local hljs_theme = (type(syn) == 'table' and syn.theme) or (is_dark and "github-dark" or "github")
    local custom_colors = (type(syn) == 'table' and syn.colors) or {}

    local markdown_css = is_dark
        and "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-dark.min.css"
        or "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-light.min.css"

    local body_bg = is_dark and "#0d1117" or "#ffffff"

    -- Build custom syntax color CSS overrides
    local custom_css_rules = {}
    if highlight_enabled and type(custom_colors) == 'table' and not vim.tbl_isempty(custom_colors) then
        local bg = custom_colors.background or custom_colors.bg
        local fg = custom_colors.text or custom_colors.fg
        if bg or fg then
            local pre_rule = "pre, code, .markdown-body pre, .markdown-body pre code, .hljs {"
            if bg then pre_rule = pre_rule .. " background-color: " .. bg .. " !important;" end
            if fg then pre_rule = pre_rule .. " color: " .. fg .. " !important;" end
            pre_rule = pre_rule .. " }"
            table.insert(custom_css_rules, pre_rule)
        end

        local border = custom_colors.border or custom_colors.border_color
        if border then
            table.insert(custom_css_rules, ".markdown-body pre { border: 1px solid " .. border .. " !important; }")
        end

        local selector_map = {
            keyword = ".hljs-keyword, .hljs-selector-tag, .hljs-subst",
            string = ".hljs-string, .hljs-doctag",
            number = ".hljs-number, .hljs-literal",
            comment = ".hljs-comment, .hljs-quote, .hljs-meta",
            function_name = ".hljs-title.function_, .hljs-function .hljs-title",
            func = ".hljs-title.function_, .hljs-function .hljs-title",
            title = ".hljs-title, .hljs-title.class_, .hljs-title.function_",
            variable = ".hljs-variable, .hljs-template-variable",
            var = ".hljs-variable, .hljs-template-variable",
            constant = ".hljs-variable.constant_, .hljs-symbol",
            operator = ".hljs-operator, .hljs-punctuation",
            builtin = ".hljs-built_in, .hljs-builtin-name",
            built_in = ".hljs-built_in, .hljs-builtin-name",
            type = ".hljs-type",
            tag = ".hljs-tag, .hljs-name",
            attribute = ".hljs-attribute, .hljs-attr",
            attr = ".hljs-attribute, .hljs-attr",
            parameter = ".hljs-params",
            params = ".hljs-params",
        }

        for key, sel in pairs(selector_map) do
            local col = custom_colors[key]
            if col and col ~= 'NONE' and col ~= '' then
                table.insert(custom_css_rules, sel .. " { color: " .. col .. " !important; }")
            end
        end
    end

    local custom_css_str = #custom_css_rules > 0 and ("\n" .. table.concat(custom_css_rules, "\n") .. "\n") or ""

    local hljs_link = highlight_enabled
        and string.format('<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/%s.min.css">', hljs_theme)
        or ''

    local hljs_script = highlight_enabled
        and '<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>'
        or ''

    local latex_conf = preview_conf.latex
    local latex_enabled = true
    local latex_code_blocks = true
    if type(latex_conf) == 'boolean' then
        latex_enabled = latex_conf
    elseif type(latex_conf) == 'table' then
        if latex_conf.enabled ~= nil then latex_enabled = latex_conf.enabled end
        if latex_conf.code_blocks ~= nil then latex_code_blocks = latex_conf.code_blocks end
    end

    local katex_link = latex_enabled
        and '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">'
        or ''

    local katex_scripts = latex_enabled
        and '<script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>\n<script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>'
        or ''

    return string.format([[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>fk_markdown preview</title>
<link rel="stylesheet" href="%s">
%s
%s
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.0.3/purify.min.js"></script>
%s
%s
<style>
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; padding: 20px; max-width: 900px; margin: auto; background-color: %s; }
.markdown-body { box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; }
.markdown-body pre { border-radius: 8px; }
.markdown-body pre code.hljs { padding: 0; background: transparent; }
.katex-display-block { margin: 1.2em 0; overflow-x: auto; text-align: center; }
@media (max-width: 767px) { .markdown-body { padding: 15px; } }

/* GitHub Alert / Callout Styles */
.markdown-alert {
    padding: 12px 16px;
    margin-bottom: 16px;
    color: inherit;
    border-left: 0.25em solid #30363d;
    border-radius: 6px;
    background-color: rgba(110, 118, 129, 0.05);
}
.markdown-alert > :first-child {
    margin-top: 0;
}
.markdown-alert > :last-child {
    margin-bottom: 0;
}
.markdown-alert .markdown-alert-title {
    display: flex;
    font-weight: 600;
    align-items: center;
    line-height: 1.25;
    margin-bottom: 8px;
    gap: 8px;
    font-size: 14px;
}
.markdown-alert .markdown-alert-title svg {
    margin-right: 0;
    vertical-align: text-bottom;
}

/* Alert Themes */
.markdown-alert.markdown-alert-note {
    border-left-color: #1f6feb;
    background-color: rgba(31, 111, 235, 0.08);
}
.markdown-alert.markdown-alert-note .markdown-alert-title {
    color: #58a6ff;
}

.markdown-alert.markdown-alert-tip {
    border-left-color: #238636;
    background-color: rgba(35, 134, 54, 0.08);
}
.markdown-alert.markdown-alert-tip .markdown-alert-title {
    color: #3fb950;
}

.markdown-alert.markdown-alert-important {
    border-left-color: #8957e5;
    background-color: rgba(137, 87, 229, 0.08);
}
.markdown-alert.markdown-alert-important .markdown-alert-title {
    color: #a371f7;
}

.markdown-alert.markdown-alert-warning {
    border-left-color: #9e6a03;
    background-color: rgba(158, 106, 3, 0.08);
}
.markdown-alert.markdown-alert-warning .markdown-alert-title {
    color: #d29922;
}

.markdown-alert.markdown-alert-caution,
.markdown-alert.markdown-alert-danger {
    border-left-color: #da3633;
    background-color: rgba(218, 54, 51, 0.08);
}
.markdown-alert.markdown-alert-caution .markdown-alert-title,
.markdown-alert.markdown-alert-danger .markdown-alert-title {
    color: #f85149;
}
%s
</style>
</head>
<body>
<article class="markdown-body" id="content"></article>
<script>
const contentDiv = document.getElementById('content');
const syntaxHighlightEnabled = %s;
const latexEnabled = %s;
const latexCodeBlocks = %s;

const alertIcons = {
    note: '<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>',
    tip: '<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.099-.115-.2-.23-.306-.35-.615-.718-1.29-1.583-1.29-2.929 0-2.88 2.327-5.25 5.5-5.25s5.5 2.37 5.5 5.25c0 1.346-.675 2.211-1.29 2.929-.106.12-.207.235-.306.35-.18.21-.36.425-.542.68-.207.3-.33.565-.37.847a.75.75 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5Zm1 2.5h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1 0-1.5Z"></path></svg>',
    important: '<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v9.5A1.75 1.75 0 0 1 14.25 13H8.06l-2.573 2.573A1.458 1.458 0 0 1 3 14.543V13H1.75A1.75 1.75 0 0 1 0 11.25Zm1.75-.25a.25.25 0 0 0-.25.25v9.5c0 .138.112.25.25.25h2a.75.75 0 0 1 .75.75v2.19l2.72-2.72a.749.749 0 0 1 .53-.22h6.5a.25.25 0 0 0 .25-.25v-9.5a.25.25 0 0 0-.25-.25Zm7 2.25v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 9a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"></path></svg>',
    warning: '<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.396A1.75 1.75 0 0 1 14.082 15H1.918A1.75 1.75 0 0 1 .375 12.443Zm1.763.94a.25.25 0 0 0-.44 0L1.698 13.383a.25.25 0 0 0 .22.367h12.164a.25.25 0 0 0 .22-.367L8.22 1.987ZM8 5.5a.75.75 0 0 1 .75.75v2.5a.75.75 0 0 1-1.5 0v-2.5A.75.75 0 0 1 8 5.5Zm0 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>',
    caution: '<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6a.749.749 0 0 1-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5ZM8 4a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>'
};

function processAlerts(container) {
    container.querySelectorAll('blockquote').forEach((bq) => {
        const firstP = bq.querySelector('p');
        if (!firstP) return;
        
        const html = firstP.innerHTML.trim();
        const match = html.match(/^\[!([a-zA-Z_-]+)\]/);
        if (!match) return;
        
        const rawType = match[1].toLowerCase();
        let alertType = rawType;
        if (alertType === 'danger') alertType = 'caution';
        if (alertType === 'info') alertType = 'note';
        
        const titleText = rawType.charAt(0).toUpperCase() + rawType.slice(1);
        const icon = alertIcons[alertType] || alertIcons.note;
        
        // Remove [!TYPE] marker and optional leading break/whitespace
        let remainingHtml = html.slice(match[0].length).replace(/^<br\s*\/?>\s*/i, '').trim();
        if (remainingHtml) {
            firstP.innerHTML = remainingHtml;
        } else {
            firstP.remove();
        }
        
        const titleDiv = document.createElement('p');
        titleDiv.className = 'markdown-alert-title';
        titleDiv.innerHTML = icon + '<span>' + titleText + '</span>';
        
        const alertDiv = document.createElement('div');
        alertDiv.className = 'markdown-alert markdown-alert-' + alertType;
        alertDiv.appendChild(titleDiv);
        
        while (bq.firstChild) {
            alertDiv.appendChild(bq.firstChild);
        }
        
        bq.replaceWith(alertDiv);
    });
}

function renderMarkdown(text) {
    contentDiv.innerHTML = DOMPurify.sanitize(marked.parse(text));
    processAlerts(contentDiv);
    if (latexEnabled) {
        if (latexCodeBlocks && window.katex) {
            contentDiv.querySelectorAll('pre code.language-math, pre code.language-latex, pre code.language-tex').forEach((block) => {
                try {
                    const mathDiv = document.createElement('div');
                    mathDiv.className = 'katex-display-block';
                    katex.render(block.textContent, mathDiv, { displayMode: true, throwOnError: false });
                    block.closest('pre').replaceWith(mathDiv);
                } catch (e) {
                    console.error("KaTeX code block error:", e);
                }
            });
        }
        if (window.renderMathInElement) {
            try {
                renderMathInElement(contentDiv, {
                    delimiters: [
                        { left: '$$', right: '$$', display: true },
                        { left: '\\[', right: '\\]', display: true },
                        { left: '$', right: '$', display: false },
                        { left: '\\(', right: '\\)', display: false }
                    ],
                    throwOnError: false,
                    ignoredTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code', 'option']
                });
            } catch (e) {
                console.error("KaTeX auto-render error:", e);
            }
        }
    }
    if (syntaxHighlightEnabled && window.hljs) {
        contentDiv.querySelectorAll('pre code').forEach((block) => {
            try {
                hljs.highlightElement(block);
            } catch (e) {
                console.error("Syntax highlight error:", e);
            }
        });
    }
}

const es = new EventSource('/events');
es.onmessage = function(e) {
    const payload = JSON.parse(e.data);
    if (payload.type === 'update') {
        renderMarkdown(payload.text);
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
</html>]],
        markdown_css,
        hljs_link,
        katex_link,
        hljs_script,
        katex_scripts,
        body_bg,
        custom_css_str,
        tostring(highlight_enabled),
        tostring(latex_enabled),
        tostring(latex_code_blocks)
    )
end

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
                    local body = self:get_html()
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
