import re

with open('lua/fk_markdown/preview/server.lua', 'r') as f:
    content = f.read()

# Replace the 404 block with a file server
file_server_code = """
                else
                    -- attempt to serve local file
                    local file_path = vim.fn.expand(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ':h') .. path)
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
                        local resp = "HTTP/1.1 200 OK\\r\\nContent-Type: " .. ctype .. "\\r\\nContent-Length: " .. #content .. "\\r\\nConnection: close\\r\\n\\r\\n" .. content
                        client:write(resp)
                        client:close()
                    else
                        client:write("HTTP/1.1 404 Not Found\\r\\nContent-Length: 0\\r\\nConnection: close\\r\\n\\r\\n")
                        client:close()
                    end
                end
"""

content = content.replace(
    'client:write("HTTP/1.1 404 Not Found\\r\\nContent-Length: 0\\r\\nConnection: close\\r\\n\\r\\n")\n                    client:close()\n                end',
    file_server_code
)

with open('lua/fk_markdown/preview/server.lua', 'w') as f:
    f.write(content)
