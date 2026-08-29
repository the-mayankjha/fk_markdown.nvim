with open('lua/fk_markdown/settings.lua', 'r') as f:
    lines = f.readlines()

for i in range(len(lines)-1, -1, -1):
    if lines[i].strip() == 'return M':
        lines[i] = """
M.preview = {
    default = {
        enabled = true,
        auto_start = false,
        auto_close = true,
        browser = "",
        browser_func = nil,
        port = nil,
        open_ip = "127.0.0.1",
        theme = "dark",
        sync_scroll = true,
        keymap = {
            start = false,
            stop = false,
            toggle = false,
        },
    },
}

return M
"""
        break

with open('lua/fk_markdown/settings.lua', 'w') as f:
    f.writelines(lines)
